import router from '@ohos.router'
import { WeatherBackground } from '../components/WeatherBackground'
import { BreakpointType } from '../utils/BreakpointSystem'
import { window } from '@kit.ArkUI'

@Entry
@Component
struct Game {
  // 从上一页传递过来的天气类型和关卡
  @State weatherType: string = '晴天'
  @State level: number = 1 // 当前关卡
  // 游戏状态
  @State score: number = 0
  @State timeLeft: number = 30
  @State targetScore: number = 30 // 第一关达标分数
  @State isGameOver: boolean = false
  @State isWin: boolean = false
  
  // 玩家位置
  @State playerX: number = 180
  private playerWidth: number = 40 // 进一步缩小判定范围
  
  // 掉落物列表
  @State fallingItems: FallingItem[] = []
  private itemSize: number = 40
  private itemSpeed: number = 3 // 降低速度，保证流畅
  private spawnInterval: number = 800 // 生成间隔
  
  // 定时器ID
  private gameTimer: number = -1
  private spawnTimer: number = -1
  private moveTimer: number = -1
  
  // 屏幕宽度
  private screenWidth: number = 360
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm'
  
  async aboutToAppear() {
    try {
      const params = router.getParams() as GameParams
      if (params && params.weatherType) {
        this.weatherType = params.weatherType
      }
      if (params && params.level) {
        this.level = params.level
      }
    } catch (e) {
      console.error('获取参数失败', e)
    }

    // 动态获取窗口宽度，适配不同设备
    try {
      const mainWindow = await window.getLastWindow(getContext(this))
      const windowProperties = mainWindow.getWindowProperties()
      const uiContext = mainWindow.getUIContext()
      const rawWidth: number = windowProperties.windowRect.width
      const widthVp: number = uiContext.px2vp(rawWidth)
      this.screenWidth = widthVp
      this.playerWidth = Math.max(30, widthVp * 0.11)
      this.itemSize = Math.max(30, widthVp * 0.11)
      this.itemSpeed = Math.max(2, widthVp * 0.008)
      this.playerX = widthVp / 2
    } catch (winErr) {
      console.error('获取窗口宽度失败，使用默认值', winErr)
    }
    
    this.startGame()
  }
  
  aboutToDisappear() {
    this.stopGame()
  }
  
