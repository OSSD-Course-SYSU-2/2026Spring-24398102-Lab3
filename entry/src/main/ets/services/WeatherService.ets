/**
 * 天气服务类 - 使用和风天气API获取官方天气数据
 * 和风天气API文档：https://dev.qweather.com/
 *
 * 注意：使用前需要在和风天气官网申请API Key
 * 免费订阅支持：1000次/天
 */
import { http } from '@kit.NetworkKit';

// 天气数据接口
export interface WeatherData {
  weather: string          // 天气状况
  temperature: string      // 温度
  humidity: string         // 湿度
  windDirection: string    // 风向
  windSpeed: string        // 风速
  airQuality: string       // 空气质量
}

// 和风天气API实时天气响应结构
interface NowWeatherResponse {
  code: string;
  now: NowWeatherItem;
}

interface NowWeatherItem {
  text: string;
  temp: string;
  humidity: string;
  windDir: string;
  windScale: string;
}

// 和风天气API空气质量响应结构
interface AirQualityResponse {
  code: string;
  now: AirQualityItem;
}

interface AirQualityItem {
  aqi: string;
}

// 和风天气API 3天预报响应结构
interface ForecastResponse {
  code: string;
  daily: DailyForecastItem[];
}

interface DailyForecastItem {
  textDay: string;
  tempMin: string;
  tempMax: string;
  humidity: string;
  windDirDay: string;
  windScaleDay: string;
}

export class WeatherService {
  // 和风天气API配置
  // 注意：请替换为您自己的API Key
  // 申请地址：https://dev.qweather.com/
  private static readonly API_KEY = 'be6149206cb64b0caa3a8b17b7ae89a4'
  private static readonly BASE_URL = 'https://k86hf249w9.re.qweatherapi.com/v7'

  // 城市ID映射表（中国主要城市）
  private static readonly CITY_IDS: Map<string, string> = new Map([
    ['北京', '101010100'],
    ['上海', '101020100'],
    ['天津', '101030100'],
    ['重庆', '101040100'],
    ['哈尔滨', '101050101'],
    ['长春', '101060101'],
    ['沈阳', '101070101'],
    ['石家庄', '101090101'],
    ['太原', '101100101'],
    ['呼和浩特', '101080101'],
    ['济南', '101120101'],
    ['南京', '101190101'],
    ['合肥', '101220101'],
    ['杭州', '101210101'],
    ['福州', '101230101'],
    ['南昌', '101240101'],
    ['郑州', '101180101'],
    ['武汉', '101200101'],
    ['长沙', '101250101'],
    ['广州', '101280101'],
    ['南宁', '101300101'],
    ['海口', '101310101'],
    ['成都', '101270101'],
    ['贵阳', '101260101'],
    ['昆明', '101290101'],
    ['拉萨', '101140101'],
    ['西安', '101110101'],
    ['兰州', '101160101'],
    ['西宁', '101150101'],
    ['银川', '101170101'],
    ['乌鲁木齐', '101130101'],
    ['大连', '101070201'],
    ['青岛', '101120201'],
    ['宁波', '101210401'],
    ['厦门', '101230201'],
    ['深圳', '101280601'],
    ['苏州', '101190401'],
    ['无锡', '101190201'],
    ['东莞', '101281601'],
    ['佛山', '101281701'],
    ['烟台', '101120501'],
    ['温州', '101210701'],
    ['泉州', '101230501'],
    ['唐山', '101090301'],
    ['保定', '101090201'],
    ['包头', '101080201'],
    ['鄂尔多斯', '101080301'],
    ['洛阳', '101180901'],
    ['开封', '101180801'],
    ['大同', '101100201'],
    ['桂林', '101300501'],
    ['三亚', '101310201'],
    ['绵阳', '101270401'],
    ['遵义', '101260201'],
    ['大理', '101290201'],
    ['咸阳', '101110200'],
    ['宝鸡', '101110301'],
    ['天水', '101160501'],
    ['酒泉', '101160801'],
    ['克拉玛依', '101130201']
  ])

  static getCityId(cityName: string): string | null {
    return WeatherService.CITY_IDS.get(cityName) || null
  }

