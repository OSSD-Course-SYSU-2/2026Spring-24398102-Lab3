// 天气背景动画组件
@Component
export struct WeatherBackground {
  @Prop weatherType: string = '晴天'
  @State animationTime: number = 0
  @State lightningFlash: boolean = false  // 闪电闪烁状态
  private timer: number = -1
  private lightningTimer: number = -1  // 闪电定时器
  
  aboutToAppear() {
    // 启动动画定时器
    this.timer = setInterval(() => {
      this.animationTime += 1
    }, 50)
    
    // 启动闪电定时器（仅雷阵雨时使用）
    this.startLightningTimer()
  }
  
  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
    if (this.lightningTimer !== -1) {
      clearInterval(this.lightningTimer)
    }
  }
  
  // 启动闪电定时器
  startLightningTimer() {
    // 随机间隔3-6秒闪烁一次
    const randomInterval = 3000 + Math.random() * 3000
    
    this.lightningTimer = setInterval(() => {
      if (this.weatherType === '雷阵雨') {
        // 闪电效果：快速闪烁2次
        this.lightningFlash = true
        setTimeout(() => {
          this.lightningFlash = false
          setTimeout(() => {
            this.lightningFlash = true
            setTimeout(() => {
              this.lightningFlash = false
            }, 50)
          }, 100)
        }, 50)
      }
    }, randomInterval)
  }
  
  // 根据天气类型获取背景颜色
  getBackgroundColor(): string {
    switch (this.weatherType) {
      case '晴天':
        return '#87CEEB' // 天蓝色
      case '多云':
        return '#B0C4DE' // 浅钢蓝色
      case '阴天':
        return '#A9A9A9' // 深灰色
      case '小雨':
      case '中雨':
      case '大雨':
        return '#708090' // 石板灰色
      case '雷阵雨':
        return '#4A5568' // 深灰色（更暗，适合闪电效果）
      case '小雪':
      case '中雪':
      case '大雪':
        return '#B8C4CE' // 深灰蓝色，提高对比度
      default:
        return '#87CEEB'
    }
  }
  
  build() {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getBackgroundColor())
      
      // 根据天气类型渲染不同的动画效果
      if (this.weatherType === '晴天') {
        this.SunnyAnimation()
      } else if (this.weatherType === '多云') {
        this.CloudyAnimation()
      } else if (this.weatherType === '雷阵雨') {
        this.ThunderstormAnimation()
      } else if (this.weatherType.includes('雨')) {
        this.RainAnimation()
      } else if (this.weatherType.includes('雪')) {
        this.SnowAnimation()
      } else if (this.weatherType === '阴天') {
        this.OvercastAnimation()
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 晴天动画 - 太阳光芒
  @Builder
  SunnyAnimation() {
    Stack() {
      // 太阳
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#FFD700')
        .borderRadius(20)
        .shadow({
          radius: 20,
          color: '#FFD700',
          offsetX: 0,
          offsetY: 0
        })
        .position({ x: '70%', y: '20%' })
      
      // 光芒射线
      ForEach([0, 45, 90, 135], (angle: number) => {
        Column()
          .width(2)
          .height(30)
          .backgroundColor('#FFD700')
          .opacity(0.6)
          .rotate({ angle: angle + (this.animationTime % 360) })
          .position({ x: '72%', y: '22%' })
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 多云动画 - 飘动的云朵
  @Builder
  CloudyAnimation() {
    Stack() {
      // 云朵1 - 大云朵
      Stack() {
        this.CloudShape(1.0)
      }
      .position({ 
        x: `${(this.animationTime * 0.5 % 120 - 10)}%`, 
        y: '10%' 
      })
      
      // 云朵2 - 中云朵
      Stack() {
        this.CloudShape(0.7)
      }
      .position({ 
        x: `${((this.animationTime * 0.3 + 40) % 120 - 10)}%`, 
        y: '35%' 
      })
      
      // 云朵3 - 小云朵
      Stack() {
        this.CloudShape(0.5)
      }
      .position({ 
        x: `${((this.animationTime * 0.4 + 80) % 120 - 10)}%`, 
        y: '55%' 
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 云朵形状 - 更自然的云朵外观
  @Builder
  CloudShape(scale: number) {
    Stack() {
      // 主体 - 最大的圆形
      Column()
        .width(50 * scale)
        .height(50 * scale)
        .backgroundColor('#FFFFFF')
        .borderRadius(25 * scale)
        .opacity(0.95)
        .shadow({
          radius: 10 * scale,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 5 * scale
        })
      
      // 左侧圆形
      Column()
        .width(40 * scale)
        .height(40 * scale)
        .backgroundColor('#FFFFFF')
        .borderRadius(20 * scale)
        .opacity(0.95)
        .position({ x: `${-15 * scale}%`, y: `${10 * scale}%` })
      
      // 右侧圆形
      Column()
        .width(45 * scale)
        .height(45 * scale)
        .backgroundColor('#FFFFFF')
        .borderRadius(22.5 * scale)
        .opacity(0.95)
        .position({ x: `${55 * scale}%`, y: `${5 * scale}%` })
      
      // 顶部小圆形
      Column()
        .width(35 * scale)
        .height(35 * scale)
        .backgroundColor('#FFFFFF')
        .borderRadius(17.5 * scale)
        .opacity(0.95)
        .position({ x: `${20 * scale}%`, y: `${-20 * scale}%` })
    }
    .width(100 * scale)
    .height(60 * scale)
  }
  
  // 下雨动画 - 雨滴下落
  @Builder
  RainAnimation() {
    Stack() {
      // 主要雨滴 - 垂直下落
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (index: number) => {
        Column()
          .width(2)
          .height(20)
          .backgroundColor('#ADD8E6')
          .opacity(0.7)
          .borderRadius(1)
          .rotate({ angle: 15 }) // 轻微倾斜，模拟风吹效果
          .position({ 
            x: `${(index * 8 + 2)}%`, 
            y: `${((this.animationTime * 5 + index * 25) % 120 - 20)}%` 
          })
      })
      
      // 细雨滴 - 更快下落
      ForEach([1, 2, 3, 4, 5, 6], (index: number) => {
        Column()
          .width(1)
          .height(15)
          .backgroundColor('#B0E0E6')
          .opacity(0.5)
          .rotate({ angle: 10 })
          .position({ 
            x: `${(index * 15 + 5)}%`, 
            y: `${((this.animationTime * 6 + index * 30) % 120 - 20)}%` 
          })
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 下雪动画 - 雪花飘落
  @Builder
  SnowAnimation() {
    Stack() {
      ForEach([1, 2, 3, 4, 5, 6, 7, 8], (index: number) => {
        Column()
          .width(6)
          .height(6)
          .backgroundColor('#FFFFFF')
          .borderRadius(3)
          .opacity(0.8)
          .position({ 
            x: `${(index * 12 + Math.sin(this.animationTime + index) * 5)}%`, 
            y: `${((this.animationTime * 2 + index * 15) % 100)}%` 
          })
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 阴天动画 - 灰暗效果
  @Builder
  OvercastAnimation() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#696969')
      .opacity(0.3)
  }
  
  // 雷阵雨动画 - 雨滴 + 闪电
  @Builder
  ThunderstormAnimation() {
    Stack() {
      // 1. 雨滴动画（复用下雨效果，但更密集）
      // 主要雨滴 - 垂直下落
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], (index: number) => {
        Column()
          .width(2.5)
          .height(25)
          .backgroundColor('#ADD8E6')
          .opacity(0.8)
          .borderRadius(1)
          .rotate({ angle: 20 }) // 更大倾斜角度，模拟大风
          .position({ 
            x: `${(index * 6.5 + 1)}%`, 
            y: `${((this.animationTime * 6 + index * 20) % 120 - 25)}%` 
          })
      })
      
      // 细雨滴 - 更快下落
      ForEach([1, 2, 3, 4, 5, 6, 7, 8], (index: number) => {
        Column()
          .width(1.5)
          .height(18)
          .backgroundColor('#B0E0E6')
          .opacity(0.6)
          .rotate({ angle: 15 })
          .position({ 
            x: `${(index * 12 + 3)}%`, 
            y: `${((this.animationTime * 7 + index * 25) % 120 - 25)}%` 
          })
      })
      
      // 2. 闪电效果
      if (this.lightningFlash) {
        // 闪电光芒 - 全屏闪光
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .opacity(0.4)
        
        // 闪电线条 - 主闪电
        Stack() {
          // 主闪电线条
          Column()
            .width(3)
            .height(200)
            .backgroundColor('#FFFF00')
            .opacity(0.9)
            .shadow({
              radius: 20,
              color: '#FFFF00',
              offsetX: 0,
              offsetY: 0
            })
            .position({ x: '45%', y: '5%' })
          
          // 分叉闪电 1
          Column()
            .width(2)
            .height(80)
            .backgroundColor('#FFFF00')
            .opacity(0.8)
            .rotate({ angle: -30 })
            .position({ x: '42%', y: '35%' })
          
          // 分叉闪电 2
          Column()
            .width(2)
            .height(60)
            .backgroundColor('#FFFF00')
            .opacity(0.8)
            .rotate({ angle: 25 })
            .position({ x: '48%', y: '40%' })
          
          // 细小分叉
          Column()
            .width(1.5)
            .height(40)
            .backgroundColor('#FFFF00')
            .opacity(0.7)
            .rotate({ angle: -45 })
            .position({ x: '40%', y: '55%' })
        }
        .width('100%')
        .height('100%')
      }
      
      // 3. 乌云效果
      Stack() {
        // 深色乌云 1
        this.DarkCloudShape(1.2)
      }
      .position({ 
        x: `${(this.animationTime * 0.3 % 100 - 5)}%`, 
        y: '5%' 
      })
      
      // 深色乌云 2
      Stack() {
        this.DarkCloudShape(0.9)
      }
      .position({ 
        x: `${((this.animationTime * 0.2 + 30) % 100 - 5)}%`, 
        y: '15%' 
      })
      
      // 深色乌云 3
      Stack() {
        this.DarkCloudShape(1.0)
      }
      .position({ 
        x: `${((this.animationTime * 0.25 + 60) % 100 - 5)}%`, 
        y: '8%' 
      })
    }
    .width('100%')
    .height('100%')
  }
  
  // 深色乌云形状（用于雷阵雨）
  @Builder
  DarkCloudShape(scale: number) {
    Stack() {
      // 主体 - 深灰色云朵
      Column()
        .width(60 * scale)
        .height(40 * scale)
        .backgroundColor('#2D3748')
        .borderRadius(20 * scale)
        .opacity(0.9)
        .shadow({
          radius: 15 * scale,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 8 * scale
        })
      
      // 左侧圆形
      Column()
        .width(45 * scale)
        .height(35 * scale)
        .backgroundColor('#2D3748')
        .borderRadius(17.5 * scale)
        .opacity(0.9)
        .position({ x: `${-20 * scale}%`, y: `${5 * scale}%` })
      
      // 右侧圆形
      Column()
        .width(50 * scale)
        .height(38 * scale)
        .backgroundColor('#2D3748')
        .borderRadius(19 * scale)
        .opacity(0.9)
        .position({ x: `${50 * scale}%`, y: `${3 * scale}%` })
      
      // 顶部圆形
      Column()
        .width(40 * scale)
        .height(32 * scale)
        .backgroundColor('#2D3748')
        .borderRadius(16 * scale)
        .opacity(0.9)
        .position({ x: `${15 * scale}%`, y: `${-15 * scale}%` })
    }
    .width(120 * scale)
    .height(70 * scale)
  }
}
