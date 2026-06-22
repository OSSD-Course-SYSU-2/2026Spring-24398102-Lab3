import router from '@ohos.router'
import { WeatherBackground } from '../components/WeatherBackground'
import { BreakpointType } from '../utils/BreakpointSystem'

@Entry
@Component
struct GameLevel2 {
  // 从上一页传递过来的天气类型和关卡
  @State weatherType: string = '晴天'
  @State level: number = 2 // 当前关卡
  
  // 游戏状态
  @State score: number = 0
  @State timeLeft: number = 45 // 第二关限时45秒
  @State targetScore: number = 10 // 第二关达标分数
  @State isGameOver: boolean = false
  @State isWin: boolean = false
  @State targetAppearCount: number = 0 // 目标元素已出现次数
  @State cycleTargetCount: number = 0 // 当前9秒周期内目标元素出现次数
  
  // 卡牌状态
  @State cards: Card[] = []
  @State currentFlippedCard: number = -1 // 当前翻开的卡牌索引
  @State targetElement: string = '' // 要求点击的元素
  @State isCardClickable: boolean = false // 卡牌是否可点击
  
  // 定时器ID
  private gameTimer: number = -1
  private flipTimer: number = -1
  private spawnTimer: number = -1
  private cycleTimer: number = -1 // 9秒周期定时器
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm'
  
  // 天气元素列表
  private weatherElements: string[] = ['☀️', '💧', '☁️', '❄️', '⚡']
  private elementNames: string[] = ['太阳', '雨滴', '云朵', '雪花', '闪电']
  
  aboutToAppear() {
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
    
    this.initCards()
    this.startGame()
  }
  
  aboutToDisappear() {
    this.stopGame()
  }
  
  // 初始化卡牌
  initCards() {
    this.cards = []
    for (let i = 0; i < 12; i++) {
      this.cards.push({
        index: i,
        isFlipped: false,
        element: '',
        elementName: ''
      })
    }
  }
  
