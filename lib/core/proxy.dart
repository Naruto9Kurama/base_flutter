import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  final router = Router();

  // 根路径
  router.get('/', (Request request) {
    return Response.ok('''
视频代理服务器运行中

支持的功能：
1. 通用代理: /[scheme]/[host]/[path]
   示例: /https/api.github.com/users

2. 视频代理（query方式）: /video/proxy?url=<视频URL>
   示例: /video/proxy?url=https://example.com/video.mp4

3. M3U8代理: /video/m3u8?url=<M3U8_URL>
   示例: /video/m3u8?url=https://example.com/playlist.m3u8

4. 健康检查: /health
''');
  });

  // 健康检查
  router.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // 视频代理路由（query 参数方式）
  router.get('/video/proxy', videoProxyHandler);
  
  // M3U8 代理路由
  router.get('/video/m3u8', m3u8ProxyHandler);

  // 通用代理路由（原有功能）
  router.all('/<scheme>/<host|[^/]+>/<path|.*>', generalProxyHandler);

  var reqHandle = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router);

  var server = await shelf_io.serve(reqHandle, '0.0.0.0', 8005);

  print('🚀 视频代理服务器运行在 http://${server.address.host}:${server.port}');
  print('');
  print('📹 视频代理: http://localhost:8005/video/proxy?url=<视频URL>');
  print('📺 M3U8代理: http://localhost:8005/video/m3u8?url=<M3U8_URL>');
  print('🔄 通用代理: http://localhost:8005/[scheme]/[host]/[path]');
  print('');
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
        'Access-Control-Expose-Headers': 'Content-Length, Content-Range, Accept-Ranges, Content-Type',
      });
    };
  };
}

/// 视频代理处理器
Future<Response> videoProxyHandler(Request request) async {
  try {
    final videoUrl = request.url.queryParameters['url'];

    if (videoUrl == null || videoUrl.isEmpty) {
      return Response.badRequest(
        body: '缺少 url 参数\n使用方式: /video/proxy?url=<视频URL>'
      );
    }

    print('📹 代理视频: $videoUrl');

    // 获取 Range 请求头（用于视频分段加载）
    final rangeHeader = request.headers['range'];

    // 创建 HTTP 客户端
    final client = http.Client();

    try {
      // 构建请求头
      final headers = <String, String>{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'identity', // 不使用压缩，保持原始格式
        'Connection': 'keep-alive',
      };

      // 添加 Range 头（如果有）
      if (rangeHeader != null) {
        headers['Range'] = rangeHeader;
      }

      // 发送请求
      final targetRequest = http.Request('GET', Uri.parse(videoUrl));
      targetRequest.headers.addAll(headers);

      final streamedResponse = await client.send(targetRequest);

      // 构建响应头
      final responseHeaders = <String, String>{
        'Content-Type': streamedResponse.headers['content-type'] ?? 'video/mp4',
      };

      // 转发重要的响应头
      final headersToForward = [
        'content-length',
        'content-range',
        'accept-ranges',
        'last-modified',
        'etag',
        'cache-control',
      ];

      for (final header in headersToForward) {
        final value = streamedResponse.headers[header];
        if (value != null) {
          responseHeaders[header] = value;
        }
      }

      // 如果没有 Accept-Ranges，添加默认值
      if (!responseHeaders.containsKey('accept-ranges')) {
        responseHeaders['accept-ranges'] = 'bytes';
      }

      print('✅ 视频代理成功: ${streamedResponse.statusCode}');

      // 流式返回视频数据
      return Response(
        streamedResponse.statusCode,
        body: streamedResponse.stream,
        headers: responseHeaders,
      );
    } finally {
      // 注意：不要在这里关闭 client，因为流还在传输
      // client.close(); 
    }
  } catch (e, stackTrace) {
    print('❌ 视频代理错误: $e');
    print(stackTrace);
    return Response.internalServerError(
      body: '视频代理失败: $e'
    );
  }
}

