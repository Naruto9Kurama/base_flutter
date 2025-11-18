import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  var reqHandle = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addHandler(proxyRequestHandler);

  var server = await shelf_io.serve(reqHandle, '0.0.0.0', 8005);

  print('Serving at http://${server.address.host}:${server.port}');
  print('代理格式: http://localhost:8080/[scheme]/[host]/[path]');
  print('示例: http://localhost:8080/https/api.github.com/users');
}

/// CORS 中间件
Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // 处理 OPTIONS 预检请求
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Max-Age': '86400',
        });
      }

      final response = await handler(request);

      // 为所有响应添加 CORS 头
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Expose-Headers': '*',
      });
    };
  };
}

/// 代理请求处理器
Future<Response> proxyRequestHandler(Request request) async {
  try {
    // 解析路径格式: /scheme/host/path?query
    // 例如: /https/api.github.com/users?page=1
    final path = request.url.path;
    
    if (path.isEmpty) {
      return Response.ok('反向代理服务器运行中\n使用格式: /[scheme]/[host]/[path]');
    }

    // 分割路径
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    
    if (segments.length < 2) {
      return Response.badRequest(
        body: '错误的代理格式。正确格式: /[scheme]/[host]/[path]\n'
              '示例: /https/api.github.com/users'
      );
    }

    // 提取 scheme 和 host
    final scheme = segments[0]; // http 或 https
    final host = segments[1];
    
    // 验证 scheme
    if (scheme != 'http' && scheme != 'https') {
      return Response.badRequest(body: 'scheme 必须是 http 或 https');
    }

    // 提取路径部分
    final targetPath = segments.length > 2 
        ? '/' + segments.sublist(2).join('/')
        : '/';
    
    // 构建目标 URL
    final queryString = request.url.query.isNotEmpty 
        ? '?${request.url.query}' 
        : '';
    final targetUrl = '$scheme://$host$targetPath$queryString';

    print('代理请求: ${request.method} $targetUrl');

    // 转发请求
    final client = http.Client();
    
    try {
      // 读取请求体（必须先读取）
      final body = await request.read().toList();
      final bodyBytes = body.expand((chunk) => chunk).toList();
      
      // 复制请求头（排除一些不需要的头）
      final headers = Map<String, String>.from(request.headers);
      headers.remove('host');
      headers.remove('connection');
      headers.remove('content-length'); // 会自动计算
      
      // 设置正确的 Host 头
      headers['host'] = host;
      
      // 确保 Content-Type 被正确传递
      if (request.headers['content-type'] != null) {
        headers['content-type'] = request.headers['content-type']!;
      }
      
      // 如果有请求体，确保 Content-Type 存在
      if (bodyBytes.isNotEmpty && !headers.containsKey('content-type')) {
        headers['content-type'] = 'application/json; charset=utf-8';
      }

      // 发送请求
      http.Response targetResponse;
      
      switch (request.method.toUpperCase()) {
        case 'GET':
          targetResponse = await client.get(
            Uri.parse(targetUrl),
            headers: headers,
          );
          break;
        case 'POST':
          targetResponse = await client.post(
            Uri.parse(targetUrl),
            headers: headers,
            body: bodyBytes.isNotEmpty ? bodyBytes : null,
          );
          break;
        case 'PUT':
          targetResponse = await client.put(
            Uri.parse(targetUrl),
            headers: headers,
            body: bodyBytes.isNotEmpty ? bodyBytes : null,
          );
          break;
        case 'DELETE':
          // DELETE 也可能有请求体
          targetResponse = await client.delete(
            Uri.parse(targetUrl),
            headers: headers,
            body: bodyBytes.isNotEmpty ? bodyBytes : null,
          );
          break;
        case 'PATCH':
          targetResponse = await client.patch(
            Uri.parse(targetUrl),
            headers: headers,
            body: bodyBytes.isNotEmpty ? bodyBytes : null,
          );
          break;
        case 'HEAD':
          targetResponse = await client.head(
            Uri.parse(targetUrl),
            headers: headers,
          );
          break;
        default:
          return Response.badRequest(body: '不支持的请求方法: ${request.method}');
      }

      // 复制响应头（排除一些可能冲突的头）
      final responseHeaders = Map<String, String>.from(targetResponse.headers);
      responseHeaders.remove('transfer-encoding');
      responseHeaders.remove('connection');
      responseHeaders.remove('content-encoding'); // 避免压缩问题

      // 返回响应
      return Response(
        targetResponse.statusCode,
        body: targetResponse.bodyBytes,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  } catch (e, stackTrace) {
    print('代理错误: $e');
    print(stackTrace);
    return Response.internalServerError(
      body: '代理请求失败: $e'
    );
  }
}