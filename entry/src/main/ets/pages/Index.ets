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
  
  aboutToAppear() {
    // 获取当前日期和明日日期
    this.getCurrentDate()
    this.getTomorrowDate()
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
  
  build() {
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
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f4f8')
  }
}
