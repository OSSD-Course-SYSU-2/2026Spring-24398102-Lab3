/**
 * 自由流转管理器
 * 实现应用接续、跨设备协同能力
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { wantConstant, common, Want } from '@kit.AbilityKit';
import { AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'ContinuationManager';

// 设备状态变化回调数据
interface DeviceStateChangeData {
  action: distributedDeviceManager.DeviceStateChange;
  device: distributedDeviceManager.DeviceBasicInfo;
}

// 设备信息接口
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
}

// 流转状态
export enum ContinuationState {
  IDLE = 'idle',           // 空闲
  CONNECTING = 'connecting', // 连接中
  READY = 'ready',         // 就绪
  TRANSFERRING = 'transferring' // 流转中
}

// 流转回调类
export class ContinuationCallback {
  onDeviceAvailable?: (devices: DeviceInfo[]) => void;
  onStateChanged?: (state: ContinuationState) => void;
  onTransferSuccess?: (deviceId: string) => void;
  onTransferFailed?: (error: string) => void;
}

/**
 * 自由流转管理器
 * 提供跨设备流转能力
 */
export class ContinuationManager {
  private static instance: ContinuationManager;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private context: common.UIAbilityContext | null = null;
  private state: ContinuationState = ContinuationState.IDLE;
  private callback: ContinuationCallback | null = null;
  private availableDevices: DeviceInfo[] = [];
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ContinuationManager {
    if (!ContinuationManager.instance) {
      ContinuationManager.instance = new ContinuationManager();
    }
    return ContinuationManager.instance;
  }
  