  startGame() {
    this.score = 0
    this.timeLeft = 45
    this.isGameOver = false
    this.isWin = false
    this.currentFlippedCard = -1
    this.isCardClickable = false
    this.targetAppearCount = 0
    this.cycleTargetCount = 0
    
    // 随机选择目标元素（全程不变）
    this.selectNewTarget()
    
    // 游戏计时器
    this.gameTimer = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--
      } else {
        this.endGame()
      }
    }, 1000)
    
    // 9秒周期定时器，重置周期内目标元素计数
    this.cycleTimer = setInterval(() => {
      console.info(`9秒周期结束，本周期目标元素出现: ${this.cycleTargetCount} 次`)
      this.cycleTargetCount = 0
    }, 9000)
    
    // 定时翻开卡牌
    this.spawnTimer = setInterval(() => {
      if (!this.isGameOver && this.currentFlippedCard === -1) {
        this.flipRandomCard()
      }
    }, 1500) // 每1.5秒翻开一张新卡牌
  }
  
  stopGame() {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
      this.gameTimer = -1
    }
    if (this.flipTimer !== -1) {
      clearTimeout(this.flipTimer)
      this.flipTimer = -1
    }
    if (this.spawnTimer !== -1) {
      clearInterval(this.spawnTimer)
      this.spawnTimer = -1
    }
    if (this.cycleTimer !== -1) {
      clearInterval(this.cycleTimer)
      this.cycleTimer = -1
    }
  }
  
  endGame() {
    this.isGameOver = true
    this.isWin = this.score >= this.targetScore
    this.stopGame()
  }
  
  // 选择新的目标元素
  selectNewTarget() {
    const randomIndex = Math.floor(Math.random() * this.weatherElements.length)
    this.targetElement = this.weatherElements[randomIndex]
  }
  
  // 随机翻开一张卡牌
  flipRandomCard() {
    console.info('flipRandomCard 被调用')
    // 找到所有未翻开的卡牌
    const availableCards: number[] = []
    for (let i = 0; i < this.cards.length; i++) {
      if (!this.cards[i].isFlipped) {
        availableCards.push(i)
      }
    }
    
    if (availableCards.length === 0) {
      // 所有卡牌都翻开过了，重置所有卡牌
      for (let i = 0; i < this.cards.length; i++) {
        this.cards[i] = {
          index: this.cards[i].index,
          isFlipped: false,
          element: this.cards[i].element,
          elementName: this.cards[i].elementName
        }
      }
      // 重新收集可用卡牌
      for (let i = 0; i < this.cards.length; i++) {
        availableCards.push(i)
      }
    }
    
    // 随机选择一张卡牌
    const randomCardIndex = availableCards[Math.floor(Math.random() * availableCards.length)]
    
    // 智能分配天气元素，确保每9秒至少出现2次目标元素
    // 每9秒翻开 9/1.5 = 6 张卡牌
    const cycleFlips = 6 // 每个周期最多翻开的卡牌数
    const minTargetPerCycle = 2 // 每个周期最少出现的目标元素次数
    const remainingInCycle = cycleFlips - (this.cycleTargetCount + (cycleFlips - Math.floor((this.timeLeft % 9) / 1.5)))
    
    let selectedElementIndex: number
    let isTarget = false
    
    // 如果当前周期内目标元素出现次数不足，且剩余翻牌机会有限，强制翻开目标元素
    if (this.cycleTargetCount < minTargetPerCycle) {
      // 计算当前周期内还能翻开多少张卡牌
      const timeInCycle = this.timeLeft % 9 // 当前周期内剩余时间
      const flipsLeftInCycle = Math.ceil(timeInCycle / 1.5) // 当前周期内还能翻开的卡牌数
      
      // 如果剩余翻牌数 <= 还需要的目标元素次数，必须翻开目标元素
      const targetNeeded = minTargetPerCycle - this.cycleTargetCount
      if (flipsLeftInCycle <= targetNeeded) {
        // 必须翻开目标元素
        selectedElementIndex = this.weatherElements.indexOf(this.targetElement)
        isTarget = true
        console.info(`周期内强制翻开目标元素，周期内已出现: ${this.cycleTargetCount}，剩余翻牌: ${flipsLeftInCycle}`)
      } else if (Math.random() < 0.4) {
        // 40% 概率翻开目标元素
        selectedElementIndex = this.weatherElements.indexOf(this.targetElement)
        isTarget = true
      } else {
        // 随机选择元素
        selectedElementIndex = Math.floor(Math.random() * this.weatherElements.length)
        isTarget = this.weatherElements[selectedElementIndex] === this.targetElement
      }
    } else {
      // 当前周期已满足要求，随机选择
      if (Math.random() < 0.3) {
        // 30% 概率翻开目标元素
        selectedElementIndex = this.weatherElements.indexOf(this.targetElement)
        isTarget = true
      } else {
        selectedElementIndex = Math.floor(Math.random() * this.weatherElements.length)
        isTarget = this.weatherElements[selectedElementIndex] === this.targetElement
      }
    }
    
    // 更新计数器
    if (isTarget) {
      this.targetAppearCount++
      this.cycleTargetCount++
    }
    
    // 创建新数组并修改（触发UI更新）
    const newCards: Card[] = []
    for (let i = 0; i < this.cards.length; i++) {
      if (i === randomCardIndex) {
        newCards.push({
          index: i,
          isFlipped: true,
          element: this.weatherElements[selectedElementIndex],
          elementName: this.elementNames[selectedElementIndex]
        })
      } else {
        newCards.push({
          index: this.cards[i].index,
          isFlipped: this.cards[i].isFlipped,
          element: this.cards[i].element,
          elementName: this.cards[i].elementName
        })
      }
    }
    this.cards = newCards
    
    this.currentFlippedCard = randomCardIndex
    this.isCardClickable = true
    console.info(`翻开卡牌 ${randomCardIndex}，元素: ${this.weatherElements[selectedElementIndex]}，周期内目标: ${this.cycleTargetCount}，总目标: ${this.targetAppearCount}`)
    
    // 2秒后翻回去
    const flippedIndex = randomCardIndex
    this.flipTimer = setTimeout(() => {
      if (this.currentFlippedCard !== -1) {
        const newCards2: Card[] = []
        for (let i = 0; i < this.cards.length; i++) {
          if (i === flippedIndex) {
            newCards2.push({
              index: this.cards[i].index,
              isFlipped: false,
              element: this.cards[i].element,
              elementName: this.cards[i].elementName
            })
          } else {
            newCards2.push({
              index: this.cards[i].index,
              isFlipped: this.cards[i].isFlipped,
              element: this.cards[i].element,
              elementName: this.cards[i].elementName
            })
          }
        }
        this.cards = newCards2
        this.currentFlippedCard = -1
        this.isCardClickable = false
        console.info('卡牌自动翻回')
      }
    }, 2000)
  }
  
  // 点击卡牌
  handleCardClick(index: number) {
    if (this.isGameOver || !this.isCardClickable || index !== this.currentFlippedCard) {
      return
    }
    
    // 检查是否是目标元素
    if (this.cards[index].element === this.targetElement) {
      this.score++
      // 目标元素全程不变，不选择新目标
    } else {
      this.score = Math.max(0, this.score - 1)
    }
    
    // 翻回去（创建新数组触发UI更新）
    const newCards: Card[] = []
    for (let i = 0; i < this.cards.length; i++) {
      if (i === index) {
        newCards.push({
          index: this.cards[i].index,
          isFlipped: false,
          element: this.cards[i].element,
          elementName: this.cards[i].elementName
        })
      } else {
        newCards.push({
          index: this.cards[i].index,
          isFlipped: this.cards[i].isFlipped,
          element: this.cards[i].element,
          elementName: this.cards[i].elementName
        })
      }
    }
    this.cards = newCards
    this.currentFlippedCard = -1
    this.isCardClickable = false
    
    // 清除翻牌定时器
    if (this.flipTimer !== -1) {
      clearTimeout(this.flipTimer)
      this.flipTimer = -1
    }
    
    // 达到目标分数立即结算
    if (this.score >= this.targetScore) {
      this.endGame()
    }
  }
  
  goBack() {
    router.back()
  }
  
  restart() {
    this.stopGame()
    this.initCards()
    this.startGame()
  }
  
  // 根据断点获取自适应布局配置
  private getLayoutConfig(): LayoutConfig {
    const configs: Record<string, LayoutConfig> = {
      'xs': { cardWidth: 55, cardHeight: 70, cardFontSize: 30, gridHeight: 320, stackHeight: 360 },
      'sm': { cardWidth: 70, cardHeight: 90, cardFontSize: 40, gridHeight: 450, stackHeight: 500 },
      'md': { cardWidth: 90, cardHeight: 110, cardFontSize: 48, gridHeight: 520, stackHeight: 580 },
      'lg': { cardWidth: 110, cardHeight: 130, cardFontSize: 54, gridHeight: 600, stackHeight: 660 },
      'xl': { cardWidth: 130, cardHeight: 150, cardFontSize: 60, gridHeight: 700, stackHeight: 760 }
    };
    return configs[this.currentBreakpoint] || configs['sm'];
  }

  build() {
    Stack() {
      Column() {
        // 顶部信息栏
        Row() {
          Text(`目标: ${this.targetElement}`)
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
          
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
        
        // 卡牌区域
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.weatherType })
          
          // 4x3 卡牌网格
          Column() {
            ForEach([0, 1, 2, 3], (row: number) => {
              Row() {
                ForEach([0, 1, 2], (col: number) => {
                  Column() {
                    if (this.cards[row * 3 + col].isFlipped) {
                      // 正面：显示天气元素
                      Text(this.cards[row * 3 + col].element)
                        .fontSize(this.getLayoutConfig().cardFontSize)
                    } else {
                      // 背面：显示问号
                      Text('?')
                        .fontSize(this.getLayoutConfig().cardFontSize)
                        .fontColor('#000000')
                        .fontWeight(FontWeight.Bold)
                    }
                  }
                  .width(this.getLayoutConfig().cardWidth)
                  .height(this.getLayoutConfig().cardHeight)
                  .backgroundColor(this.cards[row * 3 + col].isFlipped ? '#FFFFFF' : '#DDDDDD')
                  .borderRadius(10)
                  .border({ width: 2, color: '#000000' })
                  .justifyContent(FlexAlign.Center)
                  .margin({ left: 5, right: 5, top: 5, bottom: 5 })
                  .onClick(() => {
                    this.handleCardClick(row * 3 + col)
                  })
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('100%')
          .height(this.getLayoutConfig().gridHeight)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(this.getLayoutConfig().stackHeight)
        .clip(true)
        
        // 提示文字
        Text('点击匹配的天气元素')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .margin({ top: 10 })
        
        // 退出按钮
        Button('退出游戏')
          .fontSize(17)
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
}

interface Card {
  index: number
  isFlipped: boolean
  element: string
  elementName: string
}

interface GameParams {
  weatherType: string
  level?: number
}

interface LayoutConfig {
  cardWidth: number;
  cardHeight: number;
  cardFontSize: number;
  gridHeight: number;
  stackHeight: number;
}
