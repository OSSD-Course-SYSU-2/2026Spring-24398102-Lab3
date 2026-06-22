/**
 * 响应式布局组件示例
 * 展示如何使用断点系统和栅格布局实现多端适配
 */
import { BreakpointType, BreakpointValue, BreakpointConstants } from '../utils/BreakpointSystem';

/**
 * 响应式容器组件
 * 根据断点自动调整布局
 */
@Component
export struct ResponsiveContainer {
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm';
  @BuilderParam content: () => void;
  
  build() {
    GridRow({
      // 根据断点配置列数
      columns: {
        xs: BreakpointConstants.GRID_COLUMNS.xs,
        sm: BreakpointConstants.GRID_COLUMNS.sm,
        md: BreakpointConstants.GRID_COLUMNS.md,
        lg: BreakpointConstants.GRID_COLUMNS.lg,
        xl: BreakpointConstants.GRID_COLUMNS.xl
      },
      // 根据断点配置间距
      gutter: {
        x: new BreakpointValue({
          xs: BreakpointConstants.GRID_GUTTER.xs,
          sm: BreakpointConstants.GRID_GUTTER.sm,
          md: BreakpointConstants.GRID_GUTTER.md,
          lg: BreakpointConstants.GRID_GUTTER.lg,
          xl: BreakpointConstants.GRID_GUTTER.xl
        }).getValue(this.currentBreakpoint),
        y: 16
      },
      breakpoints: {
        value: ['320vp', '600vp', '840vp', '1440vp'],
        reference: BreakpointsReference.WindowSize
      }
    }) {
      GridCol({
        // 根据断点配置占据列数
        span: {
          xs: 4,  // 小屏占满
          sm: 4,  // 手机占满
          md: 8,  // 平板占大部分
          lg: 10, // 大屏占主体
          xl: 10  // 超大屏占主体
        },
        offset: {
          md: 0,
          lg: 1,  // 大屏居中
          xl: 1   // 超大屏居中
        }
      }) {
        Column() {
          this.content();
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 响应式卡片组件
 * 根据设备尺寸自动调整卡片样式
 */
@Component
export struct ResponsiveCard {
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm';
  @Prop title: string = '';
  @Prop content: string = '';
  @BuilderParam extraContent?: () => void;
  
  // 根据断点获取卡片内边距
  private getCardPadding(): number {
    return new BreakpointValue({
      xs: 12,
      sm: 16,
      md: 20,
      lg: 24,
      xl: 32
    }).getValue(this.currentBreakpoint) || 16;
  }
  
  // 根据断点获取标题字体大小
  private getTitleFontSize(): number {
    return new BreakpointValue({
      xs: 16,
      sm: 18,
      md: 20,
      lg: 22,
      xl: 24
    }).getValue(this.currentBreakpoint) || 18;
  }
  
  // 根据断点获取内容字体大小
  private getContentFontSize(): number {
    return new BreakpointValue({
      xs: 12,
      sm: 14,
      md: 14,
      lg: 16,
      xl: 16
    }).getValue(this.currentBreakpoint) || 14;
  }
  
  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 });
      
      // 内容
      Text(this.content)
        .fontSize(this.getContentFontSize())
        .fontColor('#666666')
        .width('100%');
      
      // 额外内容
      if (this.extraContent) {
        this.extraContent();
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    .backgroundColor('#FFFFFF')
    .borderRadius(new BreakpointValue({
      xs: 8,
      sm: 12,
      md: 16,
      lg: 20,
      xl: 24
    }).getValue(this.currentBreakpoint) || 12)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    });
  }
}

/**
 * 响应式按钮组件
 * 根据设备尺寸自动调整按钮大小和间距
 */
@Component
export struct ResponsiveButton {
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm';
  @Prop text: string = '';
  @Prop type: 'primary' | 'secondary' = 'primary';
  private onClick?: () => void;
  
  // 根据断点获取按钮高度
  private getButtonHeight(): number {
    return new BreakpointValue({
      xs: 36,
      sm: 40,
      md: 44,
      lg: 48,
      xl: 52
    }).getValue(this.currentBreakpoint) || 40;
  }
  
  // 根据断点获取字体大小
  private getFontSize(): number {
    return new BreakpointValue({
      xs: 14,
      sm: 16,
      md: 16,
      lg: 18,
      xl: 18
    }).getValue(this.currentBreakpoint) || 16;
  }
  
  build() {
    Button(this.text)
      .width('100%')
      .height(this.getButtonHeight())
      .fontSize(this.getFontSize())
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.type === 'primary' ? '#1a73e8' : '#f5f5f5')
      .fontColor(this.type === 'primary' ? '#FFFFFF' : '#333333')
      .borderRadius(new BreakpointValue({
        xs: 6,
        sm: 8,
        md: 10,
        lg: 12,
        xl: 14
      }).getValue(this.currentBreakpoint) || 8)
      .onClick(() => {
        if (this.onClick) {
          this.onClick();
        }
      });
  }
}

/**
 * 响应式列表组件
 * 根据设备尺寸自动调整列数
 */
@Component
export struct ResponsiveGrid {
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm';
  @Prop dataList: Array<any> = [];
  @BuilderParam itemBuilder: (item: any, index: number) => void;
  
  // 根据断点获取列数
  private getColumns(): number {
    return new BreakpointValue({
      xs: 1,
      sm: 2,
      md: 3,
      lg: 4,
      xl: 5
    }).getValue(this.currentBreakpoint) || 2;
  }
  
  // 根据断点获取间距
  private getGutter(): number {
    return new BreakpointValue({
      xs: 8,
      sm: 12,
      md: 16,
      lg: 20,
      xl: 24
    }).getValue(this.currentBreakpoint) || 12;
  }
  
  build() {
    Grid() {
      ForEach(this.dataList, (item: any, index: number) => {
        GridItem() {
          this.itemBuilder(item, index);
        }
      }, (item: any, index: number) => index.toString())
    }
    .columnsTemplate(`repeat(${this.getColumns()}, 1fr)`)
    .rowsGap(this.getGutter())
    .columnsGap(this.getGutter())
    .width('100%');
  }
}
