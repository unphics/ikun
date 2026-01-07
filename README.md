

# Ikun Project

一个基于 Unreal Engine 的个人学习与实验项目。本项目不用于任何商业目的，欢迎开发者参考、借鉴或基于此延伸开发。

---

## 📦 项目结构

```plaintext
Ikun/
├── Config                  # 游戏工程的配置表
├── Ikun/                   # 主要维护开发的Unreal游戏工程
|  ├── ···                  # 其他Unreal工程的制式目录
|  ├── Content/             # Unreal工程的内容资产目录
|  |  ├── ···               # 其他美术资产
|  |  ├── Ikun              # 主要开发内容的资产目录 *
|  |  └── Script            # 游戏工程的lua脚本文件, 大部分的游戏逻辑在这里存放 *
|  └── Source               # Unreal工程的cpp代码目录
├── LICENSE                 # MIT License
├── Resource                # 美术资产源文件
└── README.md
````

---

## 🛠️ 项目依赖

* [UnLua](https://github.com/Tencent/UnLua)

  * MIT License
  * 用于 Lua 脚本逻辑及热更新功能
  * LICENSE 文件已包含在仓库
  * 源代码版权归其原作者所有

---

## ⚠️ 资产来源声明 (Asset Provenance Statement)

* 本项目中的 **源代码与自制资源** 采用 MIT License。
* **第三方媒体资源（美术、音频、模型等）** 遵循其各自的授权协议：

  * **Korean Traditional Martial Arts (Characters & Animations)**
    * **作者**: KCISA (Korea Culture Information Service Agency / 韩国文化信息服务中心)
    * **协议**: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
    * **来源**: [https://fab.com/s/67ee4349df23]
    * **说明**: 本项目使用了其提供的 3D 模型与动作捕捉数据，并将其转换为虚幻引擎格式。

  * **UE5 Starter Character / Mannequin**
    * 来自 Epic Games，使用遵守 [Unreal Engine EULA](https://www.unrealengine.com/eula)。

* **移除申请**: 如果您是资源版权所有者，发现本项目使用了您的作品且未获授权或署名不当，请通过 [GitHub Issues] 联系，我们会立即移除相关文件。

---

## ⚙️ 关于 Unreal Engine

* 本项目基于 Epic Games 官方 Unreal Engine 开发，遵守其最终用户许可协议（EULA）。
* **引擎源码及官方内容未包含在本仓库**。
* 仓库仅包含作者编写的逻辑代码与自制或合法引入的资源。
* 本项目与 Epic Games, Inc. **无关，也未获得其认可或背书**。
* “Unreal Engine” 为 Epic Games 的注册商标。

---

## 🙏 致谢与参考资料

* [Tencent UnLua](https://github.com/Tencent/UnLua)
* 博客园、Zenn 等技术文章
* [Google Gemini](https://aistudio.google.com/) 逻辑优化与技术文档建议
* ChatGPT (GPT-4) 逻辑优化与技术文档建议

---

## 📄 License

本项目自制代码与资源采用 **MIT License**，详见 LICENSE 文件。
第三方资源版权归其各自所有，请遵守其许可协议。
UE Starter Character / Mannequin 使用遵守 Unreal Engine EULA。

---

如有疑问或建议，欢迎通过 GitHub Issues 联系。

话说可以问一下你们都看的哪部分吗？纯好奇ヽ(゜Q。)ノ

---