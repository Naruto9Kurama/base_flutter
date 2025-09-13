import 'package:get_it/get_it.dart';
import '../api/dio_client.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
final getIt = GetIt.instance;

/// 注册全局依赖
void setupDI() {
  // Dio 单例
  getIt.registerLazySingleton(() => DioClient.dio);

  // ThemeProvider 单例
  // getIt.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  getIt.registerSingleton<ThemeProvider>(ThemeProvider());
  // LocaleProvider 单例
  getIt.registerLazySingleton<LocaleProvider>(() => LocaleProvider());

  // Retrofit 客户端
  // getIt.registerLazySingleton(() => RestClient(getIt()));
  //
  // // Repository
  // getIt.registerLazySingleton(() => PostRepository(getIt()));
}
