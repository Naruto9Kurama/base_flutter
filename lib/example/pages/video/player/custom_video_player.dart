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
  bool _isLongPressing = false;
  double _longPressSpeed = 2.0;
  double? _speedBeforeLongPress;

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return WillPopScope(
          onWillPop: () async {
            if (state.isFullscreen) {
              _handleExitFullscreen(state);
              return false; // 阻止返回上一页
            }
            return true; // 非全屏允许返回
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isPortrait = constraints.maxHeight >= constraints.maxWidth;
              final double scaleFactor = (constraints.maxWidth / 900).clamp(0.65, 1.0);
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
                          strokeWidth: 3,
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
                        onTapDown: (_) {
                          if (state.showControls) {
                            state.showControlsTemporarily();
                          }
                        },
                        onLongPressStart: (_) {
                          setState(() => _isLongPressing = true);
                          _speedBeforeLongPress = state.currentSpeed;
                          state.setSpeed(_longPressSpeed);
                        },
                        onLongPressEnd: (_) {
                          setState(() => _isLongPressing = false);
                          final fallbackSpeed = _speedBeforeLongPress ?? 1.0;
                          state.setSpeed(fallbackSpeed);
                          _speedBeforeLongPress = null;
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    if (_isLongPressing)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fast_forward, color: Colors.white, size: 32),
                              const SizedBox(width: 12),
                              Text(
                                '${_longPressSpeed}x 倍速播放中',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (state.showControls)
                      VideoControlsOverlay(
                        videoTitle: widget.videoTitle,
                        episode: widget.episode,
                        scaleFactor: scaleFactor,
                        isPortraitLayout: isPortrait,
                      ),
                    if (state.showEpisodeList) const EpisodeListSidebar(),
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
    state.isFullscreen = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    state.notifyListeners();
  }
}
