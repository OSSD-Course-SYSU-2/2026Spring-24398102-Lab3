/**
 * 响应式布局断点系统
 * 实现多端适配的核心能力
 */
import { mediaquery } from '@kit.ArkUI';
import { window } from '@kit.ArkUI';

// 断点类型定义
export type BreakpointType = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

// 断点配置接口
export interface BreakpointConfig {
  name: BreakpointType;
  size: number;
  mediaQueryListener?: mediaquery.MediaQueryListener;
}

/**
 * 断点系统管理类
 * 负责监听窗口尺寸变化并更新断点状态
 */
export class BreakpointSystem {
  private static instance: BreakpointSystem;
  
  // 标准断点配置
  private readonly breakpoints: BreakpointConfig[] = [
    { name: 'xs', size: 0 },      // 超小屏(0-320vp) - 智能穿戴
    { name: 'sm', size: 320 },    // 小屏(320-600vp) - 手机竖屏
    { name: 'md', size: 600 },    // 中屏(600-840vp) - 平板竖屏/折叠屏
    { name: 'lg', size: 840 },    // 大屏(840-1440vp) - 平板横屏/PC
    { name: 'xl', size: 1440 }    // 超大屏(1440vp+) - 大屏显示器
  ];
  
  private currentBreakpoint: BreakpointType = 'sm';
  private listeners: Set<mediaquery.MediaQueryListener> = new Set();
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }
  
  /**
   * 注册断点监听
   * @param windowClass 窗口对象
   */
  public register(windowClass: window.Window): void {
    try {
      // 获取初始窗口尺寸
      const windowProperties = windowClass.getWindowProperties();
      const initialWidth = windowProperties.windowRect.width;
      const uiContext = windowClass.getUIContext();
      const initialWidthVp = uiContext.px2vp(initialWidth);
      
      // 计算初始断点
      this.updateBreakpoint(initialWidthVp);
      
      // 监听窗口尺寸变化
      windowClass.on('windowSizeChange', (size: window.Size) => {
        const widthVp = uiContext.px2vp(size.width);
        this.updateBreakpoint(widthVp);
      });
      
      console.info('[BreakpointSystem] 断点监听已注册');
    } catch (error) {
      console.error(`[BreakpointSystem] 注册失败: ${JSON.stringify(error)}`);
    }
  }
  
  /**
   * 注销断点监听
   */
  public unregister(): void {
    this.listeners.forEach(listener => {
      listener.off('change');
    });
    this.listeners.clear();
    console.info('[BreakpointSystem] 断点监听已注销');
  }
  
  /**
   * 更新断点状态
   * @param widthVp 窗口宽度(vp)
   */
  private updateBreakpoint(widthVp: number): void {
    let newBreakpoint: BreakpointType = 'sm';
    
    if (widthVp < 320) {
      newBreakpoint = 'xs';
    } else if (widthVp < 600) {
      newBreakpoint = 'sm';
    } else if (widthVp < 840) {
      newBreakpoint = 'md';
    } else if (widthVp < 1440) {
      newBreakpoint = 'lg';
    } else {
      newBreakpoint = 'xl';
    }
    
    // 仅在断点变化时更新
    if (this.currentBreakpoint !== newBreakpoint) {
      this.currentBreakpoint = newBreakpoint;
      // 更新全局状态
      AppStorage.setOrCreate<BreakpointType>('currentBreakpoint', newBreakpoint);
      console.info(`[BreakpointSystem] 断点变化: ${newBreakpoint} (${widthVp}vp)`);
    }
  }
  
  /**
   * 获取当前断点
   */
  public getCurrentBreakpoint(): BreakpointType {
    return this.currentBreakpoint;
  }
}

/**
 * 断点值映射工具类
 * 用于根据不同断点返回不同的值
 */
export class BreakpointValue<T> {
  private xsValue: T | undefined = undefined;
  private smValue: T | undefined = undefined;
  private mdValue: T | undefined = undefined;
  private lgValue: T | undefined = undefined;
  private xlValue: T | undefined = undefined;
  
  constructor(xs?: T, sm?: T, md?: T, lg?: T, xl?: T) {
    this.xsValue = xs;
    this.smValue = sm;
    this.mdValue = md;
    this.lgValue = lg;
    this.xlValue = xl;
  }
  
  /**
   * 根据断点获取对应值
   * @param breakpoint 当前断点
   * @returns 对应的值,如果没有则返回sm断点的值
   */
  public getValue(breakpoint: BreakpointType): T | undefined {
    // 优先返回当前断点的值
    if (breakpoint === 'xs' && this.xsValue !== undefined) {
      return this.xsValue;
    }
    if (breakpoint === 'sm' && this.smValue !== undefined) {
      return this.smValue;
    }
    if (breakpoint === 'md' && this.mdValue !== undefined) {
      return this.mdValue;
    }
    if (breakpoint === 'lg' && this.lgValue !== undefined) {
      return this.lgValue;
    }
    if (breakpoint === 'xl' && this.xlValue !== undefined) {
      return this.xlValue;
    }
    
    // 降级查找: lg -> md -> sm -> xs
    if (this.lgValue !== undefined) return this.lgValue;
    if (this.mdValue !== undefined) return this.mdValue;
    if (this.smValue !== undefined) return this.smValue;
    if (this.xsValue !== undefined) return this.xsValue;
    
    return undefined;
  }
}

/**
 * 常用断点常量
 */
export class BreakpointConstants {
  // 断点名称
  static readonly BREAKPOINT_XS: BreakpointType = 'xs';
  static readonly BREAKPOINT_SM: BreakpointType = 'sm';
  static readonly BREAKPOINT_MD: BreakpointType = 'md';
  static readonly BREAKPOINT_LG: BreakpointType = 'lg';
  static readonly BREAKPOINT_XL: BreakpointType = 'xl';
  
  // 栅格布局默认配置
  static readonly GRID_COLUMNS_XS: number = 4;
  static readonly GRID_COLUMNS_SM: number = 4;
  static readonly GRID_COLUMNS_MD: number = 8;
  static readonly GRID_COLUMNS_LG: number = 12;
  static readonly GRID_COLUMNS_XL: number = 12;
  
  // 栅格间距配置(vp)
  static readonly GRID_GUTTER_XS: number = 12;
  static readonly GRID_GUTTER_SM: number = 16;
  static readonly GRID_GUTTER_MD: number = 20;
  static readonly GRID_GUTTER_LG: number = 24;
  static readonly GRID_GUTTER_XL: number = 24;
  
  // 内容边距配置(vp)
  static readonly CONTENT_PADDING_XS: number = 16;
  static readonly CONTENT_PADDING_SM: number = 20;
  static readonly CONTENT_PADDING_MD: number = 24;
  static readonly CONTENT_PADDING_LG: number = 32;
  static readonly CONTENT_PADDING_XL: number = 48;
}
