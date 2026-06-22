import { WeatherBackground } from '../components/WeatherBackground'
import router from '@ohos.router'
import { WeatherService } from '../services/WeatherService'
import { DistributedDataManager, GameProgress, WeatherData } from '../utils/DistributedDataManager'
import { BreakpointType, BreakpointValue } from '../utils/BreakpointSystem'

@Entry
@Component
struct Index {
  // 今日天气状态变量
  @State weather: string = '小雨'
  @State temperature: string = '33°C'
  @State humidity: string = '85%'
  @State windDirection: string = '东南风'  // 风向
  @State windSpeed: string = '3级'        // 风速
  @State airQuality: string = '良'        // 空气指数
  @State currentDate: string = ''
  
  // 明日天气预测状态变量
  @State tomorrowWeather: string = '多云'
  @State tomorrowTemperature: string = '23°C'
  @State tomorrowHumidity: string = '65%'
  @State tomorrowWindDirection: string = '东风'
  @State tomorrowWindSpeed: string = '2级'
  @State tomorrowAirQuality: string = '优'
  @State tomorrowDate: string = ''
  
  // 后天天气预测状态变量
  @State dayAfterTomorrowWeather: string = '小雨'
  @State dayAfterTomorrowTemperature: string = '20°C'
  @State dayAfterTomorrowHumidity: string = '75%'
  @State dayAfterTomorrowWindDirection: string = '北风'
  @State dayAfterTomorrowWindSpeed: string = '4级'
  @State dayAfterTomorrowAirQuality: string = '良'
  @State dayAfterTomorrowDate: string = ''
  
  // 大后天天气预测状态变量
  @State threeDaysLaterWeather: string = '阴天'
  @State threeDaysLaterTemperature: string = '22°C'
  @State threeDaysLaterHumidity: string = '70%'
  @State threeDaysLaterWindDirection: string = '西风'
  @State threeDaysLaterWindSpeed: string = '3级'
  @State threeDaysLaterAirQuality: string = '良'
  @State threeDaysLaterDate: string = ''
  
  // 节气和黄历状态变量
  @State solarTerm: string = ''
  @State lunarDate: string = ''
  @State lunarYear: string = ''
  @State suitableActivities: string = ''
  @State avoidActivities: string = ''
  
  // 随机名言状态变量
  @State quote: string = ''
  @State quoteAuthor: string = ''
  
  // 搜索相关状态变量
  @State searchCity: string = ''
  @State currentCity: string = '广州'
  @State searchError: string = ''
  
  // 游戏关卡状态变量
  @State currentLevel: number = 1 // 当前关卡（1-3）
  @State completedLevels: number = 0 // 已通关关卡数（0-3）
  @State lastUpdateDate: string = '' // 上次更新日期
  @State showLevelSelect: boolean = false // 显示关卡选择对话框
  private distributedDataManager: DistributedDataManager = DistributedDataManager.getInstance()
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointType = 'sm'
  
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
  
  // 名言集合
  private quotes: string[][] = [
    ['生活不是等待暴风雨过去，而是学会在雨中翩翩起舞。', '《阿甘正传》'],
    ['每一个不曾起舞的日子，都是对生命的辜负。', '尼采'],
    ['人生就像骑自行车，要保持平衡就得不断前进。', '爱因斯坦'],
    ['不要因为走得太远，而忘记为什么出发。', '纪伯伦'],
    ['生命中最美好的事情都是免费的，第二美好的事情都很贵。', '《疯狂动物城》'],
    ['成功不是终点，失败也不是终结，唯有勇气才是永恒。', '丘吉尔'],
    ['人生最大的荣耀不在于从不跌倒，而在于每次跌倒后都能爬起来。', '孔子'],
    ['时间会刺破青春的华美精致，会把平行线刻上美人的额角。', '莎士比亚'],
    ['生活是一面镜子，你笑它也笑，你哭它也哭。', '萨克雷'],
    ['人生没有彩排，每一天都是现场直播。', '《楚门的世界》'],
    ['世界上只有一种真正的英雄主义，那就是认清生活的真相后依然热爱生活。', '罗曼·罗兰'],
    ['不要试图去做一个成功的人，而要努力成为一个有价值的人。', '爱因斯坦'],
    ['人生就像一杯茶，不会苦一辈子，但总会苦一阵子。', '林清玄'],
    ['真正的智慧不在于知道所有答案，而在于知道去哪里寻找答案。', '苏格拉底'],
    ['生活中最重要的事情不是你身处何处，而是你朝着什么方向走。', '霍姆斯']
  ]
  
