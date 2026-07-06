# ![Flow logo](logo@32.png) Flow

[![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-sadespresso-f5ccff?logo=buy-me-a-coffee&logoColor=white&style=for-the-badge)](https://buymeacoffee.com/sadespresso)
[![Website](https://img.shields.io/badge/Website-flow.gege.mn-f5ccff?style=for-the-badge)](https://flow.gege.mn)&nbsp;

## 前言

![Flow logo](logo@16.png) Flow 是一款免费、开源且非常简洁的费用追踪器——专注于提供出色的用户体验，支持完全离线工作，并在各个平台无缝运行。

## 下载 Flow（测试版）

[![Google Play Store](https://img.shields.io/badge/Google_Play_Store-beta-f5ccff?logo=google-play&logoColor=white&style=for-the-badge)](https://play.google.com/store/apps/details?id=mn.flow.flow)
[![App Store](https://img.shields.io/badge/App_Store-beta-f5ccff?logo=appstore&logoColor=white&style=for-the-badge)](https://apps.apple.com/mn/app/flow-expense-tracker/id6477741670)
[![Obtanium](https://img.shields.io/badge/Obtainium-beta-f5ccff?logo=obtainium&logoColor=white&style=for-the-badge)](https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/%7B%22id%22%3A%22mn.flow.flow%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2Fflow-mn%2Fflow%22%2C%22author%22%3A%22flow-mn%22%2C%22name%22%3A%22Flow%22%2C%22preferredApkIndex%22%3A0%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Afalse%2C%5C%22fallbackToOlderReleases%5C%22%3Atrue%2C%5C%22filterReleaseTitlesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22filterReleaseNotesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22verifyLatestTag%5C%22%3Afalse%2C%5C%22sortMethodChoice%5C%22%3A%5C%22date%5C%22%2C%5C%22useLatestAssetDateAsReleaseDate%5C%22%3Afalse%2C%5C%22releaseTitleAsVersion%5C%22%3Afalse%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionExtractionRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22matchGroupToUse%5C%22%3A%5C%22%5C%22%2C%5C%22versionDetection%5C%22%3Atrue%2C%5C%22releaseDateAsVersion%5C%22%3Afalse%2C%5C%22useVersionCodeAsOSVersion%5C%22%3Afalse%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22invertAPKFilter%5C%22%3Afalse%2C%5C%22autoApkFilterByArch%5C%22%3Atrue%2C%5C%22appName%5C%22%3A%5C%22%5C%22%2C%5C%22appAuthor%5C%22%3A%5C%22%5C%22%2C%5C%22shizukuPretendToBeGooglePlay%5C%22%3Afalse%2C%5C%22allowInsecure%5C%22%3Afalse%2C%5C%22exemptFromBackgroundUpdates%5C%22%3Afalse%2C%5C%22skipUpdateNotifications%5C%22%3Afalse%2C%5C%22about%5C%22%3A%5C%22%5C%22%2C%5C%22refreshBeforeDownload%5C%22%3Afalse%7D%22%2C%22overrideSource%22%3Anull%7D)

> 支持针对 Linux 和 macOS 构建和运行。尚未在 Windows 上测试[^2]

## 用 Eny 为 Flow 赋能：AI 小票解析器

我也开发了一个基于 AI 的小票解析器。给你的收据拍张照（是的，可以直接在 Flow 中拍摄），它就会被添加到记录里。去看看吧：<https://eny.gege.mn/>

<!-- markdownlint-disable-next-line -->
<a href="https://eny.gege.mn">
  <!-- markdownlint-disable-next-line -->
  <picture>
    <!-- markdownlint-disable-next-line -->
    <source srcset="https://cdn.gege.mn/eny/2026-02-28/5b374d28-43d5-4276-a7b2-dab81ea684be/fxe.png 1x, https://cdn.gege.mn/eny/2026-02-28/5b374d28-43d5-4276-a7b2-dab81ea684be/fxe@2x.png 2x, https://cdn.gege.mn/eny/2026-02-28/5b374d28-43d5-4276-a7b2-dab81ea684be/fxe@3x.png 3x">
    <!-- markdownlint-disable-next-line -->
    <img src="https://cdn.gege.mn/eny/2026-02-28/5b374d28-43d5-4276-a7b2-dab81ea684be/fxe.png" alt="Supercharged by Eny: Parse receipts straight from Flow" width="440">
  </picture>
</a>

## 功能特点

* 极致简单的用户体验，助你高效追踪财务状况
* 无限账户和币种（包括各种加密货币）
* 支持分类、标签、文件附件、地理位置标记（可选）
* 反思你的支出
* 完全离线[^1]
* 完全掌控你的数据
  * 无追踪器，无分析工具
  * 可完全恢复的备份（ZIP/JSON 格式）
  * 导出 CSV、PDF 文件
  * 定期自动备份到 iCloud
* 完全免费（[可以考虑打赏一下 🥺](#支持-flow)）
* [基于 URI 的自动化](#基于-uri-的自动化)

## 基于 URI 的自动化

你可以使用 `flow-mn` schema 的 URI 来添加一笔或多笔交易。

查看 schemas 文件夹中支持的 [JSON Schema 文件](./schemas/programmable-object.json)。

货币类型取决于账户，目前暂时无法单独指定货币。

### 添加单笔交易

添加单笔交易时，属性必须作为查询参数（query params）提供。

```json
{
  "title": "Tous les jours",
  "amount": 42000.00
}
```

转换为：

```plain
flow-mn:///transaction/new?title=Tous+les+jours&amount=42000.00
```

### 添加多笔交易

添加多笔交易时，你必须提供以下内容的字符串化版本，作为 `json` 查询参数。

```json
{
  "t": [
    {
      "title": "Fresh blueberry piece",
      "amount": "13000.00",
      "transactionDate": "2011-12-05",
      "category": "Food",
      "tags": "My fave cafe",
      "accountUuid": "faa6d523-277f-46af-9493-67768e5b48ab"
    },
    {
      "title": "Caffe Mocha ice",
      "amount": "10000.00",
      "transactionDate": "2011-12-05",
      "category": "Drinks"
    }
  ]
}
```

转换为：

```plain
flow-mn:///transaction/new?json=%7B%22t%22%3A%5B%7B%22title%22%3A%22Fresh%20blueberry%20piece%22%2C%22amount%22%3A%2213000.00%22%2C%22transactionDate%22%3A%222011-12-05%22%2C%22category%22%3A%22Food%22%7D%2C%7B%22title%22%3A%22Caffe%20Mocha%20ice%22%2C%22amount%22%3A%2210000.00%22%2C%22transactionDate%22%3A%222011-12-05%22%2C%22category%22%3A%22Drinks%22%7D%5D%7D
```

## 开发

在贡献代码前，请先阅读 [贡献指南](./CONTRIBUTING.md) 和 [行为准则](./CODE_OF_CONDUCT.md)。

### 先决条件

* [Flutter](https://flutter.dev/) (最新的稳定版)

其他：

* 如果打算构建 Android 版本，需要 JDK 11 或更高版本
* 如果打算构建 iOS/macOS 版本，需要 [XCode](https://developer.apple.com/xcode/)
* 如果想在本地机器上运行测试，请查看 [测试](#测试)

为 Windows、macOS 和基于 Linux 的系统进行构建与 Flutter 需要相同的依赖项。请在 <https://docs.flutter.dev/platform-integration> 上阅读更多信息。

### 测试

如果你打算在本地机器上运行测试，请确保已经安装了 ObjectBox 的动态库。

安装 ObjectBox 动态库[^3]：

`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)`

使用以下命令运行测试：`flutter test`

## 支持 Flow

Flow 是我在业余时间开发的个人项目，它不会产生任何收入。你可以考虑资助 Flow！以下是一些建议：

* 在应用商店留下你的评论
* 推荐给朋友
* [请我喝杯咖啡](https://buymeacoffee.com/sadespresso)
  <!-- markdownlint-disable-next-line -->
  <a href="https://www.buymeacoffee.com/sadespresso"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=☕&slug=sadespresso&button_colour=BD5FFF&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00" /></a>
  
维持 Flow 在 App Store 的上架需要一笔不小的年度费用（参考 [Apple 开发者计划](https://developer.apple.com/support/enrollment/#:~:text=The%20Apple%20Developer%20Program%20annual,in%20local%20currency%20where%20available.)），目前这笔费用由我承担。为了保证 Flow 能够继续存在和后续开发，如果你能提供支持，我将感激不尽。

感谢所有贡献者、支持者、测试人员以及所有间接提供过帮助的人 🤍

## 支持语言列表

* 阿拉伯语 - 感谢 [Ultrate](https://github.com/Ultrate)
* 英语
* 法语 (法国)
* 德语 (德国) - 感谢 [MarkusWangler](https://github.com/MarkusWangler)
* 意大利语 (意大利) - 感谢 [albertorizzi](https://github.com/albertorizzi)
* 蒙古语 (蒙古)
* 俄语 (俄罗斯)
* 西班牙语 (西班牙)
* 土耳其语 (土耳其) - 感谢 [NoRiskNoViski](https://github.com/NoRiskNoViski)
* 乌克兰语 (乌克兰)
* 捷克语 (捷克) - 感谢 **Miloš Koliáš** 邮件支持

> 如果你想将 Flow 翻译成你的语言，请查看 [翻译指南](./CONTRIBUTING.md#translating)

<!-- markdownlint-disable-next-line -->
<!-- <a href="https://www.producthunt.com/posts/flow-2cbe921f-2ed9-4ed1-b8d7-26dff1c2c49d?embed=true&utm_source=badge-top-post-badge&utm_medium=badge&utm_souce=badge-flow&#0045;2cbe921f&#0045;2ed9&#0045;4ed1&#0045;b8d7&#0045;26dff1c2c49d" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=955354&theme=light&period=daily&t=1745222977391" alt="Flow - A&#0032;FOSS&#0032;expense&#0032;tracker&#0032;that&#0032;focuses&#0032;on&#0032;privacy&#0032;and&#0032;UX | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a> -->

[^1]: Flow 仅需要网络连接来下载汇率。只有在使用多种货币时才需要。

[^2]: 桌面体验 UI 暂未做针对性优化，但未来将支持 macOS、Windows 和基于 Linux 的系统。

[^3]: 请到官方网站二次确认，脚本可能会过期。访问 <https://docs.objectbox.io/getting-started#add-objectbox-to-your-project> （确保选择 Flutter 才能看到相应的脚本）。
