# 天气应用服务层文档

## 📋 概述

本项目已全面升级为使用官方数据源，确保所有数据的准确性和可靠性。

## 🌤️ 天气数据服务 (WeatherService)

### 数据来源
- **官方API**: 和风天气 (QWeather)
- **API文档**: https://dev.qweather.com/
- **数据更新**: 实时更新
- **覆盖范围**: 中国主要城市

### 使用方法

1. **申请API Key**
   - 访问 https://dev.qweather.com/
   - 注册账号并创建应用
   - 选择"免费订阅"（1000次/天）
   - 获取API Key

2. **配置API Key**
   ```typescript
   // 在 WeatherService.ets 中
   private static readonly API_KEY = 'YOUR_API_KEY_HERE'  // 替换为您的API Key
   ```

3. **配置网络权限**
   ```json5
   // 在 module.json5 中添加
   "requestPermissions": [
     {
       "name": "ohos.permission.INTERNET"
     }
   ]
   ```

4. **使用示例**
   ```typescript
   // 获取城市ID
   const cityId = WeatherService.getCityId('广州')
   
   // 获取实时天气
   const weather = await WeatherService.getNowWeather(cityId)
   
   // 获取空气质量
   const airQuality = await WeatherService.getAirQuality(cityId)
   
   // 获取3天预报
   const forecast = await WeatherService.get3DaysForecast(cityId)
   ```

### 支持的城市
- 直辖市：北京、上海、天津、重庆
- 省会城市：全部覆盖
- 重要城市：深圳、苏州、大连、青岛等50+城市

---

## 🌙 农历服务 (LunarService)

### 数据来源
- **官方API**: HarmonyOS i18n.Calendar
- **算法标准**: 中国传统农历算法
- **支持功能**: 农历日期、干支纪年、节气

### 使用方法

```typescript
import { LunarService } from '../services/LunarService'

// 获取农历日期
const lunarDate = LunarService.getLunarDate()
console.log(lunarDate.year)      // 甲子年 鼠年
console.log(lunarDate.month)     // 正月
console.log(lunarDate.day)       // 初一
console.log(lunarDate.shengXiao) // 鼠

// 获取当前节气
const solarTerm = LunarService.getCurrentSolarTerm()
console.log(solarTerm.name)      // 立春
console.log(solarTerm.meaning)   // 节气含义
console.log(solarTerm.customs)   // 相关习俗
console.log(solarTerm.health)    // 养生建议

// 判断是否为节气当天
const isTermDay = LunarService.isSolarTermDay()
```

### 功能特点
- ✅ 使用HarmonyOS官方农历API
- ✅ 支持干支纪年计算
- ✅ 支持生肖计算
- ✅ 支持闰月判断
- ✅ 支持24节气查询
- ✅ 提供节气含义、习俗、养生建议

---

## 📅 黄历服务 (HuangLiService)

### 数据来源
- **传统历法**: 基于《协纪辨方书》等传统历法典籍
- **计算方法**: 天干地支、五行生克
- **数据范围**: 宜忌、吉神凶神、五行、值日星神

### 使用方法

```typescript
import { HuangLiService } from '../services/HuangLiService'

// 获取黄历数据
const huangLi = HuangLiService.getHuangLiData()
console.log(huangLi.suitable)     // ['祭祀', '祈福', ...]
console.log(huangLi.avoid)        // ['动土', '破土', ...]
console.log(huangLi.luckyGod)     // 天德 月德
console.log(huangLi.evilGod)      // 月破 大耗
console.log(huangLi.fiveElements) // 金木
console.log(huangLi.star)         // 青龙

// 获取活动解释
const explanation = HuangLiService.getActivityExplanation('嫁娶')
console.log(explanation) // 举行婚礼，男娶女嫁
```

### 功能特点
- ✅ 基于传统历法计算
- ✅ 提供宜忌建议
- ✅ 提供吉神凶神
- ✅ 提供五行属性
- ✅ 提供值日星神
- ✅ 提供活动解释

---

## 💬 名言服务 (QuoteService)

### 数据来源
- **经典电影**: 《阿甘正传》《楚门的世界》等
- **哲学著作**: 尼采、罗曼·罗兰、苏格拉底等
- **文学作品**: 纪伯伦、莎士比亚、林清玄等
- **历史名人**: 爱因斯坦、丘吉尔、孔子等

### 使用方法

