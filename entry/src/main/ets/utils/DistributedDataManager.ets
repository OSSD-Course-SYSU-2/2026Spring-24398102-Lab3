/**
 * 分布式数据管理器
 * 实现跨设备数据同步与一致性保证
 */
import { distributedKVStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// 分布式数据存储键名常量
export class DistributedDataKeys {
  static readonly WEATHER_DATA = 'weather_data';
  static readonly CURRENT_CITY = 'current_city';
  static readonly USER_PREFERENCES = 'user_preferences';
  static readonly GAME_PROGRESS = 'game_progress';
}

// 天气数据接口
export interface WeatherData {
  city: string;
  weather: string;
  temperature: string;
  humidity: string;
  windDirection: string;
  windSpeed: string;
  airQuality: string;
  lastUpdate: number; // 时间戳
}

// 用户偏好设置接口
export interface UserPreferences {
  temperatureUnit: string; // 'celsius' | 'fahrenheit'
  theme: string; // 'light' | 'dark' | 'auto'
  notifications: boolean;
  autoUpdate: boolean;
}

// 游戏进度接口
export interface GameProgress {
  currentLevel: number;
  completedLevels: number;
  lastUpdateDate: string;
  totalStars: number;
}

/**
 * 分布式数据管理类
 * 提供跨设备数据同步能力
 */
export class DistributedDataManager {
  private static instance: DistributedDataManager;
  private kvManager: distributedKVStore.KVManager | null = null;
  private kvStore: distributedKVStore.SingleKVStore | null = null;
  private context: common.UIAbilityContext | null = null;
  private readyPromise: Promise<void>;
  private readyResolve: (() => void) | null = null;
  
  private constructor() {
    this.readyPromise = new Promise<void>((resolve) => {
      this.readyResolve = resolve;
    });
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): DistributedDataManager {
    if (!DistributedDataManager.instance) {
      DistributedDataManager.instance = new DistributedDataManager();
    }
    return DistributedDataManager.instance;
  }
  
  /**
   * 初始化分布式数据存储
   * @param context 应用上下文
   */
  public async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      this.context = context;
      
      // 创建KVManager
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        bundleName: context.applicationInfo.name,
        context: context
      };
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      
      // 创建分布式KVStore
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };
      
      this.kvStore = await this.kvManager.getKVStore('weather_distributed_store', options) as distributedKVStore.SingleKVStore;
      
      // 注册数据变更监听
      this.registerDataChangeListener();
      
      console.info('[DistributedDataManager] 初始化成功');
      // 通知等待者管理器已就绪
      if (this.readyResolve) {
        this.readyResolve();
      }
    } catch (error) {
      console.error(`[DistributedDataManager] 初始化失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 注册数据变更监听
   */
  private registerDataChangeListener(): void {
    if (!this.kvStore) return;
    
    this.kvStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE, 
      (changeNotification: distributedKVStore.ChangeNotification) => {
        console.info('[DistributedDataManager] 收到远程数据变更');
        // 触发UI更新
        AppStorage.setOrCreate<number>('distributedDataUpdated', Date.now());
      });
  }
  
  /**
   * 保存天气数据
   * @param data 天气数据
   */
  public async saveWeatherData(data: WeatherData): Promise<void> {
    if (!this.kvStore) {
      console.error('[DistributedDataManager] KVStore未初始化');
      return;
    }
    
    try {
      const jsonString = JSON.stringify(data);
      await this.kvStore.put(DistributedDataKeys.WEATHER_DATA, jsonString);
      console.info('[DistributedDataManager] 天气数据已保存');
    } catch (error) {
      console.error(`[DistributedDataManager] 保存天气数据失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取天气数据
   * @returns 天气数据或null
   */
  public async getWeatherData(): Promise<WeatherData | null> {
    if (!this.kvStore) return null;
    
    try {
      const jsonString = await this.kvStore.get(DistributedDataKeys.WEATHER_DATA) as string;
      if (jsonString) {
        return JSON.parse(jsonString) as WeatherData;
      }
      return null;
    } catch (error) {
      console.error(`[DistributedDataManager] 获取天气数据失败: ${JSON.stringify(error)}`);
      return null;
    }
  }
  
  /**
   * 保存当前城市
   * @param city 城市名称
   */
  public async saveCurrentCity(city: string): Promise<void> {
    if (!this.kvStore) return;
    
    try {
      await this.kvStore.put(DistributedDataKeys.CURRENT_CITY, city);
      console.info(`[DistributedDataManager] 当前城市已保存: ${city}`);
    } catch (error) {
      console.error(`[DistributedDataManager] 保存当前城市失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取当前城市
   * @returns 城市名称
   */
  public async getCurrentCity(): Promise<string> {
    if (!this.kvStore) return '';
    
    try {
      const result = await this.kvStore.get(DistributedDataKeys.CURRENT_CITY);
      return result as string || '';
    } catch (error) {
      console.error(`[DistributedDataManager] 获取当前城市失败: ${JSON.stringify(error)}`);
      return '';
    }
  }
  
  /**
   * 保存用户偏好设置
   * @param preferences 用户偏好
   */
  public async saveUserPreferences(preferences: UserPreferences): Promise<void> {
    if (!this.kvStore) return;
    
    try {
      const jsonString = JSON.stringify(preferences);
      await this.kvStore.put(DistributedDataKeys.USER_PREFERENCES, jsonString);
      console.info('[DistributedDataManager] 用户偏好已保存');
    } catch (error) {
      console.error(`[DistributedDataManager] 保存用户偏好失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取用户偏好设置
   * @returns 用户偏好或默认值
   */
  public async getUserPreferences(): Promise<UserPreferences> {
    const defaultPreferences: UserPreferences = {
      temperatureUnit: 'celsius',
      theme: 'auto',
      notifications: true,
      autoUpdate: true
    };
    
    if (!this.kvStore) return defaultPreferences;
    
    try {
      const jsonString = await this.kvStore.get(DistributedDataKeys.USER_PREFERENCES) as string;
      if (jsonString) {
        return JSON.parse(jsonString) as UserPreferences;
      }
      return defaultPreferences;
    } catch (error) {
      console.error(`[DistributedDataManager] 获取用户偏好失败: ${JSON.stringify(error)}`);
      return defaultPreferences;
    }
  }
  
  /**
   * 保存游戏进度
   * @param progress 游戏进度
   */
  public async saveGameProgress(progress: GameProgress): Promise<void> {
    if (!this.kvStore) return;
    
    try {
      const jsonString = JSON.stringify(progress);
      await this.kvStore.put(DistributedDataKeys.GAME_PROGRESS, jsonString);
      console.info('[DistributedDataManager] 游戏进度已保存');
    } catch (error) {
      console.error(`[DistributedDataManager] 保存游戏进度失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 获取游戏进度
   * @returns 游戏进度或null
   */
  public async getGameProgress(): Promise<GameProgress | null> {
    if (!this.kvStore) return null;
    
    try {
      const jsonString = await this.kvStore.get(DistributedDataKeys.GAME_PROGRESS) as string;
      if (jsonString) {
        return JSON.parse(jsonString) as GameProgress;
      }
      return null;
    } catch (error) {
      console.error(`[DistributedDataManager] 获取游戏进度失败: ${JSON.stringify(error)}`);
      return null;
    }
  }
  
  /**
   * 手动触发数据同步
   */
  public async syncData(): Promise<void> {
    if (!this.kvStore) return;
    
    try {
      await this.kvStore.sync([], distributedKVStore.SyncMode.PUSH_PULL);
      console.info('[DistributedDataManager] 数据同步已触发');
    } catch (error) {
      console.error(`[DistributedDataManager] 数据同步失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 等待管理器初始化完成
   */
  public async waitForReady(): Promise<void> {
    await this.readyPromise;
  }

  /**
   * 销毁资源
   */
  public async destroy(): Promise<void> {
    try {
      if (this.kvStore && this.kvManager) {
        const appId: string = this.context?.applicationInfo.name ?? '';
        const storeId: string = 'weather_distributed_store';
        await this.kvManager.closeKVStore(appId, storeId);
        this.kvStore = null;
        this.kvManager = null;
        console.info('[DistributedDataManager] 资源已释放');
      }
    } catch (error) {
      console.error(`[DistributedDataManager] 销毁失败: ${JSON.stringify(error)}`);
    }
  }
}