/// M3U8 代理处理器
Future<Response> m3u8ProxyHandler(Request request) async {
  try {
    final m3u8Url = request.url.queryParameters['url'];

    if (m3u8Url == null || m3u8Url.isEmpty) {
      return Response.badRequest(
        body: '缺少 url 参数\n使用方式: /video/m3u8?url=<M3U8_URL>'
      );
    }

    print('📺 代理 M3U8: $m3u8Url');

    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(m3u8Url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
        },
      );

      if (response.statusCode != 200) {
        return Response(
          response.statusCode,
          body: 'M3U8 获取失败: ${response.statusCode}'
        );
      }

      // 解析 M3U8 内容
      String m3u8Content = response.body;

      // 获取 M3U8 的 base URL
      final uri = Uri.parse(m3u8Url);
      final baseUrl = '${uri.scheme}://${uri.host}${uri.path.substring(0, uri.path.lastIndexOf('/') + 1)}';

      // 处理 M3U8 文件中的相对路径
      // 将相对路径的 .ts 和 .m3u8 文件转换为绝对路径
      m3u8Content = m3u8Content.replaceAllMapped(
        RegExp(r'^(?!#|http)(.*\.(ts|m3u8|key))$', multiLine: true),
        (match) {
          final relativePath = match.group(1)!;
          final absoluteUrl = '$baseUrl$relativePath';
          
          // 如果是 .ts 文件，也通过代理
          if (relativePath.endsWith('.ts')) {
            final encodedUrl = Uri.encodeComponent(absoluteUrl);
            return 'http://kurama-server:14056/video/proxy?url=$encodedUrl';
          }
          
          return absoluteUrl;
        },
      );

      print('✅ M3U8 代理成功');

      return Response.ok(
        m3u8Content,
        headers: {
          'Content-Type': 'application/vnd.apple.mpegurl',
          'Content-Length': m3u8Content.length.toString(),
        },
      );
    } finally {
      client.close();
    }
  } catch (e, stackTrace) {
    print('❌ M3U8 代理错误: $e');
    print(stackTrace);
    return Response.internalServerError(
      body: 'M3U8 代理失败: $e'
    );
  }
}

/// 通用代理请求处理器（原有功能）
Future<Response> generalProxyHandler(Request request) async {
  try {
    final scheme = request.params['scheme'];
    final host = request.params['host'];
    final path = request.params['path'] ?? '';

    // 验证 scheme
    if (scheme != 'http' && scheme != 'https') {
      return Response.badRequest(body: 'scheme 必须是 http 或 https');
    }

    // 构建目标 URL
    final targetPath = path.isEmpty ? '/' : '/$path';
    final queryString = request.url.query.isNotEmpty 
        ? '?${request.url.query}' 
        : '';
    final targetUrl = '$scheme://$host$targetPath$queryString';

    print('🔄 通用代理: ${request.method} $targetUrl');

    final client = http.Client();

    try {
      // 读取请求体
      final body = await request.read().toList();
      final bodyBytes = body.expand((chunk) => chunk).toList();

      // 复制请求头
      final headers = Map<String, String>.from(request.headers);
      headers.remove('host');
      headers.remove('connection');
      headers.remove('content-length');
      headers['host'] = host!;

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

      // 复制响应头
      final responseHeaders = Map<String, String>.from(targetResponse.headers);
      responseHeaders.remove('transfer-encoding');
      responseHeaders.remove('connection');
      responseHeaders.remove('content-encoding');

      return Response(
        targetResponse.statusCode,
        body: targetResponse.bodyBytes,
        headers: responseHeaders,
      );
    } finally {
      client.close();
    }
  } catch (e, stackTrace) {
    print('❌ 通用代理错误: $e');
    print(stackTrace);
    return Response.internalServerError(
      body: '代理请求失败: $e'
    );
  }
}