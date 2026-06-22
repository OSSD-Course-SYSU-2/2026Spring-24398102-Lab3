import router from '@ohos.router'
import { WeatherBackground } from '../components/WeatherBackground'
import { BreakpointType } from '../utils/BreakpointSystem'

@Entry
@Component
struct GameLevel3 {
  // 从上一页传递过来的天气类型和关卡
  @State weatherType: string = '晴天'
  @State level: number = 3 // 当前关卡
  
  // 游戏状态
  @State score: number = 0
  @State timeLeft: number = 60 // 第三关限时60秒
  @State targetScore: number = 8 // 第三关达标分数（8对）
  @State isGameOver: boolean = false
  @State isWin: boolean = false
  
  // 卡牌状态
  @State cards: Card[] = []
  @State flippedCards: number[] = [] // 当前翻开的卡牌索引（最多2张）
  @State matchedPairs: number = 0 // 已配对的数量
  
  // 定时器ID
  private gameTimer: number = -1
  private matchTimer: number = -1
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm'
  
  // 天气元素列表（每种元素有两张，8种共16张）
  private weatherElements: string[] = ['☀️', '💧', '☁️', '❄️', '⚡', '🌈', '🌪️', '🌙']
  
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
  
  // 初始化卡牌（打乱顺序，相同元素相邻概率降低，最多2对相邻）
  initCards() {
    this.cards = []
    
    // Fisher-Yates 洗牌函数
    const shuffle = (arr: string[]): string[] => {
      const result = [...arr]
      for (let i = result.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1))
        const temp = result[i]
        result[i] = result[j]
        result[j] = temp
      }
      return result
    }
    
    // 计算相邻相同的对数
    const countAdjacentPairs = (arr: string[]): number => {
      let count = 0
      for (let i = 0; i < arr.length - 1; i++) {
        if (arr[i] === arr[i + 1]) {
          count++
        }
      }
      return count
    }
    
    // 打乱元素顺序
    const shuffledElements = shuffle(this.weatherElements)
    
    // 创建两组元素
    const elements: string[] = []
    for (let i = 0; i < shuffledElements.length; i++) {
      elements.push(shuffledElements[i])
    }
    for (let i = 0; i < shuffledElements.length; i++) {
      elements.push(shuffledElements[i])
    }
    
    // 打乱所有元素
    let finalElements = shuffle(elements)
    let adjacentCount = countAdjacentPairs(finalElements)
    
    // 如果相邻对数超过2，进行修复
    let attempts = 0
    while (adjacentCount > 2 && attempts < 100) {
      // 找到相邻相同的位置并交换
      for (let i = 0; i < finalElements.length - 1; i++) {
        if (finalElements[i] === finalElements[i + 1]) {
          // 随机选择一个位置交换
          const swapIndex = Math.floor(Math.random() * finalElements.length)
          if (swapIndex !== i && swapIndex !== i + 1) {
            const temp = finalElements[i + 1]
            finalElements[i + 1] = finalElements[swapIndex]
            finalElements[swapIndex] = temp
            break
          }
        }
      }
      adjacentCount = countAdjacentPairs(finalElements)
      attempts++
    }
    
    // 如果相邻对数为0，有20%概率尝试制造1-2对相邻
    if (adjacentCount === 0 && Math.random() > 0.8) {
      // 尝试制造1-2对相邻
      const targetPairs = Math.random() < 0.5 ? 1 : 2
      attempts = 0
      while (adjacentCount < targetPairs && attempts < 50) {
        // 随机选择两个位置交换，尝试制造相邻
        const idx1 = Math.floor(Math.random() * (finalElements.length - 1))
        const idx2 = Math.floor(Math.random() * finalElements.length)
        if (idx2 !== idx1 && idx2 !== idx1 + 1) {
          const temp = finalElements[idx1 + 1]
          finalElements[idx1 + 1] = finalElements[idx2]
          finalElements[idx2] = temp
          adjacentCount = countAdjacentPairs(finalElements)
        }
        attempts++
      }
      // 如果制造了超过2对，再修复
      while (adjacentCount > 2 && attempts < 100) {
        for (let i = 0; i < finalElements.length - 1; i++) {
          if (finalElements[i] === finalElements[i + 1]) {
            const swapIndex = Math.floor(Math.random() * finalElements.length)
            if (swapIndex !== i && swapIndex !== i + 1) {
              const temp = finalElements[i + 1]
              finalElements[i + 1] = finalElements[swapIndex]
              finalElements[swapIndex] = temp
              break
            }
          }
        }
        adjacentCount = countAdjacentPairs(finalElements)
        attempts++
      }
    }
    
    for (let i = 0; i < 16; i++) {
      this.cards.push({
        index: i,
        isFlipped: false,
        isMatched: false,
        element: finalElements[i]
      })
    }
    
    console.info(`卡牌初始化完成，相邻对数: ${adjacentCount}`, finalElements.join(' '))
  }
  
  startGame() {
    this.score = 0
    this.timeLeft = 60
    this.isGameOver = false
    this.isWin = false
    this.flippedCards = []
    this.matchedPairs = 0
    
    // 游戏计时器
    this.gameTimer = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--
      } else {
        this.endGame()
      }
    }, 1000)
  }
  
  stopGame() {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
      this.gameTimer = -1
    }
    if (this.matchTimer !== -1) {
      clearTimeout(this.matchTimer)
      this.matchTimer = -1
    }
  }
  
  endGame() {
    this.isGameOver = true
    this.isWin = this.matchedPairs >= this.targetScore
    this.stopGame()
  }
  
  // 点击卡牌
  handleCardClick(index: number) {
    if (this.isGameOver || 
        this.cards[index].isFlipped || 
        this.cards[index].isMatched ||
        this.flippedCards.length >= 2) {
      return
    }
    
    // 翻开卡牌（创建新数组触发UI更新）
    const newCards: Card[] = []
    for (let i = 0; i < this.cards.length; i++) {
      if (i === index) {
        newCards.push({
          index: this.cards[i].index,
          isFlipped: true,
          isMatched: this.cards[i].isMatched,
          element: this.cards[i].element
        })
      } else {
        newCards.push({
          index: this.cards[i].index,
          isFlipped: this.cards[i].isFlipped,
          isMatched: this.cards[i].isMatched,
          element: this.cards[i].element
        })
      }
    }
    this.cards = newCards
    this.flippedCards.push(index)
    
    // 如果翻开了两张卡牌
    if (this.flippedCards.length === 2) {
      const firstIndex = this.flippedCards[0]
      const secondIndex = this.flippedCards[1]
      const firstCard = this.cards[firstIndex]
      const secondCard = this.cards[secondIndex]
      
      // 检查是否匹配
      if (firstCard.element === secondCard.element) {
        // 匹配成功
        this.score++
        this.matchedPairs++
        
        // 更新卡牌状态
        const matchedCards: Card[] = []
        for (let i = 0; i < this.cards.length; i++) {
          if (i === firstIndex || i === secondIndex) {
            matchedCards.push({
              index: this.cards[i].index,
              isFlipped: this.cards[i].isFlipped,
              isMatched: true,
              element: this.cards[i].element
            })
          } else {
            matchedCards.push({
              index: this.cards[i].index,
              isFlipped: this.cards[i].isFlipped,
              isMatched: this.cards[i].isMatched,
              element: this.cards[i].element
            })
          }
        }
        this.cards = matchedCards
        this.flippedCards = []
        // 配对成功加2秒
        this.timeLeft += 2
        
        // 检查是否全部配对完成
        if (this.matchedPairs === 8) {
          this.endGame()
        }
      } else {
        // 匹配失败，1秒后翻回去
        const cardsRef = this.cards
        const flippedRef = this.flippedCards
        this.matchTimer = setTimeout(() => {
          // 翻回去（创建新数组触发UI更新），并扣5秒
          const flipBackCards: Card[] = []
          for (let i = 0; i < cardsRef.length; i++) {
            if (i === flippedRef[0] || i === flippedRef[1]) {
              flipBackCards.push({
                index: cardsRef[i].index,
                isFlipped: false,
                isMatched: cardsRef[i].isMatched,
                element: cardsRef[i].element
              })
            } else {
              flipBackCards.push({
                index: cardsRef[i].index,
                isFlipped: cardsRef[i].isFlipped,
                isMatched: cardsRef[i].isMatched,
                element: cardsRef[i].element
              })
            }
          }
          this.cards = flipBackCards
          this.flippedCards = []
          // 扣减5秒，最低为0
          this.timeLeft = Math.max(0, this.timeLeft - 5)
        }, 1000)
      }
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
  
  // 根据断点获取自适应布局配置（4×4网格）
  private getLayoutConfig(): LayoutConfig {
    const configs: Record<string, LayoutConfig> = {
      'xs': { cardWidth: 48, cardHeight: 62, cardFontSize: 32, gridHeight: 300, stackHeight: 340 },
      'sm': { cardWidth: 72, cardHeight: 90, cardFontSize: 42, gridHeight: 450, stackHeight: 500 },
      'md': { cardWidth: 85, cardHeight: 105, cardFontSize: 48, gridHeight: 500, stackHeight: 560 },
      'lg': { cardWidth: 100, cardHeight: 120, cardFontSize: 54, gridHeight: 560, stackHeight: 620 },
      'xl': { cardWidth: 120, cardHeight: 140, cardFontSize: 60, gridHeight: 640, stackHeight: 700 }
    };
    return configs[this.currentBreakpoint] || configs['sm'];
  }

  build() {
    Stack() {
      Column() {
        // 顶部信息栏
        Row() {
          Text('记忆配对')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          Text(`时间: ${this.timeLeft}s`)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(`配对: ${this.matchedPairs}/${this.targetScore}`)
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
          
          // 4x4 卡牌网格
          Column() {
            ForEach([0, 1, 2, 3], (row: number) => {
              Row() {
                ForEach([0, 1, 2, 3], (col: number) => {
                  Column() {
                    if (this.cards[row * 4 + col].isFlipped || this.cards[row * 4 + col].isMatched) {
                      // 正面：显示天气元素
                      Text(this.cards[row * 4 + col].element)
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
                  .backgroundColor(
                    this.cards[row * 4 + col].isMatched ? '#90EE90' : 
                    this.cards[row * 4 + col].isFlipped ? '#FFFFFF' : '#DDDDDD'
                  )
                  .borderRadius(10)
                  .border({ width: 2, color: '#000000' })
                  .justifyContent(FlexAlign.Center)
                  .margin({ left: 3, right: 3, top: 4, bottom: 4 })
                  .onClick(() => {
                    this.handleCardClick(row * 4 + col)
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
        Text('翻开两张相同的天气元素卡牌进行配对')
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
          
          Text(`配对成功: ${this.matchedPairs}/${this.targetScore}`)
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
  isMatched: boolean
  element: string
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