  /**
   * 初始化流转管理器
   * @param context 应用上下文
   * @param callback 流转回调
   */
  public async initialize(
    context: common.UIAbilityContext,
    callback?: ContinuationCallback
  ): Promise<void> {
    try {
      this.context = context;
      this.callback = callback || null;
      
      // 创建设备管理器
      this.deviceManager = distributedDeviceManager.createDeviceManager(context.applicationInfo.name);
      
      // 注册设备状态监听
      this.registerDeviceListener();
      
      hilog.info(DOMAIN, TAG, '流转管理器初始化成功');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `初始化失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 注册设备状态监听（合并设备发现与状态变化）
   */
  private registerDeviceListener(): void {
    if (!this.deviceManager) return;
    
    this.deviceManager.on('deviceStateChange', (data: DeviceStateChangeData) => {
      if (data.action === distributedDeviceManager.DeviceStateChange.AVAILABLE) {
        hilog.info(DOMAIN, TAG, `设备上线: ${data.device.deviceName}`);
      } else {
        hilog.info(DOMAIN, TAG, `设备下线: ${data.device.deviceName}`);
      }
      this.updateAvailableDevices();
    });
  }
  
  /**
   * 更新可用设备列表
   */
  private async updateAvailableDevices(): Promise<void> {
    if (!this.deviceManager) return;
    
    try {
      const deviceInfos: Array<distributedDeviceManager.DeviceBasicInfo> = this.deviceManager.getAvailableDeviceListSync();
      this.availableDevices = deviceInfos.map((device: distributedDeviceManager.DeviceBasicInfo): DeviceInfo => {
        return {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          networkId: device.networkId ?? ''
        };
      });
      
      // 触发回调
      if (this.callback?.onDeviceAvailable) {
        this.callback.onDeviceAvailable(this.availableDevices);
      }
      
      hilog.info(DOMAIN, TAG, `可用设备数量: ${this.availableDevices.length}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `更新设备列表失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取可用设备列表
   * @returns 设备列表
   */
  public getAvailableDevices(): DeviceInfo[] {
    return this.availableDevices;
  }
  
  /**
   * 开始流转到指定设备
   * @param deviceId 目标设备ID
   */
  public async startContinuation(deviceId: string): Promise<void> {
    if (!this.context) {
      hilog.error(DOMAIN, TAG, 'Context未初始化');
      return;
    }
    
    try {
      this.updateState(ContinuationState.CONNECTING);
      
      // 构造流转Want
      const want: Want = {
        deviceId: deviceId,
        bundleName: this.context.applicationInfo.name,
        abilityName: 'EntryAbility',
        parameters: {
          // 标记为流转启动
          'ohos.aafwk.continuation': true,
          // 携带当前状态数据
          'continuationData': await this.prepareContinuationData()
        }
      };
      
      // 启动远程Ability
      await this.context.startAbility(want);
      
      this.updateState(ContinuationState.TRANSFERRING);
      
      hilog.info(DOMAIN, TAG, `流转已启动: ${deviceId}`);
    } catch (error) {
      this.updateState(ContinuationState.IDLE);
      const errorMsg = `流转失败: ${JSON.stringify(error)}`;
      hilog.error(DOMAIN, TAG, errorMsg);
      
      if (this.callback?.onTransferFailed) {
        this.callback.onTransferFailed(errorMsg);
      }
    }
  }
  
  /**
   * 准备流转数据（包含应用完整状态）
   * @returns 流转数据JSON字符串
   */
  private async prepareContinuationData(): Promise<string> {
    // 定义流转数据接口
    interface ContinuationData {
      currentBreakpoint: string;
      currentCity: string;
      currentPage: string;
      timestamp: number;
      gameProgress?: Record<string, Object>;
      userPreferences?: Record<string, Object>;
    }
    
    // 从AppStorage获取当前状态
    const continuationData: ContinuationData = {
      currentBreakpoint: AppStorage.get('currentBreakpoint') as string || 'sm',
      currentCity: AppStorage.get('currentCity') as string || '广州',
      currentPage: AppStorage.get('currentPage') as string || 'pages/Index',
      timestamp: Date.now()
    };
    
    // 携带游戏进度（如果存在）
    const gameProgress: Record<string, Object> | undefined = AppStorage.get('gameProgress') as (Record<string, Object> | undefined);
    if (gameProgress) {
      continuationData.gameProgress = gameProgress;
    }
    
    // 携带用户偏好（如果存在）
    const userPreferences: Record<string, Object> | undefined = AppStorage.get('userPreferences') as (Record<string, Object> | undefined);
    if (userPreferences) {
      continuationData.userPreferences = userPreferences;
    }
    
    return JSON.stringify(continuationData);
  }
  
  /**
   * 处理流转数据
   * @param continuationData 流转数据
   */
  public handleContinuationData(continuationData: string): void {
    try {
      // 定义流转数据接口
      interface ContinuationData {
        currentBreakpoint?: string;
        currentCity?: string;
        currentPage?: string;
        timestamp?: number;
        gameProgress?: Record<string, Object>;
        userPreferences?: Record<string, Object>;
      }
      
      const data: ContinuationData = JSON.parse(continuationData) as ContinuationData;
      
      // 恢复状态
      if (data.currentBreakpoint) {
        AppStorage.setOrCreate('currentBreakpoint', data.currentBreakpoint);
      }
      
      if (data.currentCity) {
        AppStorage.setOrCreate('currentCity', data.currentCity);
      }
      
      if (data.currentPage) {
        AppStorage.setOrCreate('currentPage', data.currentPage);
      }
      
      // 恢复游戏进度
      if (data.gameProgress) {
        AppStorage.setOrCreate('gameProgress', data.gameProgress);
      }
      
      // 恢复用户偏好
      if (data.userPreferences) {
        AppStorage.setOrCreate('userPreferences', data.userPreferences);
      }
      
      hilog.info(DOMAIN, TAG, '流转数据已处理');
      
      // 通知成功
      if (this.callback?.onTransferSuccess) {
        this.callback.onTransferSuccess('local');
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `处理流转数据失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 更新流转状态
   * @param newState 新状态
   */
  private updateState(newState: ContinuationState): void {
    this.state = newState;
    
    if (this.callback?.onStateChanged) {
      this.callback.onStateChanged(newState);
    }
    
    hilog.info(DOMAIN, TAG, `流转状态更新: ${newState}`);
  }
  
  /**
   * 获取当前流转状态
   * @returns 当前状态
   */
  public getState(): ContinuationState {
    return this.state;
  }
  
  /**
   * 取消流转
   */
  public cancelContinuation(): void {
    this.updateState(ContinuationState.IDLE);
    hilog.info(DOMAIN, TAG, '流转已取消');
  }
  
  /**
   * 销毁资源
   */
  public destroy(): void {
    if (this.deviceManager) {
      this.deviceManager.off('deviceStateChange');
      this.deviceManager = null;
    }
    
    this.context = null;
    this.callback = null;
    this.availableDevices = [];
    
    hilog.info(DOMAIN, TAG, '流转管理器已销毁');
  }
}

/**
 * 流转工具类
 * 提供便捷的流转操作方法
 */
export class ContinuationHelper {
  /**
   * 检查是否为流转启动
   * @param want 启动Want
   * @returns 是否为流转启动
   */
  public static isContinuationLaunch(want: Want): boolean {
    return want.parameters?.['ohos.aafwk.continuation'] === true;
  }
  
  /**
   * 获取流转数据
   * @param want 启动Want
   * @returns 流转数据或null
   */
  public static getContinuationData(want: Want): string | null {
    return want.parameters?.['continuationData'] as string || null;
  }
  
  /**
   * 设备类型显示名称
   * @param deviceType 设备类型
   * @returns 显示名称
   */
  public static getDeviceTypeDisplayName(deviceType: string): string {
    const typeMap: Record<string, string> = {
      '0': '未知设备',
      '1': '手机',
      '2': '平板',
      '3': '智慧屏',
      '4': '智能手表',
      '5': '车机',
      '6': 'PC'
    };
    
    return typeMap[deviceType] || '未知设备';
  }
}
