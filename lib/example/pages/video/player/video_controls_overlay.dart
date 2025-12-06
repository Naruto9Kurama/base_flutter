import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'video_state.dart';

// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                    📺 视频播放器 UI 控制条覆盖层                            ║
// ║                                                                            ║
// ║  职责: 管理播放器控制条的显示/隐藏、事件分发、UI 布局                      ║
// ║  特点: 分层式架构、完全的中文注释、高度可扩展                              ║
// ╚════════════════════════════════════════════════════════════════════════════╝

/// 📺 视频播放器控制条 - 主 Widget 类
/// 这是一个 StatefulWidget，管理播放器的所有控制条 UI
class VideoControlsOverlay extends StatefulWidget {
  // ════════════════════════════════════════════════════════════════════════════
  // 📝 属性定义
  // ════════════════════════════════════════════════════════════════════════════

  /// 视频标题（显示在顶部导航栏）
  final String videoTitle;

  /// 剧集信息（显示在标题下方）
  final String episode;

  /// 是否为竖屏布局（用于响应式适配）
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

/// 📊 视频播放器控制条状态类
/// 管理: UI 显示状态、响应式计算、事件处理
class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  // ════════════════════════════════════════════════════════════════════════════
  // 🎮 UI 状态管理
  // ════════════════════════════════════════════════════════════════════════════

  /// 倍速选项列表：0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // ════════════════════════════════════════════════════════════════════════════
  // 📐 响应式尺寸计算方法（三套方案）
  // ════════════════════════════════════════════════════════════════════════════