  // 城市列表（各省省会和第二重要城市）
  private cityList: Map<string, string[]> = new Map([
    // 直辖市
    ['北京', ['晴天', '26°C', '45%', '北风', '3级', '良']],
    ['上海', ['多云', '28°C', '70%', '东风', '2级', '良']],
    ['天津', ['晴天', '27°C', '55%', '西南风', '3级', '良']],
    ['重庆', ['阴天', '30°C', '75%', '南风', '2级', '中']],
    
    // 省会城市
    ['哈尔滨', ['多云', '22°C', '65%', '西北风', '4级', '良']],
    ['长春', ['晴天', '23°C', '60%', '西风', '3级', '良']],
    ['沈阳', ['多云', '24°C', '60%', '北风', '3级', '良']],
    ['石家庄', ['晴天', '25°C', '40%', '南风', '2级', '良']],
    ['太原', ['多云', '22°C', '50%', '东风', '2级', '良']],
    ['呼和浩特', ['晴天', '18°C', '35%', '西北风', '4级', '优']],
    ['济南', ['晴天', '28°C', '45%', '东南风', '3级', '良']],
    ['南京', ['多云', '27°C', '65%', '东风', '2级', '良']],
    ['合肥', ['小雨', '24°C', '80%', '南风', '2级', '良']],
    ['杭州', ['多云', '29°C', '70%', '东南风', '2级', '良']],
    ['福州', ['晴天', '32°C', '60%', '东风', '3级', '良']],
    ['南昌', ['晴天', '31°C', '55%', '南风', '2级', '良']],
    ['郑州', ['晴天', '29°C', '45%', '东风', '2级', '良']],
    ['武汉', ['多云', '30°C', '70%', '西南风', '2级', '中']],
    ['长沙', ['晴天', '32°C', '65%', '南风', '2级', '良']],
    ['广州', ['小雨', '33°C', '85%', '东南风', '3级', '良']],
    ['南宁', ['多云', '31°C', '75%', '南风', '2级', '良']],
    ['海口', ['晴天', '34°C', '80%', '东风', '3级', '优']],
    ['成都', ['阴天', '26°C', '75%', '北风', '2级', '中']],
    ['贵阳', ['小雨', '22°C', '85%', '东风', '2级', '良']],
    ['昆明', ['晴天', '24°C', '60%', '西南风', '3级', '优']],
    ['拉萨', ['晴天', '15°C', '30%', '西风', '4级', '优']],
    ['西安', ['多云', '28°C', '50%', '东风', '2级', '中']],
    ['兰州', ['晴天', '22°C', '40%', '西北风', '3级', '良']],
    ['西宁', ['多云', '16°C', '50%', '西风', '3级', '优']],
    ['银川', ['晴天', '24°C', '35%', '北风', '3级', '良']],
    ['乌鲁木齐', ['晴天', '25°C', '40%', '西北风', '4级', '良']],
    
    // 各省第二重要城市
    ['大连', ['晴天', '5°C', '55%', '北风', '4级', '优']],
    ['青岛', ['晴天', '26°C', '60%', '东南风', '3级', '良']],
    ['宁波', ['多云', '28°C', '70%', '东风', '3级', '良']],
    ['厦门', ['晴天', '31°C', '75%', '东南风', '3级', '良']],
    ['深圳', ['多云', '33°C', '80%', '东风', '3级', '良']],
    ['苏州', ['多云', '28°C', '65%', '东风', '2级', '良']],
    ['无锡', ['晴天', '27°C', '60%', '东南风', '2级', '良']],
    ['东莞', ['小雨', '32°C', '85%', '南风', '2级', '中']],
    ['佛山', ['多云', '33°C', '75%', '东南风', '2级', '良']],
    ['烟台', ['晴天', '25°C', '55%', '北风', '3级', '优']],
    ['温州', ['多云', '29°C', '70%', '东风', '2级', '良']],
    ['泉州', ['晴天', '30°C', '65%', '东南风', '3级', '良']],
    ['唐山', ['晴天', '26°C', '50%', '西北风', '3级', '良']],
    ['保定', ['多云', '24°C', '55%', '南风', '2级', '良']],
    ['包头', ['晴天', '20°C', '40%', '西北风', '4级', '良']],
    ['鄂尔多斯', ['晴天', '18°C', '35%', '西风', '4级', '优']],
    ['洛阳', ['晴天', '27°C', '45%', '东风', '2级', '良']],
    ['开封', ['多云', '26°C', '50%', '南风', '2级', '良']],
    ['大同', ['多云', '20°C', '45%', '西风', '3级', '良']],
    ['桂林', ['小雨', '25°C', '80%', '北风', '2级', '良']],
    ['三亚', ['晴天', '35°C', '75%', '东南风', '3级', '优']],
    ['绵阳', ['阴天', '25°C', '70%', '北风', '2级', '良']],
    ['遵义', ['小雨', '20°C', '85%', '东风', '2级', '良']],
    ['大理', ['晴天', '22°C', '55%', '西南风', '3级', '优']],
    ['咸阳', ['多云', '27°C', '50%', '东风', '2级', '中']],
    ['宝鸡', ['晴天', '25°C', '45%', '西北风', '2级', '良']],
    ['天水', ['多云', '20°C', '55%', '西风', '2级', '良']],
    ['酒泉', ['晴天', '15°C', '30%', '西北风', '5级', '优']],
    ['克拉玛依', ['晴天', '28°C', '35%', '西北风', '5级', '良']]
  ])
  
