import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';

// 视频列表项组件类
class VideoListItem extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const VideoListItem({Key? key, required this.video, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: PlatformWidget(
        material: (_, __) => _buildMaterialItem(context),
        cupertino: (_, __) => _buildCupertinoItem(context),
      ),
    );
  }

  Widget _buildMaterialItem(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(onTap: onTap, child: _buildItemContent()),
    );
  }

  Widget _buildCupertinoItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildItemContent(),
      ),
    );
  }

  Widget _buildItemContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频缩略图（自适应长宽比，带加载和错误占位）
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 140,
              height: 84,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  if (video.pic != null && video.pic!.isNotEmpty)
                    Positioned.fill(
                      child: Image.network(
                        video.pic!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white70, size: 36),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Colors.white70,
                      ),
                    ),

                  // duration label
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 视频信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  video.detail ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(video.id.hashCode % 10000).abs()}次观看',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
