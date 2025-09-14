import 'package:base_flutter/example/repository/file/file_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../api/auth/auth_api.dart';
import '../../example/providers/file/file_provider.dart';
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

  // Retrofit: AuthApi
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<Dio>()));

  getIt.registerLazySingleton<FileRepository>(() => FileRepository());
  getIt.registerLazySingleton<FileProvider>(() => FileProvider());

  // Retrofit 客户端
  // getIt.registerLazySingleton(() => RestClient(getIt()));
  //
  // // Repository
  // getIt.registerLazySingleton(() => PostRepository(getIt()));
}