  async aboutToAppear() {
    // 加载分布式持久化的关卡数据（支持跨设备同步）
    await this.loadGameData()

    // 尝试从分布式存储恢复上次的城市
    try {
      const savedCity = await this.distributedDataManager.getCurrentCity()
      if (savedCity && savedCity.length > 0) {
        this.currentCity = savedCity
        AppStorage.setOrCreate('currentCity', savedCity)
      }
    } catch (e) {
      console.error('恢复城市失败', e)
    }
    
    // 检查是否有关卡完成
    try {
      const params = router.getParams() as Record<string, number>
      if (params && params['levelCompleted']) {
        console.info(`通关数据: levelCompleted=${params['levelCompleted']}, 当前completedLevels=${this.completedLevels}`)
        // 更新已通关关卡数
        if (params['levelCompleted'] > this.completedLevels) {
          this.completedLevels = params['levelCompleted']
          // 如果还有下一关，设置当前关卡为下一关
          if (this.completedLevels < 3) {
            this.currentLevel = this.completedLevels + 1
          }
          // 保存到持久化存储
          await this.saveGameData()
          console.info(`更新后: completedLevels=${this.completedLevels}, currentLevel=${this.currentLevel}`)
        }
      }
    } catch (e) {
      console.error('获取参数失败', e)
    }
    
    // 获取当前日期和明日日期
    this.getCurrentDate()
    this.getTomorrowDate()
    this.getDayAfterTomorrowDate()
    this.getThreeDaysLaterDate()
    // 获取节气和黄历信息
    this.getSolarTerm()
    this.getLunarDate()
    this.getHuangLiInfo()
    // 获取随机名言
    this.getRandomQuote()
    // 初始化未来天气预测
    // 尝试从和风天气API获取真实数据
    this.loadWeatherData(this.currentCity)
  }
  
  // 加载游戏数据（使用分布式数据管理器，支持跨设备同步）
  async loadGameData() {
    try {
      // 等待分布式数据管理器初始化完成，避免读取时 kvStore 为空导致数据丢失
      await this.distributedDataManager.waitForReady()
      const progress = await this.distributedDataManager.getGameProgress()
      const today = this.getTodayDateString()
      this.lastUpdateDate = progress?.lastUpdateDate || ''

      // 如果是新的一天，重置进度
      if (!progress || progress.lastUpdateDate !== today) {
        console.info('新的一天，重置游戏进度')
        this.completedLevels = 0
        this.currentLevel = 1
        this.lastUpdateDate = today
        await this.saveGameData()
      } else {
        // 同一天，加载保存的进度
        this.completedLevels = progress.completedLevels
        this.currentLevel = progress.currentLevel
      }
    } catch (e) {
      console.error('加载游戏数据失败', e)
    }
  }