  /// 📏 计算响应式字体大小
  /// 
  /// 响应式规则:
  ///   • 小屏幕 (<500px)   → 增加 6 像素（便于点击和阅读）
  ///   • 中屏幕 (500-900px) → 增加 3 像素（适中）
  ///   • 大屏幕 (>900px)   → 缩小到 85%（适应宽屏）
  double _getResponsiveTextSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 500) {
      return baseSize + 6; // 🔴 小屏幕：增加字体
    } else if (screenWidth < 900) {
      return baseSize + 3; // 🟡 中屏幕：微调
    } else {
      return baseSize * 0.85; // 🟢 大屏幕：缩小
    }
  }

  /// 📊 计算响应式进度条大小（极小微调）
  ///
  /// 响应式规则:
  ///   • 小屏幕 (<500px)   → 增加 2 像素
  ///   • 中屏幕 (500-900px) → 增加 1 像素  
  ///   • 大屏幕 (>900px)   → 缩小到 85%
  double _getResponsiveProgressSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 500) {
      return baseSize + 2; // 🔴 小屏幕微调
    } else if (screenWidth < 900) {
      return baseSize + 1; // 🟡 中屏幕微调
    } else {
      return baseSize * 0.85; // 🟢 大屏幕缩小
    }
  }

  /// 🔘 计算响应式按钮大小（主要调整）
  ///
  /// 响应式规则:
  ///   • 小屏幕 (<500px)   → 增加 50 像素（让按钮大且易点击）
  ///   • 中屏幕 (500-900px) → 增加 12 像素（小幅增大）
  ///   • 大屏幕 (>900px)   → 缩小到 60%（适应宽屏）
  double _getResponsiveButtonSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 500) {
      return baseSize + 50; // 🔴 小屏幕：大幅增大
    } else if (screenWidth < 900) {
      return baseSize + 12; // 🟡 中屏幕：小幅增大
    } else {
      return baseSize * 0.6; // 🟢 大屏幕：大幅缩小
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
                                  Colors.black.withOpacity(0.15),  // 🔆 进一步降低到 15% (之前 30%)
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),  // 🔆 进一步降低到 20% (之前 35%)
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
                                          size: _getResponsiveTextSize(48.w),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ✅ 顶级层：Seek preview - 永远独立显示在最顶部（由专用方法构建）
                  if (state.isSeeking && state.seekPreviewPosition != null)
                    _buildSeekPreviewOverlay(state),

                  // ✅ 顶级层：Long-press speed - 永远独立显示在最顶部（由专用方法构建）
                  if (state.isLongPressing)
                    _buildLongPressSpeedOverlay(state),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🎮 主要构建方法
  // ════════════════════════════════════════════════════════════════════════════

  /// 📍 构建顶部导航栏
  /// 显示: 返回按钮、视频标题、剧集信息、画中画按钮、更多菜单按钮
  Widget _buildTopBar(BuildContext context, VideoControllerState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8.w, 8, 16.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: _getResponsiveTextSize(22.w),
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
                    fontSize: _getResponsiveTextSize(16.sp),
                    fontWeight: FontWeight.w500,
                    shadows: [  // 🔆 添加文字阴影以提亮
                      Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.episode,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),  // 🔆 提亮到 90% (之前 70%)
                    fontSize: _getResponsiveTextSize(12.sp),
                    fontWeight: FontWeight.w500,  // 🔆 加粗
                    shadows: [  // 🔆 添加文字阴影以提亮
                      Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.picture_in_picture_alt_rounded,
              color: Colors.white,
              size: _getResponsiveTextSize(22.w),
            ),
            onPressed: () => _enablePictureInPicture(state),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: _getResponsiveTextSize(22.w)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// 🎯 构建中央控制占位符
  /// 注: 此方法为占位符，可用于未来添加中央控制元素（如 AirPlay、字幕切换等）
  /// 返回: 空 Row（不显示任何内容）
  Widget _buildCenterControls(VideoControllerState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: []);
  }

  /// 🎮 构建底部控制栏
  /// 显示:
  ///   - 进度条行: 当前时间 - 进度条 - 总时长
  ///   - 按钮行:
  ///     左侧 → 上一集、快退、播放/暂停、快进、下一集
  ///     右侧 → 选集、倍速、全屏
  Widget _buildBottomControls(VideoControllerState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        // 根据屏幕宽度动态调整按钮大小（使用响应式函数）
        final double baseButtonSize = 40.w;
        final double btnSize = _getResponsiveButtonSize(baseButtonSize);
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
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: _getResponsiveTextSize(12.sp),
                      shadows: [  // 🔆 添加文字阴影以提亮
                        Shadow(
                          offset: const Offset(0, 0),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Stack(
                      children: [
                        // 🔄 缓冲进度条背景
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: _getResponsiveProgressSize(3.w),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: _getResponsiveProgressSize(5.w),
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: _getResponsiveProgressSize(10.w),
                            ),
                            activeTrackColor: Colors.white.withOpacity(0.4),
                            inactiveTrackColor: Colors.white.withOpacity(0.1),
                            thumbColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                          ),
                          child: Slider(
                            value: state.duration.inMilliseconds > 0
                                ? (state.bufferedPosition.inMilliseconds.toDouble())
                                : 0,
                            min: 0,
                            max: state.duration.inMilliseconds > 0
                                ? state.duration.inMilliseconds.toDouble()
                                : 1,
                            onChanged: (_) {},  // 缓冲进度条不可交互
                          ),
                        ),
                        // 📊 实际进度条（覆盖在上层）
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: _getResponsiveProgressSize(3.w),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: _getResponsiveProgressSize(5.w),
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: _getResponsiveProgressSize(10.w),
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
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDuration(state.duration),
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: _getResponsiveTextSize(12.sp),
                      shadows: [  // 🔆 添加文字阴影以提亮
                        Shadow(
                          offset: const Offset(0, 0),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
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
                  // 👈 左侧控制按钮组（上一集、快退、播放/暂停、快进、下一集）
                  _buildLeftControlButtons(btnSize, showExtraButtons, state),

                  // 🔷 中间弹性空间
                  const Spacer(),

                  // 👉 右侧控制按钮组（选集、倍速、全屏）
                  _buildRightControlButtons(btnSize, showExtraButtons, state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // � 独立浮层 UI 构建方法（不受主控制条隐藏影响）
  // ════════════════════════════════════════════════════════════════════════════

  /// ⏩ 构建 Seek 快进预览 UI
  /// 显示元素:
  ///   - 快进/快退方向图标
  ///   - 预览时间和总时长
  ///   - 时间差（"快进 X 秒" / "快退 X 秒"）
  /// 位置: 屏幕中央偏上 (距顶部 40%)
  /// 触发: 水平拖动进度条时显示
  /// 重要: 此 UI 完全独立，不受主控制条 showControls 影响
  Widget _buildSeekPreviewOverlay(VideoControllerState state) {
    return Positioned(
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
              // 📍 快进/快退方向图标
              Icon(
                state.seekPreviewPosition!.inMilliseconds > state.position.inMilliseconds
                    ? Icons.fast_forward_rounded
                    : Icons.fast_rewind_rounded,
                color: Colors.white,
                size: 32.w,
              ),
              SizedBox(height: 8.h),

              // ⏱️ 预览时间和总时长
              Text(
                '${_formatDuration(state.seekPreviewPosition!)} / ${_formatDuration(state.duration)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),

              // 📊 快进/快退时间差
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
    );
  }

  /// ⚡ 构建长按倍速提示 UI
  /// 显示: 倍速值和"倍速播放中"提示文字
  /// 位置: 屏幕顶部中央 (距顶部 5%)
  /// 触发: 长按屏幕时显示
  /// 重要: 此 UI 完全独立，不受主控制条 showControls 影响
  Widget _buildLongPressSpeedOverlay(VideoControllerState state) {
    return Positioned(
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
              // ⚡ 图标
              Icon(
                Icons.fast_forward,
                color: Colors.white,
                size: 20.w,
              ),
              SizedBox(width: 10.w),

              // 📝 倍速文字
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
    );
  }

  /// 👈 构建左侧控制按钮组
  /// 包含: 上一集、快退、播放/暂停、快进、下一集
  /// 参数: 按钮大小、是否显示额外按钮（快退/快进）、播放器状态
  Widget _buildLeftControlButtons(double btnSize, bool showExtraButtons, VideoControllerState state) {
    // 左侧按钮组: 上一集 | 快退 | 播放 | 快进 | 下一集
    return Row(
      children: [
        // ⏮️ 上一集按钮
        _buildCircleButton(
          icon: Icons.skip_previous_rounded,
          size: btnSize,
          onPressed: state.hasPrevious ? state.playPrevious : null,
        ),
        SizedBox(width: 6.w), // 按钮间距

        // ⏪ 快退 10 秒按钮（仅在宽屏显示）
        if (showExtraButtons)
          _buildCircleButton(
            icon: Icons.replay_10_rounded,
            size: btnSize,
            onPressed: () {
              // 向后跳转 15 秒
              final newPosition = state.position - const Duration(seconds: 15);
              state.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
            },
          ),
        if (showExtraButtons) SizedBox(width: 6.w),

        // ⏯️ 播放/暂停按钮（主按钮，较亮）
        _buildCircleButton(
          icon: state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: btnSize,
          onPressed: state.togglePlayPause,
          isMain: true, // 标记为主按钮
        ),
        SizedBox(width: 6.w),

        // ⏩ 快进 10 秒按钮（仅在宽屏显示）
        if (showExtraButtons)
          _buildCircleButton(
            icon: Icons.forward_10_rounded,
            size: btnSize,
            onPressed: () {
              // 向前跳转 15 秒
              final newPosition = state.position + const Duration(seconds: 15);
              state.seek(newPosition > state.duration ? state.duration : newPosition);
            },
          ),
        if (showExtraButtons) SizedBox(width: 6.w),

        // ⏭️ 下一集按钮
        _buildCircleButton(
          icon: Icons.skip_next_rounded,
          size: btnSize,
          onPressed: state.hasNext ? state.playNext : null,
        ),
      ],
    );
  }

  /// 👉 构建右侧控制按钮组
  /// 包含: 选集、倍速、全屏
  /// 参数: 按钮大小、是否显示额外按钮（选集）、播放器状态
  Widget _buildRightControlButtons(double btnSize, bool showExtraButtons, VideoControllerState state) {
    // 右侧按钮组: 选集 | 倍速 | 全屏
    return Row(
      children: [
        // 📋 选集按钮（仅在宽屏显示）
        if (showExtraButtons)
          _buildBottomButton(
            icon: Icons.menu_rounded,
            label: '选集',
            onPressed: state.toggleEpisodeList,
            height: btnSize,
          ),
        if (showExtraButtons) SizedBox(width: 6.w),

        // 🎚️ 倍速下拉框 (原生DropdownButton)
        _buildSpeedDropdown(state, btnSize),
        SizedBox(width: 6.w),

        // 🖥️ 全屏按钮
        _buildCircleButton(
          icon: state.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          size: btnSize,
          onPressed: () => _toggleFullscreen(state),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🔘 按钮组件构建方法
  // ════════════════════════════════════════════════════════════════════════════

  /// 🎯 构建圆形按钮（播放、暂停、快进等）
  /// 参数:
  ///   - icon: 按钮图标
  ///   - size: 按钮大小（圆形，宽高相同）
  ///   - onPressed: 点击回调（为 null 时按钮禁用）
  ///   - isMain: 是否为主按钮（主按钮颜色更亮）
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
          onPressed != null ? (isMain ? 0.9 : 0.2) : 0.1,  // 恢复原来的透明度
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        iconSize: (size * 0.7).w,
        icon: Icon(
          icon,
          color: onPressed != null
              ? Colors.white  // 🔆 改成完全白色，之前是黑色
              : Colors.white.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }

  /// 📝 构建文字按钮（带图标和标签）
  /// 用于: 选集、倍速等功能按钮
  /// 参数:
  ///   - icon: 按钮图标
  ///   - label: 按钮标签文字
  ///   - onPressed: 点击回调
  ///   - height: 按钮高度
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
          backgroundColor: Colors.white.withOpacity(0.1),  // 恢复原来的透明度
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  /// 🎚️ 构建倍速下拉框 (原生DropdownButton)
  /// 使用 Material 原生下拉框组件，自动处理位置和显示
  Widget _buildSpeedDropdown(VideoControllerState state, double btnSize) {
    return Container(
      height: btnSize.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<double>(
        value: state.currentSpeed,
        dropdownColor: Colors.black.withOpacity(0.95),
        underline: const SizedBox(),  // 隐藏下划线
        isDense: true,
        isExpanded: false,
        items: _speedOptions.map((speed) {
          return DropdownMenuItem<double>(
            value: speed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed_rounded, color: Colors.white, size: (35 * 0.68).w),
                SizedBox(width: 6.w),
                Text(
                  '${speed}x',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveTextSize (10.sp),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (double? newSpeed) {
          if (newSpeed != null) {
            state.setSpeed(newSpeed);
          }
        },
        icon: Icon(
          Icons.unfold_more,
          color: Colors.white,
          size: (35 * 0.68).w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🎯 事件处理方法
  // ════════════════════════════════════════════════════════════════════════════

  /// 🖥️ 切换全屏模式
  /// 进入全屏: 隐藏系统 UI（沉浸式）、设置横屏方向
  /// 退出全屏: 显示系统 UI、设置竖屏方向
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

  // ════════════════════════════════════════════════════════════════════════════
  // 🎚️ 倍速菜单
  // ════════════════════════════════════════════════════════════════════════════

  /// 🎚️ 构建倍速选择菜单 (下拉框风格)
  /// 显示: 0.5x ~ 2.0x 的倍速选项
  /// 特点: 下拉框样式、底部小三角指示、支持选中状态高亮
  /// ⏱️ 格式化时长为可读字符串
  /// 示例:
  ///   - 5秒 → "00:05"
  ///   - 1分30秒 → "01:30"
  ///   - 1小时5分30秒 → "1:05:30"
  /// 返回: 格式化后的时间字符串 (MM:SS 或 H:MM:SS)
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

  /// 📊 获取 Seek 预览时间差文本
  /// 计算逻辑:
  ///   - 预览时间 > 当前时间 → "快进 X 秒"
  ///   - 预览时间 < 当前时间 → "快退 X 秒"
  ///   - 预览时间 = 当前时间 → "当前位置"
  /// 返回: 可读的时间差描述字符串
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
