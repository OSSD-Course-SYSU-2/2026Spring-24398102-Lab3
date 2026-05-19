@Entry
@Component
struct Index {
  // 今日天气状态变量
  @State weather: string = '晴天'
  @State temperature: string = '25°C'
  @State humidity: string = '60%'
  @State currentDate: string = ''
  
  // 明日天气预测状态变量
  @State tomorrowWeather: string = '多云'
  @State tomorrowTemperature: string = '23°C'
  @State tomorrowHumidity: string = '65%'
  @State tomorrowDate: string = ''
  
  // 节气和黄历状态变量
  @State solarTerm: string = ''
  @State lunarDate: string = ''
  @State lunarYear: string = ''
  @State suitableActivities: string = ''
  @State avoidActivities: string = ''
  
  // 24节气名称
  private solarTerms: string[] = [
    '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
    '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
    '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
    '寒露', '霜降', '立冬', '小雪', '大雪', '冬至'
  ]
  
  // 节气对应的大约日期（月,日）
  private solarTermDates: number[][] = [
    [1, 5], [1, 20], [2, 3], [2, 18], [3, 5], [3, 20],
    [4, 4], [4, 19], [5, 5], [5, 20], [6, 5], [6, 21],
    [7, 7], [7, 22], [8, 7], [8, 22], [9, 7], [9, 22],
    [10, 8], [10, 23], [11, 7], [11, 22], [12, 7], [12, 21]
  ]
  
  // 农历月份名称
  private lunarMonths: string[] = [
    '正月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '冬月', '腊月'
  ]
  