  // 保存游戏数据（使用分布式数据管理器，支持跨设备同步）
  async saveGameData() {
    try {
      const progress: GameProgress = {
        currentLevel: this.currentLevel,
        completedLevels: this.completedLevels,
        lastUpdateDate: this.lastUpdateDate,
        totalStars: this.completedLevels
      }
      await this.distributedDataManager.saveGameProgress(progress)
    } catch (e) {
      console.error('保存游戏数据失败', e)
    }
  }

  // 获取今天的日期字符串（YYYY-MM-DD格式）
  getTodayDateString(): string {
    const date = new Date()
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${year}-${month}-${day}`
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
  
  // 获取后天日期
  getDayAfterTomorrowDate() {
    const date = new Date()
    date.setDate(date.getDate() + 2) // 加两天
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const weekDay = weekDays[date.getDay()]
    this.dayAfterTomorrowDate = `${year}年${month}月${day}日 ${weekDay}`
  }
  
  // 获取大后天日期
  getThreeDaysLaterDate() {
    const date = new Date()
    date.setDate(date.getDate() + 3) // 加三天
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const weekDays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const weekDay = weekDays[date.getDay()]
    this.threeDaysLaterDate = `${year}年${month}月${day}日 ${weekDay}`
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
  
  // 获取随机名言
  getRandomQuote() {
    const randomIndex = Math.floor(Math.random() * this.quotes.length)
    this.quote = this.quotes[randomIndex][0]
    this.quoteAuthor = this.quotes[randomIndex][1]
  }

  // 保存天气数据到分布式存储，支持跨设备同步
  saveWeatherToDistributed() {
    try {
      const weatherData: WeatherData = {
        city: this.currentCity,
        weather: this.weather,
        temperature: this.temperature,
        humidity: this.humidity,
        windDirection: this.windDirection,
        windSpeed: this.windSpeed,
        airQuality: this.airQuality,
        lastUpdate: Date.now()
      }
      this.distributedDataManager.saveWeatherData(weatherData)
    } catch (e) {
      console.error('保存天气数据到分布式存储失败', e)
    }
  }

  // 响应式：根据断点获取内容区宽度
  getContentWidth(): string {
    switch (this.currentBreakpoint) {
      case 'xs':
        return '95%'
      case 'sm':
        return '85%'
      case 'md':
        return '65%'
      case 'lg':
        return '55%'
      case 'xl':
        return '50%'
      default:
        return '85%'
    }
  }

  // 响应式：根据断点获取标题字号
  getTitleFontSize(): number {
    switch (this.currentBreakpoint) {
      case 'xs':
        return 24
      case 'sm':
        return 32
      case 'md':
        return 36
      case 'lg':
        return 40
      case 'xl':
        return 44
      default:
        return 32
    }
  }
  
  // 搜索城市
  searchCityWeather() {
    if (this.searchCity.trim() === '') {
      this.searchError = '请输入城市名称'
      return
    }

    const cityName = this.searchCity.trim()
    const cityId = WeatherService.getCityId(cityName)

    if (!cityId) {
      this.searchError = '该城市不在搜索范围内，请重新输入'
      return
    }

    this.currentCity = cityName
    this.searchError = ''
    // 保存城市到分布式存储和全局状态
    this.distributedDataManager.saveCurrentCity(cityName)
    AppStorage.setOrCreate('currentCity', cityName)
    // 调用统一的天气数据加载方法
    this.loadWeatherData(cityName)
  }
  
  // 加载天气数据（优先使用和风天气API，失败时降级为本地数据）
  async loadWeatherData(cityName: string) {
    const cityId = WeatherService.getCityId(cityName)
    if (!cityId) {
      // 城市不在API支持范围，使用本地数据
      this.loadLocalWeatherData(cityName)
      return
    }

    // 如果API Key未配置，直接使用本地数据
    if (!WeatherService.isApiKeyConfigured()) {
      console.info('[WeatherService] API Key未配置，使用本地天气数据')
      this.loadLocalWeatherData(cityName)
      return
    }

    try {
      // 获取实时天气
      const nowData = await WeatherService.getNowWeather(cityId)
      if (nowData) {
        this.weather = nowData.weather
        this.temperature = nowData.temperature
        this.humidity = nowData.humidity
        this.windDirection = nowData.windDirection
        this.windSpeed = nowData.windSpeed
        this.airQuality = nowData.airQuality
        console.info('[WeatherService] 实时天气获取成功')
        // 保存天气数据到分布式存储
        this.saveWeatherToDistributed()
      } else {
        this.loadLocalWeatherData(cityName)
        return
      }

      // 获取未来3天预报
      const forecast = await WeatherService.get3DaysForecast(cityId)
      if (forecast && forecast.length >= 3) {
        this.tomorrowWeather = forecast[0].weather
        this.tomorrowTemperature = forecast[0].temperature
        this.tomorrowHumidity = forecast[0].humidity
        this.tomorrowWindDirection = forecast[0].windDirection
        this.tomorrowWindSpeed = forecast[0].windSpeed
        this.tomorrowAirQuality = forecast[0].airQuality

        this.dayAfterTomorrowWeather = forecast[1].weather
        this.dayAfterTomorrowTemperature = forecast[1].temperature
        this.dayAfterTomorrowHumidity = forecast[1].humidity
        this.dayAfterTomorrowWindDirection = forecast[1].windDirection
        this.dayAfterTomorrowWindSpeed = forecast[1].windSpeed
        this.dayAfterTomorrowAirQuality = forecast[1].airQuality

        this.threeDaysLaterWeather = forecast[2].weather
        this.threeDaysLaterTemperature = forecast[2].temperature
        this.threeDaysLaterHumidity = forecast[2].humidity
        this.threeDaysLaterWindDirection = forecast[2].windDirection
        this.threeDaysLaterWindSpeed = forecast[2].windSpeed
        this.threeDaysLaterAirQuality = forecast[2].airQuality
        console.info('[WeatherService] 3天预报获取成功')
      } else {
        // 预报数据不足，使用本地生成的未来天气
        this.generateFutureWeather()
      }
    } catch (error) {
      console.error('[WeatherService] 获取天气数据失败:', error)
      // 降级到本地数据
      this.loadLocalWeatherData(cityName)
    }
  }

  // 降级方案：使用本地硬编码天气数据
  loadLocalWeatherData(cityName: string) {
    const cityData = this.cityList.get(cityName)
    if (cityData) {
      this.weather = cityData[0]
      this.temperature = cityData[1]
      this.humidity = cityData[2]
      this.windDirection = cityData[3]
      this.windSpeed = cityData[4]
      this.airQuality = cityData[5]
      this.generateFutureWeather()
      // 保存天气数据到分布式存储
      this.saveWeatherToDistributed()
    }
  }

  // 生成未来几天的天气预测（本地降级方案）
  generateFutureWeather() {
    // 根据当前月份确定可用的天气类型
    const date = new Date()
    const month = date.getMonth() + 1
    
    // 根据季节选择天气类型
    let weatherTypes: string[]
    if (month >= 6 && month <= 8) {
      // 夏季（6-8月）：不下雪，但可能有雷阵雨
      weatherTypes = ['晴天', '多云', '阴天', '小雨', '中雨', '大雨', '雷阵雨']
    } else if (month >= 11 || month <= 2) {
      // 冬季（11-2月）：可能下雪
      weatherTypes = ['晴天', '多云', '阴天', '小雨', '中雨', '小雪', '中雪']
    } else {
      // 春秋季（3-5月，9-10月）：较少下雪，偶尔有雷阵雨
      weatherTypes = ['晴天', '多云', '阴天', '小雨', '中雨', '雷阵雨']
    }
    
    const currentWeatherIndex = weatherTypes.indexOf(this.weather)
    
    // 风向和空气指数选项
    const windDirections = ['东风', '南风', '西风', '北风', '东南风', '西南风', '东北风', '西北风']
    const windSpeeds = ['1级', '2级', '3级', '4级', '5级']
    const airQualities = ['优', '良', '中', '差']
    
    // 明日天气
    const tomorrowIndex = currentWeatherIndex >= 0 ? 
      (currentWeatherIndex + Math.floor(Math.random() * 3)) % weatherTypes.length : 
      Math.floor(Math.random() * weatherTypes.length)
    this.tomorrowWeather = weatherTypes[tomorrowIndex]
    this.tomorrowTemperature = `${parseInt(this.temperature) - Math.floor(Math.random() * 5 + 1)}°C`
    this.tomorrowHumidity = `${parseInt(this.humidity) + Math.floor(Math.random() * 10 - 5)}%`
    this.tomorrowWindDirection = windDirections[Math.floor(Math.random() * windDirections.length)]
    this.tomorrowWindSpeed = windSpeeds[Math.floor(Math.random() * windSpeeds.length)]
    this.tomorrowAirQuality = airQualities[Math.floor(Math.random() * 2)]  // 优或良
    
    // 后天天气
    const dayAfterTomorrowIndex = (tomorrowIndex + Math.floor(Math.random() * 3)) % weatherTypes.length
    this.dayAfterTomorrowWeather = weatherTypes[dayAfterTomorrowIndex]
    this.dayAfterTomorrowTemperature = `${parseInt(this.temperature) - Math.floor(Math.random() * 5 + 1)}°C`
    this.dayAfterTomorrowHumidity = `${parseInt(this.humidity) + Math.floor(Math.random() * 10 - 5)}%`
    this.dayAfterTomorrowWindDirection = windDirections[Math.floor(Math.random() * windDirections.length)]
    this.dayAfterTomorrowWindSpeed = windSpeeds[Math.floor(Math.random() * windSpeeds.length)]
    this.dayAfterTomorrowAirQuality = airQualities[Math.floor(Math.random() * 3)]  // 优、良、中
    
    // 大后天天气
    const threeDaysLaterIndex = (dayAfterTomorrowIndex + Math.floor(Math.random() * 3)) % weatherTypes.length
    this.threeDaysLaterWeather = weatherTypes[threeDaysLaterIndex]
    this.threeDaysLaterTemperature = `${parseInt(this.temperature) - Math.floor(Math.random() * 5 + 1)}°C`
    this.threeDaysLaterHumidity = `${parseInt(this.humidity) + Math.floor(Math.random() * 10 - 5)}%`
    this.threeDaysLaterWindDirection = windDirections[Math.floor(Math.random() * windDirections.length)]
    this.threeDaysLaterWindSpeed = windSpeeds[Math.floor(Math.random() * windSpeeds.length)]
    this.threeDaysLaterAirQuality = airQualities[Math.floor(Math.random() * 3)]  // 优、良、中
  }
  
  build() {
    Stack() {
      Scroll() {
      Column() {
        // 城市搜索框
        Column() {
          Row() {
            TextInput({ placeholder: '请输入城市名称' })
              .width('65%')
              .height(45)
              .fontSize(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 15, right: 15 })
              .onChange((value: string) => {
                this.searchCity = value
              })
              .onSubmit(() => {
                this.searchCityWeather()
              })
            
            Button('搜索')
              .width('25%')
              .height(45)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#1a73e8')
              .borderRadius(8)
              .margin({ left: 10 })
              .onClick(() => {
                this.searchCityWeather()
              })
          }
          .width(this.getContentWidth())
          .justifyContent(FlexAlign.Center)
          
          // 错误提示
          if (this.searchError !== '') {
            Text(this.searchError)
              .fontSize(14)
              .fontColor('#ff0000')
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .margin({ top: 20, bottom: 20 })
        
        // 标题
        Text(`${this.currentCity}天气`)
          .fontSize(this.getTitleFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a73e8')
          .margin({ top: 20, bottom: 30 })
      
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
        .width(this.getContentWidth())
        .padding(20)
        .backgroundColor('#f5f5f5')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 今日天气信息卡片
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.weather })
          
          // 天气内容
          Column() {
            Text('今日天气')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 15 })
            
            // 天气状态
            Row() {
              Text('天气状况')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.weather)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 温度
            Row() {
              Text('温度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.temperature)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 湿度
            Row() {
              Text('湿度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.humidity)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 风向
            Row() {
              Text('风向')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.windDirection)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 风速
            Row() {
              Text('风速')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.windSpeed)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 空气指数
            Row() {
              Text('空气指数')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.airQuality)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
        }
        .width(this.getContentWidth())
        .height(280)
        .borderRadius(12)
        .clip(true)
        .shadow({ 
          radius: 8, 
          color: '#e0e0e0', 
          offsetX: 0, 
          offsetY: 2 
        })
        .margin({ bottom: 20 })
        
        // 节气和黄历卡片
        Column() {
          Text('节气黄历')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a73e8')
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
              .fontColor('#333333')
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
              .fontColor('#333333')
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
              .fontColor('#333333')
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
              .fontColor('#333333')
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
              .fontColor('#333333')
              .maxLines(2)
          }
          .width('100%')
        }
        .width(this.getContentWidth())
        .padding(20)
        .backgroundColor('#e3f2fd')
        .borderRadius(12)
        .shadow({ 
          radius: 8, 
          color: '#e0e0e0', 
          offsetX: 0, 
          offsetY: 2 
        })
        .margin({ bottom: 20 })
        
        // 随机名言
        Column() {
          Text(`"${this.quote}"`)
            .fontSize(16)
            .fontColor('#5c6bc0')
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .margin({ bottom: 8 })
          
          Text(`—— ${this.quoteAuthor}`)
            .fontSize(14)
            .fontColor('#7986cb')
            .textAlign(TextAlign.End)
        }
        .width(this.getContentWidth())
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .margin({ bottom: 20 })
        
        // 明日天气预测卡片
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.tomorrowWeather })
          
          // 天气内容
          Column() {
            Text('明日天气预测')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 15 })
            
            // 明日日期
            Row() {
              Text('日期')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowDate)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日天气状态
            Row() {
              Text('天气状况')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowWeather)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日温度
            Row() {
              Text('温度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowTemperature)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日湿度
            Row() {
              Text('湿度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowHumidity)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日风向
            Row() {
              Text('风向')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowWindDirection)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日风速
            Row() {
              Text('风速')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowWindSpeed)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 明日空气指数
            Row() {
              Text('空气指数')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.tomorrowAirQuality)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
        }
        .width(this.getContentWidth())
        .height(340)
        .borderRadius(12)
        .clip(true)
        .shadow({ 
          radius: 8, 
          color: '#e0e0e0', 
          offsetX: 0, 
          offsetY: 2 
        })
        .margin({ bottom: 20 })
        
        // 后天天气预测卡片
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.dayAfterTomorrowWeather })
          
          // 天气内容
          Column() {
            Text('后天天气预测')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 15 })
            
            // 后天日期
            Row() {
              Text('日期')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowDate)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天天气状态
            Row() {
              Text('天气状况')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowWeather)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天温度
            Row() {
              Text('温度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowTemperature)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天湿度
            Row() {
              Text('湿度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowHumidity)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天风向
            Row() {
              Text('风向')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowWindDirection)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天风速
            Row() {
              Text('风速')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowWindSpeed)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 后天空气指数
            Row() {
              Text('空气指数')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.dayAfterTomorrowAirQuality)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
        }
        .width(this.getContentWidth())
        .height(340)
        .borderRadius(12)
        .clip(true)
        .shadow({ 
          radius: 8, 
          color: '#e0e0e0', 
          offsetX: 0, 
          offsetY: 2 
        })
        .margin({ bottom: 20 })
        
        // 大后天天气预测卡片
        Stack() {
          // 动态天气背景
          WeatherBackground({ weatherType: this.threeDaysLaterWeather })
          
          // 天气内容
          Column() {
            Text('大后天天气预测')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 15 })
            
            // 大后天日期
            Row() {
              Text('日期')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterDate)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天天气状态
            Row() {
              Text('天气状况')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterWeather)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天温度
            Row() {
              Text('温度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterTemperature)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天湿度
            Row() {
              Text('湿度')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterHumidity)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天风向
            Row() {
              Text('风向')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterWindDirection)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天风速
            Row() {
              Text('风速')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterWindSpeed)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .margin({ bottom: 15 })
            
            // 大后天空气指数
            Row() {
              Text('空气指数')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .opacity(0.9)
              
              Blank()
              
              Text(this.threeDaysLaterAirQuality)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
        }
        .width(this.getContentWidth())
        .height(340)
        .borderRadius(12)
        .clip(true)
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
            this.getDayAfterTomorrowDate()
            this.getThreeDaysLaterDate()
            this.getSolarTerm()
            this.getLunarDate()
            this.getHuangLiInfo()
          })
        
        // 小游戏按钮
        Column() {
          Button(this.completedLevels === 3 ? '已通关' : `第${this.currentLevel}关`)
            .fontSize(18)
            .fontColor('#ffffff')
            .backgroundColor(this.completedLevels === 3 ? '#999999' : 
                           (this.completedLevels >= this.currentLevel - 1 ? '#ff6b6b' : '#cccccc'))
            .borderRadius(25)
            .width('60%')
            .height(50)
            .onClick(() => {
              // 如果已通关，显示关卡选择对话框
              if (this.completedLevels === 3) {
                this.showLevelSelect = true
              } else if (this.completedLevels >= this.currentLevel - 1) {
                // 根据关卡跳转到不同的游戏页面
                const gameUrl = this.currentLevel === 1 ? 'pages/Game' : 
                               this.currentLevel === 2 ? 'pages/GameLevel2' : 'pages/GameLevel3'
                router.pushUrl({
                  url: gameUrl,
                  params: {
                    weatherType: this.weather,
                    level: this.currentLevel
                  }
                })
              }
            })
          
          // 三颗星星显示通关进度
          Column() {
            Row() {
              ForEach([1, 2, 3], (star: number) => {
                Text('★')
                  .fontSize(this.getTitleFontSize())
                  .fontColor(this.completedLevels >= star ? '#FFD700' : '#666666')
                  .margin({ left: 8, right: 8 })
              })
            }
            .margin({ top: 10 })
            
            Text(`今日已通关 ${this.completedLevels}/3 关`)
              .fontSize(18)
              .fontColor('#666666')
              .margin({ top: 8 })
          }

          Text(this.completedLevels === 3 ? '🎉 恭喜通关！' :
               this.currentLevel === 1 ? '触屏控制收集装置，收集掉落的天气元素' :
               this.currentLevel === 2 ? '点击目标所示的天气元素' :
               '记住天气元素位置，依次点击匹配')
            .fontSize(16)
            .fontColor(this.completedLevels === 3 ? '#FFD700' : '#999999')
            .margin({ top: 8 })
        }
        .margin({ top: 15 })
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
    
    // 关卡选择对话框
    if (this.showLevelSelect) {
      Column() {
        Column() {
          Text('选择关卡')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })
          
          Column() {
            ForEach([1, 2, 3], (level: number) => {
              Button(`第${level}关`)
                .fontSize(16)
                .width(120)
                .height(50)
                .backgroundColor('#1a73e8')
                .margin({ top: 8, bottom: 8 })
                .onClick(() => {
                  this.showLevelSelect = false
                  const gameUrl = level === 1 ? 'pages/Game' :
                                 level === 2 ? 'pages/GameLevel2' : 'pages/GameLevel3'
                  router.pushUrl({
                    url: gameUrl,
                    params: {
                      weatherType: this.weather,
                      level: level
                    }
                  })
                })
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 20, bottom: 20 })
          
          Button('关闭')
            .fontSize(16)
            .width('80%')
            .height(50)
            .backgroundColor('#999999')
            .margin({ top: 10 })
            .onClick(() => {
              this.showLevelSelect = false
            })
        }
        .width(this.getContentWidth())
        .padding(30)
        .backgroundColor('#ffffff')
        .borderRadius(20)
        .shadow({ radius: 20, color: '#000000', offsetX: 0, offsetY: 5 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 点击背景关闭对话框
        this.showLevelSelect = false
      })
    }
    }
    .width('100%')
    .height('100%')
  }
}