  startGame() {
    this.score = 0
    this.timeLeft = 30
    this.isGameOver = false
    this.isWin = false
    this.fallingItems = []
    this.playerX = this.screenWidth / 2
    
    this.gameTimer = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--
      } else {
        this.endGame()
      }
    }, 1000)
    
    this.spawnTimer = setInterval(() => {
      if (!this.isGameOver) {
        this.spawnItem()
      }
    }, this.spawnInterval)
    
    this.moveTimer = setInterval(() => {
      if (!this.isGameOver) {
        this.moveItems()
      }
    }, 16) // 60fps，更流畅
  }
  
  stopGame() {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
      this.gameTimer = -1
    }
    if (this.spawnTimer !== -1) {
      clearInterval(this.spawnTimer)
      this.spawnTimer = -1
    }
    if (this.moveTimer !== -1) {
      clearInterval(this.moveTimer)
      this.moveTimer = -1
    }
  }
  
  endGame() {
    this.isGameOver = true
    this.isWin = this.score >= this.targetScore
    this.stopGame()
  }
  
  spawnItem() {
    const x = Math.random() * (this.screenWidth - this.itemSize)
    
    // 雷雨天同时下闪电和雨滴
    if (this.weatherType.includes('雷')) {
      // 随机决定是闪电还是雨滴
      const isThunder = Math.random() > 0.5
      const item: FallingItem = {
        x: x,
        y: 0,
        type: isThunder ? 'thunder' : 'rain'
      }
      this.fallingItems.push(item)
    } else {
      const item: FallingItem = {
        x: x,
        y: 0,
        type: this.getItemType()
      }
      this.fallingItems.push(item)
    }
  }
  
  moveItems() {
    const itemsToRemove: number[] = []
    
    for (let i = 0; i < this.fallingItems.length; i++) {
      const item = this.fallingItems[i]
      item.y += this.itemSpeed
      
      if (this.checkCollision(item)) {
        // 雷雨天碰到闪电扣分，碰到雨滴加分
        if (this.weatherType.includes('雷') && item.type === 'thunder') {
          this.score = Math.max(0, this.score - 1)
        } else {
          this.score++
        }
        itemsToRemove.push(i)
      }
      else if (item.y > 600) {
        itemsToRemove.push(i)
      }
    }
    
    for (let i = itemsToRemove.length - 1; i >= 0; i--) {
      this.fallingItems.splice(itemsToRemove[i], 1)
    }
  }
  
  checkCollision(item: FallingItem): boolean {
    const playerLeft = this.playerX - this.playerWidth / 2
    const playerRight = this.playerX + this.playerWidth / 2
    const playerTop = 520
    const playerBottom = 560
    
    const itemLeft = item.x
    const itemRight = item.x + this.itemSize
    const itemTop = item.y
    const itemBottom = item.y + this.itemSize
    
    return !(itemRight < playerLeft || 
             itemLeft > playerRight || 
             itemBottom < playerTop || 
             itemTop > playerBottom)
  }
  
  getItemType(): string {
    if (this.weatherType.includes('晴')) {
      return 'sun'
    } else if (this.weatherType.includes('雨')) {
      return 'rain'
    } else if (this.weatherType.includes('阴')) {
      return 'cloud'
    } else if (this.weatherType.includes('雪')) {
      return 'snow'
    } else if (this.weatherType.includes('雷')) {
      return 'thunder'
    } else {
      return 'cloud'
    }
  }
  
  getPlayerEmoji(): string {
    if (this.weatherType.includes('晴')) {
      return '🍃'
    } else if (this.weatherType.includes('雪')) {
      return '⛄'
    } else {
      return '☔'
    }
  }
  
  handleTouch(event: TouchEvent) {
    if (this.isGameOver) {
      return
    }
    
    const touchX = event.touches[0].x
    this.playerX = Math.max(
      this.playerWidth / 2,
      Math.min(this.screenWidth - this.playerWidth / 2, touchX)
    )
  }
  
  goBack() {
    router.back()
  }
  
  restart() {
    this.stopGame()
    this.startGame()
  }
  
  build() {
    Stack() {
      Column() {
        Row() {
          Text(`天气: ${this.weatherType}`)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(`时间: ${this.timeLeft}s`)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(`得分: ${this.score}/${this.targetScore}`)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(15)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.weatherType })
          
          // 掉落物
          ForEach(this.fallingItems, (item: FallingItem, index: number) => {
            Text(this.getItemEmoji(item.type))
              .fontSize(30)
              .position({ x: item.x, y: item.y })
          })
          
          // 玩家收集装置
          Row() {
            Text(this.getPlayerEmoji())
              .fontSize(40)
          }
          .position({ x: this.playerX - this.playerWidth / 2, y: 520 })
        }
        .width('100%')
        .height(580)
        .clip(true)
        .onTouch((event: TouchEvent) => {
          this.handleTouch(event)
        })
        
        // 退出按钮
        Button('退出游戏')
          .fontSize(16)
          .width('90%')
          .height(50)
          .backgroundColor('#ff6b6b')
          .margin({ top: 10 })
          .onClick(() => {
            this.goBack()
          })
      }
      .width('100%')
      .height('100%')
      
      // 游戏结束弹窗
      if (this.isGameOver) {
        Column() {
          Text(this.isWin ? '🎉 恭喜通关！' : '😢 时间到！')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isWin ? '#4CAF50' : '#f44336')
            .margin({ bottom: 20 })
          
          Text(`最终得分: ${this.score}/${this.targetScore}`)
            .fontSize(20)
            .fontColor('#333333')
            .margin({ bottom: 30 })
          
          Row() {
            Button('重新开始')
              .fontSize(16)
              .width(120)
              .height(50)
              .backgroundColor('#1a73e8')
              .onClick(() => {
                this.restart()
              })
            
            Blank()
            
            Button('返回')
              .fontSize(16)
              .width(120)
              .height(50)
              .backgroundColor('#ff6b6b')
              .onClick(() => {
                // 通关后返回天气页面
                if (this.isWin) {
                  const options: router.RouterOptions = {
                    url: 'pages/Index',
                    params: {
                      levelCompleted: this.level
                    }
                  }
                  router.replaceUrl(options)
                } else {
                  this.goBack()
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .width('85%')
        .padding(30)
        .backgroundColor('#ffffff')
        .borderRadius(20)
        .shadow({ radius: 20, color: '#000000', offsetX: 0, offsetY: 5 })
      }
    }
    .width('100%')
    .height('100%')
  }
  
  private getItemEmoji(type: string): string {
    switch (type) {
      case 'sun':
        return '☀️'
      case 'rain':
        return '💧'
      case 'cloud':
        return '☁️'
      case 'snow':
        return '❄️'
      case 'thunder':
        return '⚡'
      default:
        return '☁️'
    }
  }
}

interface FallingItem {
  x: number
  y: number
  type: string
}

interface GameParams {
  weatherType: string
  level?: number
}