  // 农历日期名称
  private lunarDays: string[] = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ]
  
  // 天干
  private tianGan: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
  // 地支
  private diZhi: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
  // 生肖
  private shengXiao: string[] = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪']
  
  aboutToAppear() {
    // 获取当前日期和明日日期
    this.getCurrentDate()
    this.getTomorrowDate()
    // 获取节气和黄历信息
    this.getSolarTerm()
    this.getLunarDate()
    this.getHuangLiInfo()
  }
  
  // 获取当前日期
  getCurrentDate() {
    const date = new Date()
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const weekDay = weekDays[date.getDay()]
    this.currentDate = `${year}年${month}月${day}日 ${weekDay}`
  }
  
  // 获取明日日期
  getTomorrowDate() {
    const date = new Date()
    date.setDate(date.getDate() + 1) // 加一天
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const weekDay = weekDays[date.getDay()]
    this.tomorrowDate = `${year}年${month}月${day}日 ${weekDay}`
  }
  
  // 获取当前节气
  getSolarTerm() {
    const date = new Date()
    const month = date.getMonth() + 1
    const day = date.getDate()
    
    let currentTerm = ''
    let minDiff = 365
    
    for (let i = 0; i < this.solarTermDates.length; i++) {
      const termMonth = this.solarTermDates[i][0]
      const termDay = this.solarTermDates[i][1]
      
      // 计算日期差值
      let diff = Math.abs((month - termMonth) * 31 + (day - termDay))
      
      if (diff < minDiff) {
        minDiff = diff
        currentTerm = this.solarTerms[i]
      }
    }
    
    this.solarTerm = currentTerm
  }
  
  // 简化的农历日期计算（使用查表法）
  getLunarDate() {
    const date = new Date()
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    
    // 计算农历年份
    const lunarYearIndex = (year - 4) % 10
    const lunarYearGan = this.tianGan[lunarYearIndex]
    const lunarYearZhiIndex = (year - 4) % 12
    const lunarYearZhi = this.diZhi[lunarYearZhiIndex]
    const shengXiaoName = this.shengXiao[lunarYearZhiIndex]
    
    this.lunarYear = `${lunarYearGan}${lunarYearZhi}年 ${shengXiaoName}年`
    
    // 简化的农历月日计算（实际应用中需要使用完整的农历算法）
    // 这里使用近似计算
    const lunarMonth = month - 1
    const lunarDay = day - 1
    
    if (lunarMonth >= 0 && lunarMonth < 12 && lunarDay >= 0 && lunarDay < 30) {
      this.lunarDate = `${this.lunarMonths[lunarMonth]}${this.lunarDays[lunarDay]}`
    } else {
      this.lunarDate = `${this.lunarMonths[Math.abs(lunarMonth % 12)]}${this.lunarDays[Math.abs(lunarDay % 30)]}`
    }
  }
  
  // 获取黄历宜忌信息（简化版）
  getHuangLiInfo() {
    const date = new Date()
    const dayOfWeek = date.getDay()
    const day = date.getDate()
    
    // 根据星期和日期生成宜忌（实际应用中应使用完整的黄历算法）
    const suitableList = [
      ['嫁娶', '出行', '移徙', '开市'],
      ['祭祀', '祈福', '求嗣', '开光'],
      ['纳采', '订盟', '解除', '纳畜'],
      ['修造', '动土', '破土', '安葬'],
      ['开市', '交易', '立券', '纳财'],
      ['嫁娶', '纳采', '出行', '移徙'],
      ['祭祀', '祈福', '斋醮', '修造']
    ]
    
    const avoidList = [
      ['安葬', '破土', '作灶'],
      ['开市', '入宅', '嫁娶'],
      ['嫁娶', '作灶', '安床'],
      ['开市', '交易', '纳畜'],
      ['嫁娶', '安葬', '出行'],
      ['祈福', '斋醮', '开光'],
      ['动土', '破土', '嫁娶']
    ]
    
    this.suitableActivities = suitableList[dayOfWeek].join(' ')
    this.avoidActivities = avoidList[dayOfWeek].join(' ')
  }
  
  build() {
    Scroll() {
      Column() {
        // 标题
        Text('今日天气')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a73e8')
          .margin({ top: 40, bottom: 30 })
      
      // 日期卡片
      Column() {
        Text('日期')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 8 })
        
        Text(this.currentDate)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#f5f5f5')
      .borderRadius(12)
      .margin({ bottom: 20 })
      
      // 节气和黄历卡片
      Column() {
        Text('节气黄历')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#9c27b0')
          .margin({ bottom: 15 })
        
        // 节气
        Row() {
          Text('节气')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.solarTerm)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#9c27b0')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 农历年
        Row() {
          Text('农历年')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.lunarYear)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ff5722')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 农历日期
        Row() {
          Text('农历')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.lunarDate)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e91e63')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 宜
        Row() {
          Text('宜')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.suitableActivities)
            .fontSize(14)
            .fontColor('#4caf50')
            .maxLines(2)
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 忌
        Row() {
          Text('忌')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.avoidActivities)
            .fontSize(14)
            .fontColor('#f44336')
            .maxLines(2)
        }
        .width('100%')
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#f3e5f5')
      .borderRadius(12)
      .shadow({ 
        radius: 8, 
        color: '#e0e0e0', 
        offsetX: 0, 
        offsetY: 2 
      })
      .margin({ bottom: 20 })
      
      // 今日天气信息卡片
      Column() {
        Text('今日天气')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a73e8')
          .margin({ bottom: 15 })
        
        // 天气状态
        Row() {
          Text('天气状况')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.weather)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 温度
        Row() {
          Text('温度')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.temperature)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ff6b6b')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 湿度
        Row() {
          Text('湿度')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.humidity)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4ecdc4')
        }
        .width('100%')
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({ 
        radius: 8, 
        color: '#e0e0e0', 
        offsetX: 0, 
        offsetY: 2 
      })
      .margin({ bottom: 20 })
      
      // 明日天气预测卡片
      Column() {
        Text('明日天气预测')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff9800')
          .margin({ bottom: 15 })
        
        // 明日日期
        Row() {
          Text('日期')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.tomorrowDate)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 明日天气状态
        Row() {
          Text('天气状况')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.tomorrowWeather)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 明日温度
        Row() {
          Text('温度')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.tomorrowTemperature)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ff6b6b')
        }
        .width('100%')
        .margin({ bottom: 15 })
        
        // 明日湿度
        Row() {
          Text('湿度')
            .fontSize(16)
            .fontColor('#666666')
          
          Blank()
          
          Text(this.tomorrowHumidity)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4ecdc4')
        }
        .width('100%')
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#fff8e1')
      .borderRadius(12)
      .shadow({ 
        radius: 8, 
        color: '#e0e0e0', 
        offsetX: 0, 
        offsetY: 2 
      })
      
      // 刷新按钮
      Button('刷新天气')
        .fontSize(18)
        .fontColor('#ffffff')
        .backgroundColor('#1a73e8')
        .borderRadius(25)
        .width('60%')
        .height(50)
        .margin({ top: 40 })
        .onClick(() => {
          // 这里可以添加获取实时天气的逻辑
          // 目前使用模拟数据
          this.getCurrentDate()
          this.getTomorrowDate()
          this.getSolarTerm()
          this.getLunarDate()
          this.getHuangLiInfo()
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f4f8')
    .scrollBar(BarState.Auto)
    .scrollBarColor('#1a73e8')
    .scrollBarWidth(4)
    .edgeEffect(EdgeEffect.Spring)
  }
}
