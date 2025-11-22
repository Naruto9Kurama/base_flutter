import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DioClient {
  final Dio dio;
  String? _proxyPrefix;

  DioClient()
      : dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json, // 添加这行，确保自动解析 JSON
            contentType: Headers.jsonContentType, // 添加这行
          ),
        ) {
    // 添加拦截器处理代理前缀
    dio.interceptors.add(ProxyInterceptor(this));
    
    // 添加响应拦截器处理 JSON 解析问题
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // 如果响应是字符串，手动解析为 JSON
          print('原始数据: ${response.data}');
          if (response.data is String) {
            try {
              response.data = json.decode(response.data);
            } catch (e) {
              print('JSON 解析错误: $e');
              print('原始数据: ${response.data}');
            }
          }
          return handler.next(response);
        },
        onRequest: (options, handler) {
          // 请求日志（可选）
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          // 错误日志（可选）
          print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
          if (error.response?.data != null) {
            print('ERROR DATA: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
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