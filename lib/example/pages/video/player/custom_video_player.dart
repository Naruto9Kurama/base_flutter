// custom_video_player.dart
import 'package:base_flutter/example/features/video/provider/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'video_controls_overlay.dart';
import 'video_state.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoTitle;
  final String episode;
  final VideoControllerState controllerState;

  const CustomVideoPlayer({
    super.key,
    required this.videoTitle,
    required this.episode,
    required this.controllerState,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late final VideoController _videoController;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>().player;
    _videoController = VideoController(player);
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = context.watch<PlayerProvider>().controllerState;

    // ✅ 关键修复：将 VideoControllerState 包装在 ChangeNotifierProvider.value 中
    return ChangeNotifierProvider<VideoControllerState>.value(
      value: controllerState,
      child: WillPopScope(
        onWillPop: () async {
          if (controllerState.isFullscreen) {
            _handleExitFullscreen(controllerState);
            return false;
          }
          return true;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isPortrait = constraints.maxHeight >= constraints.maxWidth;

            return Container(
              // ✅ 添加明确的尺寸约束
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand, // ✅ 确保 Stack 填满容器
                children: [
                  // 原生播放器画面
                  Positioned.fill(
                    child: Video(
                      controller: _videoController,
                      controls: NoVideoControls,
                    ),
                  ),

                  // 缓冲指示器 + 网速
                  if (controllerState.isBuffering)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '缓冲中...',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controllerState.networkSpeedText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 手势层
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controllerState.toggleControls();
                        if (controllerState.showControls && controllerState.isPlaying) {
                          controllerState.showControlsTemporarily();
                        }
                      },
                      onDoubleTap: () {
                        controllerState.togglePlayPause();
                        controllerState.showPlayPauseIndicatorTemporarily();
                      },
                      onTapDown: (_) {
                        if (controllerState.showControls) {
                          controllerState.showControlsTemporarily();
                        }
                      },
                      onHorizontalDragStart: (d) =>
                          controllerState.onHorizontalDragStart(d.globalPosition.dx),
                      onHorizontalDragUpdate: (d) =>
                          controllerState.onHorizontalDragUpdate(
                        d.globalPosition.dx,
                        MediaQuery.of(context).size.width,
                      ),
                      onHorizontalDragEnd: (_) => controllerState.onHorizontalDragEnd(),
                      onLongPressStart: (_) =>
                          controllerState.onLongPressStart(speed: 2.0),
                      onLongPressEnd: (_) => controllerState.onLongPressEnd(),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  // 控件叠加层（使用 Positioned.fill 替代 SizedBox.expand）
                  Positioned.fill(
                    child: VideoControlsOverlay(
                      videoTitle: widget.videoTitle,
                      episode: widget.episode,
                      isPortraitLayout: isPortrait,
                    ),
                  ),

                  // 选集侧边栏
                  if (controllerState.showEpisodeList) const EpisodeListSidebar(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleExitFullscreen(VideoControllerState state) {
    state.setFullscreen(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}