import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointType } from '../utils/BreakpointSystem';
import { DistributedDataManager } from '../utils/DistributedDataManager';
import { ContinuationManager, ContinuationHelper, ContinuationCallback, DeviceInfo, ContinuationState } from '../utils/ContinuationManager';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  private distributedDataManager: DistributedDataManager = DistributedDataManager.getInstance();
  private continuationManager: ContinuationManager = ContinuationManager.getInstance();
  
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    // 检查是否为流转启动
    if (ContinuationHelper.isContinuationLaunch(want)) {
      const continuationData = ContinuationHelper.getContinuationData(want);
      if (continuationData) {
        this.continuationManager.handleContinuationData(continuationData);
        hilog.info(DOMAIN, TAG, '应用接续启动');
      }
    }
    
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    // 释放资源
    this.breakpointSystem.unregister();
    this.distributedDataManager.destroy();
    this.continuationManager.destroy();
    
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    // 提前初始化分布式数据管理，确保页面加载时 KVStore 已就绪
    this.distributedDataManager.initialize(this.context)
      .then(() => {
        hilog.info(DOMAIN, TAG, '分布式数据管理已初始化');
      })
      .catch((error: Error) => {
        hilog.error(DOMAIN, TAG, `分布式数据管理初始化失败: ${error.message}`);
      });

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      
      // 初始化响应式布局系统
      try {
        const mainWindow = windowStage.getMainWindowSync();
        this.breakpointSystem.register(mainWindow);
        hilog.info(DOMAIN, TAG, '断点系统已初始化');
      } catch (error) {
        hilog.error(DOMAIN, TAG, `断点系统初始化失败: ${JSON.stringify(error)}`);
      }
      
      // 初始化流转管理器
      const continuationCallback: ContinuationCallback = {
        onDeviceAvailable: (devices: DeviceInfo[]) => {
          hilog.info(DOMAIN, TAG, `发现${devices.length}个可用设备`);
        },
        onStateChanged: (state: ContinuationState) => {
          hilog.info(DOMAIN, TAG, `流转状态: ${state}`);
        },
        onTransferSuccess: (deviceId: string) => {
          hilog.info(DOMAIN, TAG, `流转成功: ${deviceId}`);
        },
        onTransferFailed: (error: string) => {
          hilog.error(DOMAIN, TAG, `流转失败: ${error}`);
        }
      };
      this.continuationManager.initialize(this.context, continuationCallback);
      
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * 系统级流转回调：保存当前状态到wantParams
   * 用户在任务中心选择"流转"时触发
   */
  onContinue(wantParams: Record<string, Object>): AbilityConstant.OnContinueResult {
    try {
      const currentBreakpoint = AppStorage.get<BreakpointType>('currentBreakpoint') || 'sm';
      wantParams['currentBreakpoint'] = currentBreakpoint;
      const currentCity = AppStorage.get<string>('currentCity') || '广州';
      wantParams['currentCity'] = currentCity;
      const currentPage = AppStorage.get<string>('currentPage') || 'pages/Index';
      wantParams['currentPage'] = currentPage;
      
      // 携带游戏进度
      const gameProgress: Object | undefined = AppStorage.get('gameProgress');
      if (gameProgress) {
        wantParams['gameProgress'] = gameProgress;
      }
      
      // 携带用户偏好
      const userPreferences: Object | undefined = AppStorage.get('userPreferences');
      if (userPreferences) {
        wantParams['userPreferences'] = userPreferences;
      }
      
      hilog.info(DOMAIN, TAG, '流转状态已保存');
      return AbilityConstant.OnContinueResult.AGREE;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `保存流转状态失败: ${JSON.stringify(error)}`);
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  /**
   * 系统级流转回调：从wantParams恢复状态
   * 在目标设备上继续时触发
   */
  onRestore(wantParams: Record<string, Object>): void {
    try {
      if (wantParams['currentBreakpoint']) {
        AppStorage.setOrCreate('currentBreakpoint', wantParams['currentBreakpoint'] as BreakpointType);
      }
      if (wantParams['currentCity']) {
        AppStorage.setOrCreate('currentCity', wantParams['currentCity'] as string);
      }
      if (wantParams['currentPage']) {
        AppStorage.setOrCreate('currentPage', wantParams['currentPage'] as string);
      }
      if (wantParams['gameProgress']) {
        AppStorage.setOrCreate('gameProgress', wantParams['gameProgress']);
      }
      if (wantParams['userPreferences']) {
        AppStorage.setOrCreate('userPreferences', wantParams['userPreferences']);
      }
      hilog.info(DOMAIN, TAG, '流转状态已恢复');
    } catch (error) {
      hilog.error(DOMAIN, TAG, `恢复流转状态失败: ${JSON.stringify(error)}`);
    }
  }
}