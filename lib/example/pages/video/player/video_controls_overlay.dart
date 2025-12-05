import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'video_state.dart';

class VideoControlsOverlay extends StatefulWidget {
  final String videoTitle;
  final String episode;
  final bool isPortraitLayout;

  const VideoControlsOverlay({
    super.key,
    required this.videoTitle,
    required this.episode,
    required this.isPortraitLayout,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  bool _showSpeedMenu = false;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  final GlobalKey _speedButtonKey = GlobalKey();

  /// 根据屏幕宽度计算响应式大小（用于字体，增加量小）
  double _responsiveSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 500) {
      return baseSize + 6; // 小屏幕字体增加 6
    } else if (screenWidth < 900) {
      return baseSize + 3; // 中等屏幕字体增加 3
    } else {
      return baseSize * 0.85; // 大屏幕：缩小到 85%
    }
  }

  /// 根据屏幕宽度计算进度条大小（增加量极小）
  double _responsiveProgressSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 500) {
      return baseSize + 2; // 小屏幕进度条微调
    } else if (screenWidth < 900) {
      return baseSize + 1; // 中等屏幕进度条微调
    } else {
      return baseSize * 0.85; // 大屏幕：缩小到 85%
    }
  }

  /// 根据屏幕宽度计算底部按钮大小（增加量大）
  double _responsiveButtonSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 500) {
      return baseSize + 50; // 小屏幕按钮增加 24（增大）
    } else if (screenWidth < 900) {
      return baseSize + 12; // 中等屏幕按钮增加 12（增大）
    } else {
      return baseSize * 0.6; // 大屏幕：缩小到 85%
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.expand(
              child: Stack(
                children: [
                  // 主要内容层（包含主控制条和梯度）
                  SizedBox.expand(
                    child: Stack(
                      children: [
                        // Main controls (可隐藏)
                        if (state.showControls)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
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

                        // Gradient overlay
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

                        // Play/Pause indicator
                        if (state.showPlayPauseIndicator)
                          Positioned.fill(
                            child: Center(
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: 1.0 - value,
                                    child: Transform.scale(
                                      scale: 1.0 + (value * 0.3),
                                      child: Container(
                                        padding: EdgeInsets.all(20.w),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          state.isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                          color: Colors.white,
                                          size: _responsiveSize(48.w),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // Speed menu
                        if (_showSpeedMenu)
                          Positioned(
                            right: 16.w,
                            bottom: 90.w,
                            child: _buildSpeedMenu(state),
                          ),
                      ],
                    ),
                  ),

                  // ✅ 顶级层：Seek preview - 永远独立显示在最顶部
                  if (state.isSeeking && state.seekPreviewPosition != null)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.seekPreviewPosition!.inMilliseconds > state.position.inMilliseconds
                                    ? Icons.fast_forward_rounded
                                    : Icons.fast_rewind_rounded,
                                color: Colors.white,
                                size: 32.w,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '${_formatDuration(state.seekPreviewPosition!)} / ${_formatDuration(state.duration)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getSeekDifferenceText(state),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ✅ 顶级层：Long-press speed - 永远独立显示在最顶部
                  if (state.isLongPressing)
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.05,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fast_forward,
                                color: Colors.white,
                                size: 20.w,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                '${state.longPressSpeed}x 倍速播放中',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
      padding: EdgeInsets.fromLTRB(8, 8.w, 8, 16.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: _responsiveSize(22.w),
            ),
            onPressed: () {
              if (state.isFullscreen) {
                _toggleFullscreen(state);
              } else {
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
                    fontSize: _responsiveSize(16.sp),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.episode,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: _responsiveSize(12.sp),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.picture_in_picture_alt_rounded,
              color: Colors.white,
              size: _responsiveSize(22.w),
            ),
            onPressed: () => _enablePictureInPicture(state),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: _responsiveSize(22.w)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(VideoControllerState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: []);
  }

  Widget _buildBottomControls(VideoControllerState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // 根据屏幕宽度动态调整按钮大小（使用响应式函数）
        final double baseButtonSize = 40.w;
        final double btnSize = _responsiveButtonSize(baseButtonSize);
        final bool showExtraButtons = availableWidth > 400;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    _formatDuration(
                      state.isSeeking && state.seekPreviewPosition != null
                          ? state.seekPreviewPosition!
                          : state.getDisplayPosition()
                    ),
                    style: TextStyle(color: Colors.white, fontSize: _responsiveSize(12.sp)),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: _responsiveProgressSize(3.w),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: _responsiveProgressSize(5.w),
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: _responsiveProgressSize(10.w),
                        ),
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: Slider(
                          value: state.duration.inMilliseconds > 0
                              ? (state.isSeeking && state.seekPreviewPosition != null
                                  ? state.seekPreviewPosition!.inMilliseconds.toDouble()
                                  : state.getDisplayPosition().inMilliseconds.toDouble())
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
                  SizedBox(width: 8.w),
                  Text(
                    _formatDuration(state.duration),
                    style: TextStyle(color: Colors.white, fontSize: _responsiveSize(12.sp)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _buildCircleButton(
                        icon: Icons.skip_previous_rounded,
                        size: btnSize,
                        onPressed: state.hasPrevious ? state.playPrevious : null,
                      ),
                      SizedBox(width: 6.w),
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
                      if (showExtraButtons) SizedBox(width: 6.w),
                      _buildCircleButton(
                        icon: state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: btnSize,
                        onPressed: state.togglePlayPause,
                        isMain: true,
                      ),
                      SizedBox(width: 6.w),
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
                      if (showExtraButtons) SizedBox(width: 6.w),
                      _buildCircleButton(
                        icon: Icons.skip_next_rounded,
                        size: btnSize,
                        onPressed: state.hasNext ? state.playNext : null,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (showExtraButtons)
                        _buildBottomButton(
                          icon: Icons.menu_rounded,
                          label: '选集',
                          onPressed: state.toggleEpisodeList,
                          height: btnSize,
                        ),
                      if (showExtraButtons) SizedBox(width: 6.w),
                      _buildBottomButton(
                        key: _speedButtonKey,
                        icon: Icons.speed_rounded,
                        label: '倍速 ${state.currentSpeed}x',
                        onPressed: () =>
                            setState(() => _showSpeedMenu = !_showSpeedMenu),
                        height: btnSize,
                      ),
                      SizedBox(width: 6.w),
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

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    VoidCallback? onPressed,
    bool isMain = false,
  }) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          onPressed != null ? (isMain ? 0.9 : 0.2) : 0.1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        iconSize: (size * 0.7).w,
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

  Widget _buildBottomButton({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double height = 35,
  }) {
    return Container(
      key: key,
      height: height.w,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: (height * 0.68).w),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: (height * 0.68).sp,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  void _toggleFullscreen(VideoControllerState state) {
    final bool entering = !state.isFullscreen;
    state.setFullscreen(entering);

    if (entering) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  Future<void> _enablePictureInPicture(VideoControllerState state) async {
    try {
      // 调用 Android 原生画中画
      const platform = MethodChannel('com.example.app/pip');
      final result = await platform.invokeMethod('enterPictureInPicture');
      
      if (result == true && mounted) {
        // 画中画成功，可以选择返回上一页或保持当前页面
        // Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      // 处理平台异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画中画功能不可用: ${e.message}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
      print('画中画错误: ${e.message}');
    } catch (e) {
      // 其他错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('该设备不支持画中画功能'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange.withOpacity(0.8),
          ),
        );
      }
      print('画中画错误: $e');
    }
  }

  Widget _buildSpeedMenu(VideoControllerState state) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8.w,
            spreadRadius: 1.w,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 4.w),
            child: Text(
              '播放速度',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
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
                width: 100.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.w,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${speed}x',
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.white,
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check, color: Colors.blue, size: 16.w),
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

  String _getSeekDifferenceText(VideoControllerState state) {
    final preview = state.seekPreviewPosition;
    if (preview == null) return '';
    final difference = preview.inSeconds - state.position.inSeconds;
    if (difference > 0) {
      return '快进 ${difference} 秒';
    } else if (difference < 0) {
      return '快退 ${-difference} 秒';
    }
    return '当前位置';
  }
}

class EpisodeListSidebar extends StatelessWidget {
  final bool isLandscape;
  
  const EpisodeListSidebar({
    super.key, 
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerState>(
      builder: (context, state, child) {
        return GestureDetector(
          onTap: state.toggleEpisodeList,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 280.w,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a).withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20.w,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '选集',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24.w,
                              ),
                              onPressed: state.toggleEpisodeList,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.playlist.length,
                          padding: EdgeInsets.all(8.w),
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
        margin: EdgeInsets.symmetric(
          vertical: 4.w,
          horizontal: 8.w,
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.episode,
                    style: TextStyle(
                      color: isActive ? Colors.blue : Colors.white,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.play_circle_filled,
                color: Colors.blue,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }
}