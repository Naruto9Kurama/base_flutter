## 目标 & 快速说明
本文件为 AI 编码代理（Copilot/Agent）提供最重要、可立即上手的上下文：项目结构要点、开发/构建/生成命令、常见约定和在修改代码时必须遵守的守则。

## 关键事实（快速扫读）
- 框架：Flutter (多平台：android/ios/web/linux/macos/windows)。主要入口：`lib/main.dart`。
- 路由：基于 `go_router`，路由配置在 `lib/app_router.dart`（新增页面需在此注册）。
- 依赖注入：使用 `get_it` + `injectable`（配置/初始化在 `lib/core/di/injection.dart` 与 `configureDependencies()`；在 `lib/main.dart` 中调用）。
- 本地存储：使用 `hive_ce`，生成的注册器在 `lib/hive_registrar.g.dart`（不要手动编辑生成文件）。
- 本地化：使用 `easy_localization`，翻译资源在 `assets/translations/`（`en.json`, `zh.json`）。
- 媒体：项目使用 `media_kit` / `fvp`，需要早期初始化（见 `lib/main.dart` 中的 MediaKit 初始化逻辑）。Android 还依赖 `media_kit_libs_android_video` 原生库。

## 重要构建/生成/运行命令（必须记住并在修改注解/生成器后运行）
- 代码生成（在修改注解后，必跑）：
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  # 或
  dart run build_runner build --delete-conflicting-outputs
  ```
- 本地 web 开发（项目自带脚本）：
  ```bash
  ./start-web-dev.sh
  # 或手动：
  dart ./lib/core/proxy.dart & flutter run -d web-server --web-port 8080
  ```
- 编译 APK：
  ```bash
  flutter build apk
  ```

## 编辑 / 提交 改动时的规则（非常重要）
- 切勿修改任何 `*.g.dart`, `*.injectable.json`, `*.retrofit.g.part` 等由 build_runner 生成的文件；改动应通过源码注解完成，然后运行 build_runner。
- 新增可注入类：在源码中添加 `@injectable`/`@module` 等注解并在 `lib/core/di/` 的注入配置中保持一致，然后运行 build_runner。页面类如果需通过 `get_it` 以带参数方式注入（factoryParam），请参考 `lib/main.dart` 中的 `getIt.registerFactoryParam` 示例并在 `lib/app_router.dart` 中注册路由。
- 新增 Hive 类型：添加 model 并运行 `hive_ce_generator`，不要手动修改 `hive_registrar.g.dart`，运行生成器会更新适配器注册。

## 常见改动示例（如何做）
- 新增页面
  1. 在 `lib/example/pages/...` 下添加页面类。
  2. 在 `lib/main.dart` 的 `configureDependencies` 中用 `getIt.registerFactoryParam<YourPage, Key?, void>(...)` 注册（参见已有页面注册）。
  3. 在 `lib/app_router.dart` 添加相应 `GoRoute`。
  4. 运行 build_runner（如果新增了注解或生成器依赖）。

- 新增 API 客户端（retrofit）
  1. 在 `lib/core/api/` 下新增接口并使用 `@RestApi` 注解。
  2. 运行 `retrofit_generator`（通过 build_runner）来生成实现。

## 代码风格与静态检查
- 项目启用了 `flutter_lints`（参见 `analysis_options.yaml`）。遵循现有 lint，避免全局禁用规则；若需要特殊忽略，优先在行/文件层面添加 `// ignore:` 注释并加注释说明原因。

## 关键文件一览（参考）
- `lib/main.dart` — 应用入口，初始化 DI、Hive、MediaKit、localization，以及 `MyApp`。
- `lib/app_router.dart` — 全局路由定义（go_router）。
- `lib/core/di/injection.dart` — DI 辅助与注入点。
- `lib/hive_registrar.g.dart` — Hive 生成适配器注册（生成文件，不要编辑）。
- `assets/translations/` — 本地化资源。
- `pubspec.yaml` — 列出所有生成器与依赖（注意 `generate: true`）。
- `start-web-dev.sh`, `install.sh` — 项目提供的辅助脚本（参考 README）。

## 调试与平台注意事项
- MediaKit/FVP：在 `main()` 里尽早调用 `fvp.registerWith()` / `MediaKit.ensureInitialized()`，如果修改与媒体相关的 native 插件或依赖，需关注原生库（Android 的 `media_kit_libs_android_video`）是否正确打包。
- 代理：项目通过 `assets/config/config.json`（或 `AppConfig`）支持代理配置；`lib/main.dart` 中示例展示如何根据平台（web/android/ios）启用代理。

## 不要做 / 限制
- 不要直接改动生成的 `*.g.dart` / `*.freezed.dart` / `*.json_serializable.g.part` 文件。所有改动应通过源文件注解或生成器配置完成。

## 还有问题？
如果你需要更深入的调用点或想让我把某个子系统（比如 API 层、视频播放流或 DI 配置）拆解成更详细的「小步骤清单」，告诉我想要修改的目标模块和我会生成具体的代码修改/测试步骤。