```typescript
import { QuoteService } from '../services/QuoteService'

// 获取随机名言
const quote = QuoteService.getRandomQuote()
console.log(quote.content)   // 名言内容
console.log(quote.author)    // 作者
console.log(quote.category)  // 分类
console.log(quote.source)    // 详细来源

// 根据分类获取名言
const lifeQuote = QuoteService.getQuoteByCategory('人生')

// 获取所有分类
const categories = QuoteService.getAllCategories()

// 搜索名言
const results = QuoteService.searchQuotes('人生')

// 获取数据来源说明
const info = QuoteService.getDataSourceInfo()
```

### 功能特点
- ✅ 所有名言均标注出处
- ✅ 来源可追溯、可核实
- ✅ 支持分类查询
- ✅ 支持关键词搜索
- ✅ 提供详细来源信息

---

## 📊 数据来源对比

| 服务 | 原数据来源 | 新数据来源 | 准确性 |
|------|-----------|-----------|--------|
| 天气数据 | 模拟数据 | 和风天气API | ⭐⭐⭐⭐⭐ |
| 农历日期 | 简化算法 | HarmonyOS API | ⭐⭐⭐⭐⭐ |
| 节气数据 | 固定日期 | HarmonyOS API | ⭐⭐⭐⭐⭐ |
| 黄历宜忌 | 随机生成 | 传统历法计算 | ⭐⭐⭐⭐ |
| 名言数据 | 未标注出处 | 标注详细出处 | ⭐⭐⭐⭐⭐ |

---

## ⚠️ 注意事项

### 天气API
1. **API Key**: 必须申请并配置API Key才能使用
2. **网络权限**: 必须在module.json5中配置网络权限
3. **调用限制**: 免费订阅1000次/天，注意控制调用频率
4. **错误处理**: API调用失败时会返回null，需要处理异常情况

### 农历API
1. **系统依赖**: 依赖HarmonyOS系统的i18n.Calendar API
2. **版本要求**: 需要HarmonyOS API 9及以上版本
3. **时区影响**: 农历日期受时区影响，使用时注意时区设置

### 黄历数据
1. **文化参考**: 黄历宜忌是中国传统文化的一部分，仅供参考
2. **实际应用**: 实际应用中应结合现代生活实际情况
3. **算法简化**: 当前使用简化算法，未来可接入更精确的专业历法

---

## 🔄 迁移指南

### 从旧代码迁移

1. **天气数据**
   ```typescript
   // 旧代码（模拟数据）
   this.weather = '小雨'
   this.temperature = '33°C'
   
   // 新代码（官方API）
   const cityId = WeatherService.getCityId('广州')
   const weather = await WeatherService.getNowWeather(cityId)
   if (weather) {
     this.weather = weather.weather
     this.temperature = weather.temperature
   }
   ```

2. **农历日期**
   ```typescript
   // 旧代码（简化算法）
   const lunarMonth = month - 1
   const lunarDay = day - 1
   
   // 新代码（官方API）
   const lunarDate = LunarService.getLunarDate()
   this.lunarDate = `${lunarDate.month}${lunarDate.day}`
   this.lunarYear = lunarDate.year
   ```

3. **节气数据**
   ```typescript
   // 旧代码（固定日期）
   this.solarTerm = '立春'
   
   // 新代码（官方API）
   const solarTerm = LunarService.getCurrentSolarTerm()
   this.solarTerm = solarTerm.name
   ```

4. **黄历宜忌**
   ```typescript
   // 旧代码（随机生成）
   this.suitableActivities = suitableList[dayOfWeek].join(' ')
   
   // 新代码（传统历法）
   const huangLi = HuangLiService.getHuangLiData()
   this.suitableActivities = huangLi.suitable.join(' ')
   this.avoidActivities = huangLi.avoid.join(' ')
   ```

5. **名言数据**
   ```typescript
   // 旧代码（未标注出处）
   this.quote = quotes[randomIndex][0]
   this.quoteAuthor = quotes[randomIndex][1]
   
   // 新代码（标注详细出处）
   const quote = QuoteService.getRandomQuote()
   this.quote = quote.content
   this.quoteAuthor = `${quote.author} - ${quote.source}`
   ```

---

## 📞 技术支持

如有问题，请参考：
- 和风天气API文档: https://dev.qweather.com/
- HarmonyOS i18n API: https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-i18n-V5
- 中国传统历法: 《协纪辨方书》等典籍
