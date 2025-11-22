// video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:base_flutter/example/features/video/provider/video_player_provider.dart';
import 'video_player_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerProvider videoPlayerProvider;
  // 后端代理URL（Dart Shelf 代理服务器）
  final String proxyBaseUrl;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPlayerProvider,
    this.proxyBaseUrl = 'http://kurama-server:14056', // 默认本地代理
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  int _currentUrlIndex = 0;
  bool _useProxy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 监听 provider 的变化
    widget.videoPlayerProvider.addListener(_onProviderChanged);
    // 检查是否已经有数据
    _checkInitialData();
  }

  void _checkInitialData() {
    // 如果已经有播放地址，说明数据已加载完成
    if (widget.videoPlayerProvider.videoModel.playUrls.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 移除监听器
    widget.videoPlayerProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    // 当 provider 发生变化时，重新构建界面
    if (mounted) {
      setState(() {
        // 数据加载完成，关闭加载状态
        if (widget.videoPlayerProvider.videoModel.playUrls.isNotEmpty) {
          _isLoading = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playUrls = widget.videoPlayerProvider.videoModel.playUrls;
    final currentUrl = playUrls.isNotEmpty ? playUrls[_currentUrlIndex].url : '';
    
    // 如果是 Web 且启用代理，使用代理 URL
    final videoUrl = (kIsWeb && _useProxy && widget.proxyBaseUrl != null)
        ? _getProxiedUrl(currentUrl)
        : currentUrl;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.videoPlayerProvider.videoModel.title),
        material: (_, __) => MaterialAppBarData(
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          backgroundColor: Colors.black,
        ),
        trailingActions: [
          // 代理按钮已注释
          // if (kIsWeb && widget.proxyBaseUrl != null)
          //   IconButton(
          //     icon: Icon(_useProxy ? Icons.vpn_key : Icons.vpn_key_off),
          //     onPressed: () {
          //       setState(() {
          //         _useProxy = !_useProxy;
          //       });
          //     },
          //     tooltip: _useProxy ? '禁用代理' : '启用代理',
          //   ),
        ],
      ),
      body: Column(
        children: [
          // CORS 警告提示已移除

          // 视频播放器
          Container(
            height: MediaQuery.of(context).size.width * 9 / 16,
            color: Colors.black,
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '正在加载视频...',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : videoUrl.isNotEmpty
                    ? VideoPlayerWidget(
                        videoUrl: videoUrl,
                        key: ValueKey(videoUrl),
                        useProxy: _useProxy,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.white, size: 48),
                            SizedBox(height: 8),
                            Text(
                              '暂无播放地址',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
          ),
          
          // 集数列表
          if (playUrls.length > 1)
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playUrls.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentUrlIndex;
                  final playItem = playUrls[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        if (index != _currentUrlIndex) {
                          setState(() {
                            _currentUrlIndex = index;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            playItem.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 视频信息
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CORS 解决方案说明卡片已移除
                  
                  Text(
                    widget.videoPlayerProvider.videoModel.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '描述',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.videoPlayerProvider.videoModel.title ?? '暂无描述',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('当前平台', kIsWeb ? 'Web 浏览器' : 'Mobile App'),
                  _buildInfoRow('视频格式', _getVideoFormat(currentUrl)),
                  _buildInfoRow('播放源', '${_currentUrlIndex + 1}/${playUrls.length}'),
                  // 代理状态显示已移除
                  _buildInfoRow('原始 URL', _truncateUrl(currentUrl)),
                  // 代理 URL 显示已移除
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CORS 信息卡片方法已移除

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getProxiedUrl(String originalUrl) {
    if (widget.proxyBaseUrl == null) return originalUrl;
    // 将原始 URL 编码后传给代理服务器
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '${widget.proxyBaseUrl}/proxy?url=$encodedUrl';
  }

  String _getVideoFormat(String url) {
    if (url.contains('.m3u8')) return 'M3U8 (HLS)';
    if (url.contains('.mp4')) return 'MP4';
    if (url.contains('.mkv')) return 'MKV';
    if (url.contains('.webm')) return 'WebM';
    return '未知格式';
  }

  String _truncateUrl(String url) {
    if (url.length <= 60) return url;
    return '${url.substring(0, 30)}...${url.substring(url.length - 30)}';
  }
}