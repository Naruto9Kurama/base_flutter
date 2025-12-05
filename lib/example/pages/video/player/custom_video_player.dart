import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import 'video_controls_overlay.dart';
import 'video_state.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoController controller;
  final String videoTitle;
  final String episode;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    required this.videoTitle,
    required this.episode,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  // All interaction logic (seeking, long-press speed) moved to VideoControllerState.

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return WillPopScope(
          onWillPop: () async {
            if (state.isFullscreen) {
              _handleExitFullscreen(state);
              return false;
            }
            return true;
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isPortrait =
                  constraints.maxHeight >= constraints.maxWidth;
              return Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Video(
                        controller: widget.controller,
                        controls: NoVideoControls,
                      ),
                    ),
                    if (state.isBuffering)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        ),
                      ),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          state.toggleControls();
                          if (state.showControls && state.isPlaying) {
                            state.showControlsTemporarily();
                          }
                        },
                        onDoubleTap: () {
                          // 双击暂停/播放
                          state.togglePlayPause();
                          state.showPlayPauseIndicatorTemporarily();
                        },
                        onTapDown: (_) {
                          if (state.showControls) {
                            state.showControlsTemporarily();
                          }
                        },
                        onHorizontalDragStart: (details) {
                          state.onHorizontalDragStart(details.globalPosition.dx);
                        },
                        onHorizontalDragUpdate: (details) {
                          state.onHorizontalDragUpdate(
                            details.globalPosition.dx,
                            MediaQuery.of(context).size.width,
                          );
                        },
                        onHorizontalDragEnd: (details) {
                          state.onHorizontalDragEnd();
                        },
                        onLongPressStart: (_) {
                          state.onLongPressStart(speed: 2.0);
                        },
                        onLongPressEnd: (_) {
                          state.onLongPressEnd();
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    // Note: VideoControlsOverlay 必须始终被构建（不能有 if 包裹），
                    // 这样 seek preview 和 long-press speed UI 才能独立显示，不受 showControls 影响
                    VideoControlsOverlay(
                      videoTitle: widget.videoTitle,
                      episode: widget.episode,
                      isPortraitLayout: isPortrait,
                    ),
                    if (state.showEpisodeList) 
                      const EpisodeListSidebar(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleExitFullscreen(VideoControllerState state) {
    state.setFullscreen(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}