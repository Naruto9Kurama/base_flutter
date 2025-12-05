import 'dart:io';

import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/provider/video_player_provider.dart';
import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:base_flutter/example/features/video/respository/vod_respository.dart';
import 'package:base_flutter/example/pages/drive/drive_main_page.dart';
import 'package:base_flutter/example/pages/file/file_list_page.dart';
import 'package:base_flutter/example/pages/login/login_page.dart';
import 'package:base_flutter/example/pages/video/player/video_player_screen.dart';
import 'package:base_flutter/example/pages/video/search/video_search.dart';
import 'package:base_flutter/hive_registrar.g.dart';
import 'package:base_flutter/pages/home_page.dart';
import 'package:base_flutter/pages/tab_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart'; // 用于 Hive 存储的核心库
import 'package:hive_ce_flutter/hive_flutter.dart'; // Flutter 与 Hive 的集成
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injection.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';
import 'package:fvp/fvp.dart' as fvp;


void main() async {
  // 初始化 MediaKit 尽早执行，避免其它初始化流程中间接使用到 media_kit 导致异常
  try {
    fvp.registerWith();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
    print('MediaKit.ensureInitialized called');
  } catch (e) {
    print('MediaKit initialization failed: $e');
  }

  await EasyLocalization.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();
  // 确保适配器只注册一次
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapters(); // 这里是你注册适配器的地方
  }
  // Hive.registerAdapters();

  // 异步加载配置
  final config = await AppConfig.load();
  //手动注入配置类
  GetIt.instance.registerSingleton<AppConfig>(config);

  // setupDI(); // 注册 DI
  configureDependencies((getit) {
    //页面如果要使用getit获取，需要单独注册，不能直接用@LazySingleton()，会导致key错误
    // 每个页面 factoryParam 支持 key
    getIt.registerFactoryParam<HomePage, Key?, void>(
      (key, _) => HomePage(key: key),
    );
    getIt.registerFactoryParam<LoginPage, Key?, void>(
      (key, _) => LoginPage(key: key),
    );
    getIt.registerFactoryParam<FileListPage, Key?, void>(
      (key, _) => FileListPage(key: key),
    );
    getIt.registerFactoryParam<DriveMainScreen, Key?, void>(
      (key, _) => DriveMainScreen(key: key),
    );
    getIt.registerFactoryParam<VideoSearchPage, Key?, void>(
      (key, _) => VideoSearchPage(key: key),
    );
    getIt.registerFactoryParam<TabPage, Key?, void>(
      (key, _) => TabPage(key: key),
    );
    getIt.registerFactoryParam<VideoPlayerScreen, Key?, VideoModel>(
      (key, videoModel) =>
          VideoPlayerScreen(key: key, videoModel: videoModel),
    );

    //todo 根据配置的vod url注册实例
    // getIt.registerLazySingleton<VodRespository>(() => BaseVodRespository(baseUrl: "http://cj.ffzyapi.com/",appConfig:config),instanceName: 'feifan')
  });

  bool enableProxy = false;
  Map<String, dynamic> proxyConfig = config["proxy"];
  if (kIsWeb) {
    enableProxy = proxyConfig["web"] ?? true;
  } else if (Platform.isAndroid) {
    enableProxy = proxyConfig["android"] ?? false;
  } else if (Platform.isIOS) {
    enableProxy = proxyConfig["ios"] ?? false;
  }

  if (enableProxy && proxyConfig["url"] != null) {
    final dioClient = GetIt.instance.get<DioClient>();
    dioClient.setProxyPrefix(proxyConfig["url"]);
    print("Proxy enabled: ${proxyConfig["url"]}");
  } else {
    print("Proxy not enabled for this platform");
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
      ),
    );
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: (context, child) {
        return ChangeNotifierProvider<ThemeProvider>.value(
          value: getIt<ThemeProvider>(),
          child: Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return MaterialApp.router(
                routerConfig: appRouter,
                title: 'Flutter DI Demo',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: theme.themeMode,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
              );
            },
          ),
        );
      },
    );
  }
}
