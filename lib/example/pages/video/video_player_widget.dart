// video_player_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool useProxy;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = false,
    this.useProxy = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Web 平台格式检查（仅在未使用代理时）
      if (kIsWeb && !widget.useProxy && !_isWebSupportedFormat(widget.videoUrl)) {
        throw Exception(
          '⚠️ Web 平台不直接支持此格式\n\n'
          '建议解决方案：\n'
          '1. 启用代理模式（点击右上角图标）\n'
          '2. 切换到 MP4/WebM 播放源\n'
          '3. 使用移动端 App 播放'
        );
      }

      // 创建视频控制器
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
          'Origin': kIsWeb ? Uri.base.origin : '',
        },
      );

      _videoPlayerController.addListener(_videoListener);

      await _videoPlayerController.initialize().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ 视频加载超时\n\n请检查：\n• 网络连接\n• 视频 URL 是否有效\n• 是否需要启用代理');
        },
      );

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white70,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white70,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('缓冲中...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _videoListener() {
    if (_videoPlayerController.value.hasError) {
      final error = _videoPlayerController.value.errorDescription;
      if (mounted && error != null) {
        setState(() {
          _errorMessage = _parseCorsError(error);
        });
      }
    }
  }

  String _parseCorsError(String error) {
    if (error.contains('CORS') || 
        error.contains('SRC_NOT_SUPPORTED') ||
        error.contains('Format error')) {
      return '🚫 CORS 跨域访问被阻止\n\n'
             '这是 Web 浏览器的安全限制。\n\n'
             '解决方法：\n'
             '${widget.useProxy ? "• 代理已启用但仍失败，请检查代理配置\n" : "• 点击右上角图标启用代理模式\n"}'
             '• 联系管理员在服务器配置 CORS\n'
             '• 使用移动端 App（无跨域限制）\n'
             '• 切换到其他播放源\n\n'
             '原始错误: $error';
    }
    return error;
  }

  bool _isWebSupportedFormat(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.mp4') ||
           lower.contains('.webm') ||
           lower.contains('.m3u8') ||
           lower.contains('.ogg');
  }

  Widget _buildErrorWidget(String errorMessage) {
    final isCorsError = errorMessage.contains('CORS') || 
                        errorMessage.contains('SRC_NOT_SUPPORTED');
    
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorsError ? Icons.block : Icons.error_outline,
                color: isCorsError ? Colors.orange : Colors.red,
                size: 64,
              ),
              SizedBox(height: 20),
              Text(
                isCorsError ? 'CORS 跨域问题' : '播放失败',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isCorsError ? Colors.orange : Colors.red)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isCorsError ? Colors.orange : Colors.red)
                        .withOpacity(0.5),
                  ),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: Icon(Icons.refresh),
                label: Text('重新加载'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                '正在加载视频...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (widget.useProxy)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '🔐 通过代理加载',
                    style: TextStyle(color: Colors.green.shade300, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(_errorMessage!);
    }

    return _chewieController != null
        ? Chewie(controller: _chewieController!)
        : Container(
            color: Colors.black,
            child: Center(
              child: Text(
                '初始化失败',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
  }
}