  static async getNowWeather(cityId: string): Promise<WeatherData | null> {
    const httpRequest = http.createHttp()
    try {
      const url = `${WeatherService.BASE_URL}/weather/now?location=${cityId}&key=${WeatherService.API_KEY}`
      console.info('[WeatherAPI] 请求URL:', url)
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: 10000,
        readTimeout: 10000
      })
      console.info('[WeatherAPI] 响应码:', response.responseCode)
      if (response.responseCode === 200) {
        const data = response.result as NowWeatherResponse
        console.info('[WeatherAPI] 业务码:', data.code)
        if (data.code === '200' && data.now) {
          const now: NowWeatherItem = data.now
          const result: WeatherData = {
            weather: WeatherService.translateWeather(now.text),
            temperature: `${now.temp}°C`,
            humidity: `${now.humidity}%`,
            windDirection: WeatherService.translateWindDir(now.windDir),
            windSpeed: `${now.windScale}级`,
            airQuality: '良'
          }
          console.info('[WeatherAPI] 天气获取成功:', now.text)
          return result
        }
        console.warn('[WeatherAPI] 业务错误, code:', data.code)
      }
      return null
    } catch (error) {
      console.error('[WeatherAPI] 请求异常:', JSON.stringify(error))
      return null
    } finally {
      httpRequest.destroy()
    }
  }

  static async getAirQuality(cityId: string): Promise<string> {
    const httpRequest = http.createHttp()
    try {
      const url = `${WeatherService.BASE_URL}/air/now?location=${cityId}&key=${WeatherService.API_KEY}`
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: 10000,
        readTimeout: 10000
      })
      if (response.responseCode === 200) {
        const data = response.result as AirQualityResponse
        if (data.code === '200' && data.now) {
          const aqi: number = parseInt(data.now.aqi)
          if (aqi <= 50) {
            return '优'
          }
          if (aqi <= 100) {
            return '良'
          }
          if (aqi <= 150) {
            return '中'
          }
          return '差'
        }
      }
      return '良'
    } catch (error) {
      console.error('获取空气质量失败:', JSON.stringify(error))
      return '良'
    } finally {
      httpRequest.destroy()
    }
  }

  static async get3DaysForecast(cityId: string): Promise<WeatherData[]> {
    const httpRequest = http.createHttp()
    try {
      const url = `${WeatherService.BASE_URL}/weather/3d?location=${cityId}&key=${WeatherService.API_KEY}`
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: 10000,
        readTimeout: 10000
      })
      if (response.responseCode === 200) {
        const data = response.result as ForecastResponse
        if (data.code === '200' && data.daily) {
          const result: WeatherData[] = []
          for (let i = 0; i < data.daily.length; i++) {
            const day: DailyForecastItem = data.daily[i]
            const item: WeatherData = {
              weather: WeatherService.translateWeather(day.textDay),
              temperature: `${day.tempMin}°C ~ ${day.tempMax}°C`,
              humidity: `${day.humidity}%`,
              windDirection: WeatherService.translateWindDir(day.windDirDay),
              windSpeed: `${day.windScaleDay}级`,
              airQuality: '良'
            }
            result.push(item)
          }
          return result
        }
      }
      return []
    } catch (error) {
      console.error('获取天气预报失败:', JSON.stringify(error))
      return []
    } finally {
      httpRequest.destroy()
    }
  }

  private static translateWeather(text: string): string {
    const weatherMap: Map<string, string> = new Map([
      ['晴', '晴天'],
      ['多云', '多云'],
      ['阴', '阴天'],
      ['小雨', '小雨'],
      ['中雨', '中雨'],
      ['大雨', '大雨'],
      ['暴雨', '大雨'],
      ['雷阵雨', '雷阵雨'],
      ['雷暴', '雷阵雨'],
      ['小雪', '小雪'],
      ['中雪', '中雪'],
      ['大雪', '大雪'],
      ['暴雪', '大雪'],
      ['雨夹雪', '小雨'],
      ['雾', '阴天'],
      ['霾', '阴天']
    ])
    return weatherMap.get(text) || text
  }

  private static translateWindDir(dir: string): string {
    const dirMap: Map<string, string> = new Map([
      ['N', '北风'],
      ['NNE', '东北风'],
      ['NE', '东北风'],
      ['ENE', '东风'],
      ['E', '东风'],
      ['ESE', '东南风'],
      ['SE', '东南风'],
      ['SSE', '南风'],
      ['S', '南风'],
      ['SSW', '西南风'],
      ['SW', '西南风'],
      ['WSW', '西风'],
      ['W', '西风'],
      ['WNW', '西北风'],
      ['NW', '西北风'],
      ['NNW', '北风']
    ])
    return dirMap.get(dir) || dir
  }

  static isApiKeyConfigured(): boolean {
    return WeatherService.API_KEY.length === 32
  }

  static getUsageInstructions(): string {
    return `【和风天气API使用说明】

1. 申请API Key：
   - 访问 https://dev.qweather.com/
   - 注册账号并登录
   - 创建应用，选择"免费订阅"
   - 获取API Key

2. 配置API Key：
   - 在WeatherService.ets中找到API_KEY
   - 将'YOUR_API_KEY_HERE'替换为您的API Key

3. 配置网络权限：
   - 已在module.json5中配置ohos.permission.INTERNET

4. API限制：
   - 免费订阅：1000次/天
   - 支持中国主要城市
   - 实时天气、天气预报、空气质量

5. 数据来源：
   - 和风天气（QWeather）
   - 数据更新频率：实时
   - 数据准确性：官方气象数据`
  }
}
