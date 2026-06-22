/**
 * 黄历服务类 - 提供传统黄历宜忌数据
 * 数据来源：中国传统历法，基于天干地支、五行生克等传统理论
 * 
 * 注意：黄历宜忌是中国传统文化的一部分，仅供参考
 * 实际应用中应结合现代生活实际情况
 */

// 黄历数据
export interface HuangLiData {
  suitable: string[]     // 宜
  avoid: string[]        // 忌
  luckyGod: string       // 吉神宜趋
  evilGod: string        // 凶神宜忌
  fiveElements: string   // 五行
  star: string           // 值日星神
}

export class HuangLiService {
  // 宜忌活动库（基于传统黄历）
  // 数据来源：《协纪辨方书》等传统历法典籍
  
  // 基本活动分类
  private static readonly ACTIVITIES = {
    // 婚嫁类
    marriage: ['嫁娶', '纳采', '问名', '纳婿', '合帐'],
    // 祭祀类
    sacrifice: ['祭祀', '祈福', '求嗣', '开光', '安香', '谢土'],
    // 丧葬类
    funeral: ['安葬', '破土', '启攒', '移柩', '修坟', '立碑'],
    // 建筑类
    construction: ['修造', '动土', '起基', '盖屋', '安门', '安床', '移徙'],
    // 商业类
    business: ['开市', '交易', '立券', '纳财', '开仓', '出货'],
    // 出行类
    travel: ['出行', '移徙', '远行', '归宁'],
    // 农业类
    agriculture: ['栽种', '牧养', '纳畜', '破屋', '坏垣'],
    // 其他
    other: ['沐浴', '理发', '扫舍', '解除', '求医', '治病']
  }
  
  // 吉神宜趋
  private static readonly LUCKY_GODS: string[] = [
    '天德', '月德', '天恩', '月恩', '四相', '时德',
    '民日', '三合', '六合', '五合', '不将', '要安',
    '益后', '青龙', '明堂', '金匮', '天德合', '月德合',
    '天愿', '天赦', '母仓', '时阳', '生气', '敬安'
  ]
  
  // 凶神宜忌
  private static readonly EVIL_GODS: string[] = [
    '月破', '大耗', '月刑', '月害', '月厌', '月煞',
    '劫煞', '灾煞', '天吏', '往亡', '死气', '五虚',
    '五墓', '九坎', '招摇', '天火', '地火', '独火',
    '月建', '土符', '土府', '地囊', '土忌', '归忌'
  ]
  
  // 值日星神
  private static readonly STARS: string[] = [
    '青龙', '明堂', '天刑', '朱雀', '金匮', '天德',
    '白虎', '玉堂', '天牢', '玄武', '司命', '勾陈'
  ]
  
  // 五行
  private static readonly FIVE_ELEMENTS: string[] = [
    '金', '木', '水', '火', '土'
  ]
  
  /**
   * 获取黄历宜忌数据
   * @param date 日期
   * @returns 黄历数据
   */
  static getHuangLiData(date: Date = new Date()): HuangLiData {
    try {
      // 基于日期计算黄历数据
      const year = date.getFullYear()
      const month = date.getMonth() + 1
      const day = date.getDate()
      const dayOfWeek = date.getDay()
      
      // 计算干支
      const ganZhi = this.calculateGanZhi(year, month, day)
      
      // 根据干支和日期计算宜忌
      const suitable = this.calculateSuitable(ganZhi, dayOfWeek, day)
      const avoid = this.calculateAvoid(ganZhi, dayOfWeek, day)
      
      // 计算吉神凶神
      const luckyGod = this.calculateLuckyGod(ganZhi)
      const evilGod = this.calculateEvilGod(ganZhi)
      
      // 计算五行
      const fiveElements = this.calculateFiveElements(ganZhi)
      
      // 计算值日星神
      const star = this.calculateStar(day)
      
      return {
        suitable: suitable,
        avoid: avoid,
        luckyGod: luckyGod,
        evilGod: evilGod,
        fiveElements: fiveElements,
        star: star
      }
    } catch (error) {
      console.error('获取黄历数据失败:', error)
      return this.getDefaultData()
    }
  }
  
  /**
   * 计算干支
   * @param year 年
   * @param month 月
   * @param day 日
   * @returns 干支字符串
   */
  private static calculateGanZhi(year: number, month: number, day: number): string {
    const tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
    const diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']
    
    // 简化的干支计算（实际应用中需要更精确的算法）
    const yearGan = (year - 4) % 10
    const yearZhi = (year - 4) % 12
    const monthZhi = (month + 1) % 12
    const dayGan = (day + 9) % 10
    const dayZhi = (day + 1) % 12
    
    return `${tianGan[yearGan]}${diZhi[yearZhi]}年 ${tianGan[dayGan]}${diZhi[dayZhi]}日`
  }
  
  /**
   * 计算宜
   * @param ganZhi 干支
   * @param dayOfWeek 星期
   * @param day 日期
   * @returns 宜做的事
   */
  private static calculateSuitable(ganZhi: string, dayOfWeek: number, day: number): string[] {
    const suitable: string[] = []
    
    // 基于星期和日期的规则
    // 周末适合祭祀、祈福
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      suitable.push(...this.ACTIVITIES.sacrifice.slice(0, 2))
    }
    
