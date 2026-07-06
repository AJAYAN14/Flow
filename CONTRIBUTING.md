# 参与贡献 Flow

感谢你的驻足！有很多方式可以帮助我们将 Flow 变得更好。以下是一些建议：

* 报告 Bug
* 提出新功能建议
* [贡献代码](#开发)
* [将 Flow 翻译](#翻译)成你自己的语言
* [请维护者喝杯咖啡](https://buymeacoffee.com/sadespresso)。Flow 是一款免费且开源的软件，并且会一直保持下去。

## 开发

注意：在开始之前进行简短的讨论，可以提前发现潜在问题、简化代码合并流程，并确保你的方向正确，从而避免返工。

提示：寻找带有 `ready` 标签的 issue，可以让你零门槛快速上手。

1. Fork 本仓库
2. 挑选一个 issue。如果你要修复或开发的功能还没有 issue，请先创建一个。
3. 在 issue 下评论“I'm working on it”（我正在处理），让大家知道你正在进行这项工作。
4. 创建一个特性分支（feature branch）。例如，你可以创建一个名为 `username/fix` 的分支（基于 `develop` 分支创建）。分支名称也可以不同，这无关紧要。
5. 在新分支上进行修改。
6. 确保你的代码没有任何 linter 警告或错误（你的编辑器会提示你，或者你可以运行 `flutter analyze`）。
7. 向 `develop` 分支提交 PR (Pull Request)。
8. 如果你的功能涉及 UI 更改，请添加一段简短的视频来演示实现的变化或功能。

## 代码规范指南

* 在实现新功能之前，请考虑可访问性（accessibility）、本地化（localization）以及技术因素。
* 任何新引入的依赖项都必须支持除 Web 之外的所有平台。
* 除非你负责发布新版本，否则不需要修改版本号。
* 在 [CHANGELOG.md](./CHANGELOG.md) 中更新你的修改说明。（使用版本名 `next`）。

## 翻译

将 Flow 翻译成你的语言时，翻译覆盖率必须达到 100%。

你可以遵循与 [开发](#开发) 相同的步骤，并且可以安全地跳过代码检查和测试（第 6 步和第 7 步）。

强烈建议复制 [en_US.json](./assets/l10n/en.json) 或任何其他已经具备 100% 覆盖率的现有翻译文件，并在此基础上进行修改。

确保将你的语言添加到支持的语言列表中。请参考 [lib/l10n/supported_languages.dart](./lib/l10n/supported_languages.dart)。

## 许可证

通过贡献代码，即表示你同意你的贡献将基于 GNU GENERAL PUBLIC LICENSE v3 进行许可。
