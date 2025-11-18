import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/example/features/file/models/file/video_file.dart';
import 'package:base_flutter/example/features/file/providers/file_item/file_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'video_player_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  
  final FileItemProvider fileItemProvider;
  
  const VideoPlayerScreen({
    Key? key,
    required this.fileItemProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(fileItemProvider.fileItem.filename),
        material: (_, __) => MaterialAppBarData(
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          backgroundColor: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // 视频播放器
          Container(
            height: 300, // 可以根据需要调整播放器的高度
            child: VideoPlayerWidget(videoUrl: "https://vjs.zencdn.net/v/oceans.mp4"),
            // child: VideoPlayerWidget(videoUrl: (fileItemProvider.fileItem is VideoFile)?((fileItemProvider.fileItem as VideoFile).videoPlayUrl):""),
          ),
          // 视频信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(fileItemProvider.fileItem.filename),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