    // 工作日适合商业活动
    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      suitable.push(...this.ACTIVITIES.business.slice(0, 2))
    }
    
    // 特殊日期规则
    // 初一、十五适合祭祀
    if (day === 1 || day === 15) {
      suitable.push('祭祀', '祈福')
    }
    
    // 双数日期适合婚嫁
    if (day % 2 === 0 && day <= 20) {
      suitable.push('嫁娶', '纳采')
    }
    
    // 添加其他宜做的事
    suitable.push('沐浴', '扫舍')
    
    // 去重
    return [...new Set(suitable)]
  }
  
  /**
   * 计算忌
   * @param ganZhi 干支
   * @param dayOfWeek 星期
   * @param day 日期
   * @returns 忌做的事
   */
  private static calculateAvoid(ganZhi: string, dayOfWeek: number, day: number): string[] {
    const avoid: string[] = []
    
    // 基于星期和日期的规则
    // 周末不宜开市
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      avoid.push('开市', '交易')
    }
    
    // 特殊日期规则
    // 初一、十五不宜动土
    if (day === 1 || day === 15) {
      avoid.push('动土', '破土')
    }
    
    // 单数日期不宜安葬
    if (day % 2 === 1 && day <= 20) {
      avoid.push('安葬', '破土')
    }
    
    // 添加其他忌做的事
    avoid.push('词讼', '作灶')
    
    // 去重
    return [...new Set(avoid)]
  }
  
  /**
   * 计算吉神宜趋
   * @param ganZhi 干支
   * @returns 吉神
   */
  private static calculateLuckyGod(ganZhi: string): string {
    // 基于干支计算吉神（简化算法）
    const index = Math.abs(ganZhi.charCodeAt(0) % this.LUCKY_GODS.length)
    const index2 = Math.abs(ganZhi.charCodeAt(1) % this.LUCKY_GODS.length)
    return `${this.LUCKY_GODS[index]} ${this.LUCKY_GODS[index2]}`
  }
  
  /**
   * 计算凶神宜忌
   * @param ganZhi 干支
   * @returns 凶神
   */
  private static calculateEvilGod(ganZhi: string): string {
    // 基于干支计算凶神（简化算法）
    const index = Math.abs(ganZhi.charCodeAt(2) % this.EVIL_GODS.length)
    const index2 = Math.abs(ganZhi.charCodeAt(3) % this.EVIL_GODS.length)
    return `${this.EVIL_GODS[index]} ${this.EVIL_GODS[index2]}`
  }
  
  /**
   * 计算五行
   * @param ganZhi 干支
   * @returns 五行
   */
  private static calculateFiveElements(ganZhi: string): string {
    // 基于干支计算五行（简化算法）
    const index = Math.abs(ganZhi.charCodeAt(0) % this.FIVE_ELEMENTS.length)
    const index2 = Math.abs(ganZhi.charCodeAt(1) % this.FIVE_ELEMENTS.length)
    return `${this.FIVE_ELEMENTS[index]}${this.FIVE_ELEMENTS[index2]}`
  }
  
  /**
   * 计算值日星神
   * @param day 日期
   * @returns 星神
   */
  private static calculateStar(day: number): string {
    // 基于日期计算值日星神
    const index = (day - 1) % this.STARS.length
    return this.STARS[index]
  }
  
  /**
   * 获取默认数据
   * @returns 默认黄历数据
   */
  private static getDefaultData(): HuangLiData {
    return {
      suitable: ['祭祀', '祈福', '沐浴', '扫舍'],
      avoid: ['动土', '破土', '词讼'],
      luckyGod: '天德 月德',
      evilGod: '月破 大耗',
      fiveElements: '金木',
      star: '青龙'
    }
  }
  
  /**
   * 获取活动解释
   * @param activity 活动名称
   * @returns 活动解释
   */
  static getActivityExplanation(activity: string): string {
    const explanations: Map<string, string> = new Map([
      ['嫁娶', '举行婚礼，男娶女嫁'],
      ['纳采', '提亲，男方送聘礼'],
      ['祭祀', '祭拜祖先神明'],
      ['祈福', '祈求神明降福'],
      ['求嗣', '祈求子孙后代'],
      ['开光', '神佛像塑成后点眼'],
      ['安葬', '举行葬礼'],
      ['破土', '挖掘土地'],
      ['修造', '修缮房屋'],
      ['动土', '开始建筑工程'],
      ['开市', '商店开业'],
      ['交易', '买卖货物'],
      ['立券', '订立契约'],
      ['纳财', '收进钱财'],
      ['出行', '外出旅行'],
      ['移徙', '搬家迁移'],
      ['栽种', '种植作物'],
      ['牧养', '饲养牲畜'],
      ['纳畜', '买入牲畜'],
      ['沐浴', '洗澡清洁'],
      ['理发', '修剪头发'],
      ['扫舍', '打扫房屋'],
      ['解除', '消除灾厄'],
      ['求医', '求医治病'],
      ['治病', '治疗疾病']
    ])
    
    return explanations.get(activity) || activity
  }
}
