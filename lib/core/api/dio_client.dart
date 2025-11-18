import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';

// @LazySingleton()
// class DioClient {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 5),
//     ),
//   );

//   static Dio get dio => _dio;
// }

@LazySingleton()
class DioClient {
  final Dio dio;
  String? _proxyPrefix;

  DioClient() : dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  ) {
    // 添加拦截器处理代理前缀
    dio.interceptors.add(ProxyInterceptor(this));
  }

  /// 设置反向代理前缀
  /// [proxyPrefix] 代理服务器地址，例如: "https://your-server.com/api-proxy"
  /// 传入 null 则清除代理设置
  void setProxyPrefix(String? proxyPrefix) {
    _proxyPrefix = proxyPrefix?.replaceAll(RegExp(r'/+$'), ''); // 移除末尾斜杠
  }

  /// 获取当前代理前缀
  String? get proxyPrefix => _proxyPrefix;
}

/// 代理拦截器
class ProxyInterceptor extends Interceptor {
  final DioClient dioClient;

  ProxyInterceptor(this.dioClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final proxyPrefix = dioClient.proxyPrefix;
    
    if (proxyPrefix != null && proxyPrefix.isNotEmpty) {
      final originalUrl = options.uri.toString();
      
      // 将 https://api.example.com/users 转换为 
      // https://your-server.com/api-proxy/https/api.example.com/users
      final uri = Uri.parse(originalUrl);
      final scheme = uri.scheme; // http 或 https
      final hostAndPath = '${uri.host}${uri.path}';
      final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
      
      options.path = '$proxyPrefix/$scheme/$hostAndPath$query';
      options.baseUrl = '';
    }
    
    handler.next(options);
  }
}


// @LazySingleton()
// Dio dio() => Dio(
//   BaseOptions(
//     connectTimeout: const Duration(seconds: 5),
//     receiveTimeout: const Duration(seconds: 5),
//   ),
// );
