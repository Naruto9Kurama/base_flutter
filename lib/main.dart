import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/hive_registrar.g.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart'; // 用于 Hive 存储的核心库
import 'package:hive_ce_flutter/hive_flutter.dart'; // Flutter 与 Hive 的集成
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/di/injection.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  configureDependencies();
  
  GetIt.instance.get<DioClient>().setProxyPrefix('http://kurama-server:14056');
  
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
  }
}