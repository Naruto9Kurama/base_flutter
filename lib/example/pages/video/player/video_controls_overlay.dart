import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'video_state.dart';

class VideoControlsOverlay extends StatefulWidget {
  final String videoTitle;
  final String episode;
  final double scaleFactor;
  final bool isPortraitLayout;

  const VideoControlsOverlay({
    super.key,
    required this.videoTitle,
    required this.episode,
    required this.scaleFactor,
    required this.isPortraitLayout,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _showSpeedMenu = false;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  double _scale(double base) {
    return (base * widget.scaleFactor).clamp(base * 0.65, base * 1.2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return SizedBox.expand(
              child: Stack(
                children: [
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.85),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.15, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: _scale(4)),
                    child: Column(
                      children: [
                        _buildTopBar(context, state),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: _buildCenterControls(state),
                          ),
                        ),
                        _buildBottomControls(state),
                      ],
                    ),
                  ),
                  if (_showSpeedMenu)
                    Positioned(
                      right: 16,
                      bottom: isLandscape ? 120 : 200,
                      child: _buildSpeedMenu(state),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, VideoControllerState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, _scale(8), 8, _scale(16)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: _scale(22),
            ),
            onPressed: () {
              // 如果是全屏状态，先退出全屏
              if (state.isFullscreen) {
                _toggleFullscreen(state);
              } else {
                // 退出前恢复系统UI
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _scale(16),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.episode,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: _scale(12),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: _scale(22)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(VideoControllerState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [

      ],
    );
  }

  // 通用圆形按钮，保证图标居中
  Widget _buildControlButton({
    required IconData icon,
    required double size, // 与播放按钮保持一致
    VoidCallback? onPressed,
  }) {
    return Container(
      width: _scale(size), // 固定宽度
      height: _scale(size), // 固定高度
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(onPressed != null ? 0.2 : 0.1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero, // 去掉默认内边距
        alignment: Alignment.center, // 图标居中
        iconSize: _scale(size - 5), // 图标略小于按钮，视觉居中
        icon: Icon(
          icon,
          color: Colors.white.withOpacity(onPressed != null ? 1.0 : 0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomControls(VideoControllerState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;

        final double btnSize = 35; // 左右按钮统一高度

        // 宽度阈值判断是否显示额外按钮（选集、倍速、快进快退）
        final bool showExtraButtons = availableWidth > 400;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==============================
            // 底部进度条 + 时间显示在两侧
            // ==============================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _scale(16)),
              child: Row(
                children: [
                  // 左侧：当前播放时间
                  Text(
                    _formatDuration(state.position),
                    style: TextStyle(color: Colors.white, fontSize: _scale(12)),
                  ),
                  SizedBox(width: _scale(8)),
                  // 中间：进度条 Slider
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: _scale(3),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: _scale(5),
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: _scale(10),
                        ),
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.blue.withOpacity(0.3),
                      ),
                      child: Slider(
                        value: state.duration.inMilliseconds > 0
                            ? state.position.inMilliseconds.toDouble()
                            : 0,
                        min: 0,
                        max: state.duration.inMilliseconds > 0
                            ? state.duration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: (value) {
                          state.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: _scale(8)),
                  // 右侧：视频总时长
                  Text(
                    _formatDuration(state.duration),
                    style: TextStyle(color: Colors.white, fontSize: _scale(12)),
                  ),
                ],
              ),
            ),

            SizedBox(height: _scale(6)),

            // ==============================
            // 底部按钮行
            // ==============================
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, _scale(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 左侧按钮组（上一集、快退、播放/暂停、快进、下一集）
                  Row(
                    children: [
                      // 上一集按钮
                      _buildCircleButton(
                        icon: Icons.skip_previous_rounded,
                        size: btnSize,
                        onPressed: state.hasPrevious
                            ? state.playPrevious
                            : null,
                      ),
                      SizedBox(width: _scale(6)),
                      // 快退按钮（仅在宽屏显示）
                      if (showExtraButtons)
                        _buildCircleButton(
                          icon: Icons.replay_10_rounded,
                          size: btnSize,
                          onPressed: () {
                            final newPosition =
                                state.position - const Duration(seconds: 15);
                            state.seek(
                              newPosition < Duration.zero
                                  ? Duration.zero
                                  : newPosition,
                            );
                          },
                        ),
                      SizedBox(width: _scale(6)),
                      // 播放/暂停按钮
                      _buildCircleButton(
                        icon: state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: btnSize,
                        onPressed: state.togglePlayPause,
                        isMain: true, // 用于区分主按钮，可以单独设置颜色
                      ),
                      SizedBox(width: _scale(6)),
                      // 快进按钮（仅在宽屏显示）
                      if (showExtraButtons)
                        _buildCircleButton(
                          icon: Icons.forward_10_rounded,
                          size: btnSize,
                          onPressed: () {
                            final newPosition =
                                state.position + const Duration(seconds: 15);
                            state.seek(
                              newPosition > state.duration
                                  ? state.duration
                                  : newPosition,
                            );
                          },
                        ),
                      SizedBox(width: _scale(6)),
                      // 下一集按钮
                      _buildCircleButton(
                        icon: Icons.skip_next_rounded,
                        size: btnSize,
                        onPressed: state.hasNext ? state.playNext : null,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 右侧按钮组（选集、倍速、全屏）
                  // 右侧按钮组
                  Row(
                    children: [
                      if (showExtraButtons)
                        _buildBottomButton(
                          icon: Icons.menu_rounded,
                          label: '选集',
                          onPressed: state.toggleEpisodeList,
                          height: btnSize,
                        ),
                      if (showExtraButtons) SizedBox(width: _scale(6)),
                      // if (showExtraButtons)
                        _buildBottomButton(
                          icon: Icons.speed_rounded,
                          label: '倍速 ${state.currentSpeed}x',
                          onPressed: () =>
                              setState(() => _showSpeedMenu = !_showSpeedMenu),
                          height: btnSize,
                        ),
                      SizedBox(width: _scale(6)),
                      // 全屏按钮：只显示图标，宽高与左侧按钮一致
                      _buildCircleButton(
                        icon: state.isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        size: btnSize,
                        onPressed: () => _toggleFullscreen(state),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // 左侧圆形按钮（上一集/下一集/快退/快进/播放/暂停）
  // ==============================
  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    VoidCallback? onPressed,
    bool isMain = false, // 是否是播放/暂停按钮，可设置背景色
  }) {
    return Container(
      width: _scale(size),
      height: _scale(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          onPressed != null ? (isMain ? 0.9 : 0.2) : 0.1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        iconSize: _scale(size * 0.7), // 图标大小占按钮 70%
        icon: Icon(
          icon,
          color: onPressed != null
              ? Colors.black
              : Colors.white.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ==============================
  // 右侧矩形按钮（选集/倍速/全屏）
  // ==============================
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double height = 35,
  }) {
    return Container(
      height: _scale(height),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: _scale(height * 0.6)),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: _scale(height * 0.37),
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: _scale(8), vertical: 0),
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // Widget _buildBottomButton({
  //   required IconData icon,
  //   required String label,
  //   required VoidCallback onPressed,
  //   double height = 35, // 默认和左侧按钮高度一致
  // }) {
  //   return Container(
  //     height: _scale(height),
  //     child: TextButton.icon(
  //       onPressed: onPressed,
  //       icon: Icon(
  //         icon,
  //         color: Colors.white,
  //         size: _scale(height * 0.6), // 图标略小于按钮高度
  //       ),
  //       label: Text(
  //         label,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: _scale(height * 0.37), // 字体随按钮高度缩放
  //         ),
  //       ),
  //       style: TextButton.styleFrom(
  //         padding: EdgeInsets.symmetric(
  //           horizontal: _scale(8),
  //           vertical: 0, // 高度由外层 Container 控制
  //         ),
  //         backgroundColor: Colors.white.withOpacity(0.1),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionIcons(VideoControllerState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.cast, color: Colors.white, size: _scale(24)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.high_quality_rounded,
            color: Colors.white,
            size: _scale(24),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            state.isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white,
            size: _scale(24),
          ),
          onPressed: () {
            _toggleFullscreen(state);
          },
        ),
      ],
    );
  }

  void _toggleFullscreen(VideoControllerState state) {
    state.isFullscreen = !state.isFullscreen;

    if (state.isFullscreen) {
      // 进入全屏：隐藏系统UI，只允许横屏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // 退出全屏：恢复系统UI，锁定竖屏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    state.notifyListeners();
  }

  Widget _buildSpeedMenu(VideoControllerState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: _scale(8), bottom: _scale(8)),
            child: Text(
              '播放速度',
              style: TextStyle(
                color: Colors.white,
                fontSize: _scale(14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._speedOptions.map((speed) {
            final isSelected = state.currentSpeed == speed;
            return InkWell(
              onTap: () {
                state.setSpeed(speed);
                setState(() => _showSpeedMenu = false);
              },
              child: Container(
                width: _scale(110),
                padding: EdgeInsets.symmetric(
                  horizontal: _scale(16),
                  vertical: _scale(10),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${speed}x',
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.white,
                        fontSize: _scale(14),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.blue, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class EpisodeListSidebar extends StatelessWidget {
  final bool isLandscape;
  const EpisodeListSidebar({super.key, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return GestureDetector(
          onTap: state.toggleEpisodeList,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Align(
              alignment: isLandscape
                  ? Alignment.centerRight
                  : Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.7
                      : double.infinity,
                  height: isLandscape
                      ? double.infinity
                      : MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 标题栏
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '选集',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: state.toggleEpisodeList,
                            ),
                          ],
                        ),
                      ),
                      // 集数列表
                      Expanded(
                        child: isLandscape
                            ? Row(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.playlist.length,
                                      padding: const EdgeInsets.all(8),
                                      itemBuilder: (context, index) {
                                        final isActive =
                                            index == state.currentIndex;
                                        final item = state.playlist[index];
                                        return _buildEpisodeCard(
                                          item,
                                          isActive,
                                          index,
                                          state,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: state.playlist.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, index) {
                                  final isActive = index == state.currentIndex;
                                  final item = state.playlist[index];
                                  return _buildEpisodeCard(
                                    item,
                                    isActive,
                                    index,
                                    state,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeCard(
    item,
    bool isActive,
    int index,
    VideoControllerState state,
  ) {
    return InkWell(
      onTap: () {
        state.onSwitchEpisode(index);
        state.toggleEpisodeList();
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.episode,
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isActive)
              const Icon(
                Icons.play_circle_filled,
                color: Colors.blue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
