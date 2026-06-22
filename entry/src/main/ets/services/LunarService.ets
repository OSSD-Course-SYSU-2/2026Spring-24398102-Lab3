/**
 * 农历服务类 - 使用HarmonyOS官方i18n.Calendar API
 * 数据来源：HarmonyOS系统API
 * 参考文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-i18n-V5
 */

import { i18n } from '@kit.LocalizationKit'

// 农历日期数据
export interface LunarDateData {
  year: string        // 农历年份（干支纪年）
  month: string       // 农历月份
  day: string         // 农历日期
  yearGanZhi: string  // 干支纪年
  shengXiao: string   // 生肖
  isLeapMonth: boolean // 是否闰月
}

// 节气数据
export interface SolarTermData {
  name: string        // 节气名称
  date: string        // 节气日期
  meaning: string     // 节气含义
  customs: string     // 相关习俗
  health: string      // 养生建议
}

export class LunarService {
  // 天干
  private static readonly TIAN_GAN: string[] = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ]
  
  // 地支
  private static readonly DI_ZHI: string[] = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ]
  
  // 生肖
  private static readonly SHENG_XIAO: string[] = [
    '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'
  ]
  
  // 农历月份名称
  private static readonly LUNAR_MONTHS: string[] = [
    '正月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '冬月', '腊月'
  ]
  
  // 农历日期名称
  private static readonly LUNAR_DAYS: string[] = [
    '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
  ]
  
  // 节气名称
  private static readonly SOLAR_TERMS: string[] = [
    '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
    '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
    '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
    '寒露', '霜降', '立冬', '小雪', '大雪', '冬至'
  ]
  
  // 节气含义
  private static readonly SOLAR_TERM_MEANINGS: Map<string, string> = new Map([
    ['小寒', '小寒是二十四节气中的第23个节气，标志着一年中最寒冷的日子即将到来'],
    ['大寒', '大寒是二十四节气中的最后一个节气，也是一年中最冷的时候'],
    ['立春', '立春是二十四节气中的第一个节气，标志着春天的开始，万物复苏'],
    ['雨水', '雨水节气，降雨开始，雨量渐增，有利于农作物生长'],
    ['惊蛰', '惊蛰时节，春雷始鸣，蛰伏的昆虫开始苏醒'],
    ['春分', '春分这一天，太阳直射赤道，昼夜等长'],
    ['清明', '清明时节，气温升高，正是春耕春种的大好时节'],
    ['谷雨', '谷雨是春季最后一个节气，雨生百谷，有利于谷物生长'],
    ['立夏', '立夏标志着夏季的开始，万物繁茂'],
    ['小满', '小满时节，夏熟作物的籽粒开始灌浆饱满'],
    ['芒种', '芒种是有芒作物成熟的时候，也是播种繁忙的季节'],
    ['夏至', '夏至这一天，太阳直射北回归线，北半球白昼最长'],
    ['小暑', '小暑标志着炎热天气的开始，但还不是最热'],
    ['大暑', '大暑是一年中最热的时期，正值中伏前后'],
    ['立秋', '立秋标志着秋季的开始，暑去凉来'],
    ['处暑', '处暑表示炎热的暑天结束了'],
    ['白露', '白露时节，天气转凉，露水凝结成白色'],
    ['秋分', '秋分这一天，太阳再次直射赤道，昼夜等长'],
    ['寒露', '寒露时节，气温更低，露水更多且更凉'],
    ['霜降', '霜降是秋季最后一个节气，开始有霜'],
    ['立冬', '立冬标志着冬季的开始，万物收藏'],
    ['小雪', '小雪时节，开始降雪，但雪量不大'],
    ['大雪', '大雪时节，降雪量增大，地面开始积雪'],
    ['冬至', '冬至这一天，太阳直射南回归线，北半球白昼最短']
  ])
  
  // 节气习俗
  private static readonly SOLAR_TERM_CUSTOMS: Map<string, string> = new Map([
    ['小寒', '吃腊八粥、采购年货、准备春节'],
    ['大寒', '除旧布新、准备年货、扫尘洁物'],
    ['立春', '迎春仪式、吃春饼、贴春联、咬春'],
    ['雨水', '女婿给岳父母送礼、接寿、撞拜寄'],
    ['惊蛰', '祭白虎、打小人、吃梨、蒙鼓皮'],
    ['春分', '竖蛋、放风筝、春祭、吃春菜'],
    ['清明', '扫墓祭祖、踏青郊游、插柳、放风筝'],
    ['谷雨', '赏牡丹、祭仓颉、摘谷雨茶、食香椿'],
    ['立夏', '迎夏、尝新、斗蛋、秤人'],
    ['小满', '祭车神、祈蚕节、食苦菜、抢水'],
    ['芒种', '送花神、安苗、打泥巴仗、煮梅'],
    ['夏至', '祭神祀祖、消夏避伏、吃面条'],
    ['小暑', '晒伏姜、吃饺子、吃藕、小暑尝新'],
    ['大暑', '晒伏姜、饮伏茶、烧伏香、过大暑'],
    ['立秋', '贴秋膘、啃秋、秋祭、晒秋'],
    ['处暑', '祭祖、迎秋、出游迎秋、开渔节'],
    ['白露', '收清露、祭禹王、吃龙眼、喝白露茶'],
    ['秋分', '祭月、吃秋菜、送秋牛、粘雀子嘴'],
    ['寒露', '登高赏菊、饮菊花酒、吃芝麻、秋钓边'],
    ['霜降', '赏菊花、吃柿子、登高远眺、进补'],
    ['立冬', '贺冬、补冬、吃饺子、酿黄酒'],
    ['小雪', '腌腊肉、吃糍粑、晒鱼干、腌蔬菜'],
    ['大雪', '腌肉、观赏封河、进补、喝红薯粥'],
    ['冬至', '祭天祭祖、吃饺子、吃汤圆、九九消寒']
  ])
  
  // 节气养生
  private static readonly SOLAR_TERM_HEALTH: Map<string, string> = new Map([
    ['小寒', '注意保暖，适当进补，预防感冒，多食温热食物'],
    ['大寒', '防寒保暖，适度锻炼，早睡晚起，养精蓄锐'],
    ['立春', '注意保暖，饮食清淡，适量运动，调养情志'],
    ['雨水', '调养脾胃，防寒保暖，适当运动，预防春病'],
    ['惊蛰', '养肝护脾，适度运动，早睡早起，预防疾病'],
    ['春分', '保持平衡，调养精神，适度运动，预防感冒'],
    ['清明', '养肝护脾，适度运动，调节情绪，预防过敏'],
    ['谷雨', '健脾祛湿，养肝护胆，适度运动，预防疾病'],
    ['立夏', '养心安神，清淡饮食，适度运动，防暑降温'],
    ['小满', '清热利湿，养心安神，适度运动，预防皮肤病'],
    ['芒种', '清热解暑，养心安神，适度运动，防暑降温'],
    ['夏至', '养心安神，清淡饮食，适度运动，防暑降温'],
    ['小暑', '清热解暑，养心安神，清淡饮食，防暑降温'],
    ['大暑', '防暑降温，养心安神，清淡饮食，预防中暑'],
    ['立秋', '养肺护肝，适度运动，调节情绪，预防秋燥'],
    ['处暑', '养肺护肝，适度运动，调节情绪，预防秋燥'],
    ['白露', '养肺护肝，防寒保暖，适度运动，预防感冒'],
    ['秋分', '养肺护肝，适度运动，调节情绪，预防秋燥'],
    ['寒露', '养肺护肝，防寒保暖，适度运动，预防感冒'],
    ['霜降', '养肺护肝，防寒保暖，适度运动，预防感冒'],
    ['立冬', '养肾防寒，适度运动，早睡晚起，进补养生'],
    ['小雪', '养肾防寒，适度运动，早睡晚起，温补养生'],
    ['大雪', '养肾防寒，适度运动，早睡晚起，进补养生'],
    ['冬至', '养肾防寒，适度运动，早睡晚起，进补养生']
  ])
  
  /**
   * 获取农历日期
   * @param date 公历日期
   * @returns 农历日期数据
   */
  static getLunarDate(date: Date = new Date()): LunarDateData {
    try {
      // 使用HarmonyOS官方农历API
      const calendar: i18n.Calendar = i18n.getCalendar('zh-Hans', 'chinese')
      calendar.setTime(date.getTime())
      
      // 获取农历年月日
      const year = calendar.get('year')      // 干支纪年（1-60）
      const month = calendar.get('month')    // 农历月份（0-11）
      const day = calendar.get('date')       // 农历日期（1-30）
      
      // 计算干支纪年
      const yearIndex = (year - 1) % 60
      const ganIndex = yearIndex % 10
      const zhiIndex = yearIndex % 12
      
      const yearGanZhi = `${this.TIAN_GAN[ganIndex]}${this.DI_ZHI[zhiIndex]}`
      const shengXiao = this.SHENG_XIAO[zhiIndex]
      
      // 判断是否闰月
      const isLeapMonth = calendar.get('isLeapMonth') === 1
      
      // 格式化农历月份
      let lunarMonthName = this.LUNAR_MONTHS[month]
      if (isLeapMonth) {
        lunarMonthName = '闰' + lunarMonthName
      }
      
      return {
        year: `${yearGanZhi}年 ${shengXiao}年`,
        month: lunarMonthName,
        day: this.LUNAR_DAYS[day - 1] || '初一',
        yearGanZhi: yearGanZhi,
        shengXiao: shengXiao,
        isLeapMonth: isLeapMonth
      }
    } catch (error) {
      console.error('获取农历日期失败:', error)
      // 返回默认值
      return {
        year: '甲子年 鼠年',
        month: '正月',
        day: '初一',
        yearGanZhi: '甲子',
        shengXiao: '鼠',
        isLeapMonth: false
      }
    }
  }
  
  /**
   * 获取当前节气
   * @param date 日期
   * @returns 节气数据
   */
  static getCurrentSolarTerm(date: Date = new Date()): SolarTermData {
    try {
      // 使用HarmonyOS官方农历API获取节气
      const calendar: i18n.Calendar = i18n.getCalendar('zh-Hans', 'chinese')
      calendar.setTime(date.getTime())
      
      // 获取节气名称
      const termName = calendar.get('term') || ''
      
      if (termName && this.SOLAR_TERMS.includes(termName)) {
        return {
          name: termName,
          date: this.formatDate(date),
          meaning: this.SOLAR_TERM_MEANINGS.get(termName) || '',
          customs: this.SOLAR_TERM_CUSTOMS.get(termName) || '',
          health: this.SOLAR_TERM_HEALTH.get(termName) || ''
        }
      }
      
      // 如果不是节气当天，计算最近的节气
      return this.getNearestSolarTerm(date)
    } catch (error) {
      console.error('获取节气失败:', error)
      return this.getNearestSolarTerm(date)
    }
  }
  
  /**
   * 获取最近的节气
   * @param date 日期
   * @returns 节气数据
   */
  private static getNearestSolarTerm(date: Date): SolarTermData {
    // 简化算法：根据月份估算当前节气
    const month = date.getMonth() + 1
    const day = date.getDate()
    
    // 节气大致日期（近似值）
    const termDates: [number, number, string][] = [
      [1, 5, '小寒'], [1, 20, '大寒'],
      [2, 3, '立春'], [2, 18, '雨水'],
      [3, 5, '惊蛰'], [3, 20, '春分'],
      [4, 4, '清明'], [4, 19, '谷雨'],
      [5, 5, '立夏'], [5, 20, '小满'],
      [6, 5, '芒种'], [6, 21, '夏至'],
      [7, 7, '小暑'], [7, 22, '大暑'],
      [8, 7, '立秋'], [8, 22, '处暑'],
      [9, 7, '白露'], [9, 22, '秋分'],
      [10, 8, '寒露'], [10, 23, '霜降'],
      [11, 7, '立冬'], [11, 22, '小雪'],
      [12, 7, '大雪'], [12, 21, '冬至']
    ]
    
    // 找到当前或下一个节气
    let currentTerm = termDates[0]
    let minDiff = 365
    
    for (const term of termDates) {
      const diff = Math.abs((month - term[0]) * 31 + (day - term[1]))
      if (diff < minDiff) {
        minDiff = diff
        currentTerm = term
      }
    }
    
    const termName = currentTerm[2]
    
    return {
      name: termName,
      date: this.formatDate(date),
      meaning: this.SOLAR_TERM_MEANINGS.get(termName) || '',
      customs: this.SOLAR_TERM_CUSTOMS.get(termName) || '',
      health: this.SOLAR_TERM_HEALTH.get(termName) || ''
    }
  }
  
  /**
   * 格式化日期
   * @param date 日期
   * @returns 格式化后的日期字符串
   */
  private static formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${year}年${month}月${day}日`
  }
  
  /**
   * 判断是否为节气当天
   * @param date 日期
   * @returns 是否为节气当天
   */
  static isSolarTermDay(date: Date = new Date()): boolean {
    try {
      const calendar: i18n.Calendar = i18n.getCalendar('zh-Hans', 'chinese')
      calendar.setTime(date.getTime())
      
      const termName = calendar.get('term') || ''
      return termName !== '' && this.SOLAR_TERMS.includes(termName)
    } catch (error) {
      return false
    }
  }
}
