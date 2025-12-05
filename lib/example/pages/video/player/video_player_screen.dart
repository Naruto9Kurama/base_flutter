import 'package:base_flutter/example/features/base/models/video/play_item.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/pages/video/player/custom_video_player.dart';
import 'package:base_flutter/example/pages/video/player/video_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel videoModel;
  final int initialEpisodeIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videoModel,
    this.initialEpisodeIndex = 0,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  late final VideoControllerState controllerState;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    currentIndex = widget.initialEpisodeIndex.clamp(
      0,
      widget.videoModel.playUrls.length - 1,
    );
    controllerState = VideoControllerState(
      player: player,
      playlist: widget.videoModel.playUrls,
      currentIndex: currentIndex,
      onSwitchEpisode: _loadVideo,
    );
    
    // 监听全屏状态变化
    controllerState.addListener(_onFullscreenChanged);
    
    _loadVideo(currentIndex);
  }

  void _onFullscreenChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loadVideo(int index) {
    if (index >= 0 && index < widget.videoModel.playUrls.length) {
      setState(() {
        currentIndex = index;
      });
      controllerState.resetAutoAdvance();
      player.open(Media(widget.videoModel.playUrls[index].url));
      controllerState.syncCurrentIndex(index);
    }
  }

  @override
  void dispose() {
    controllerState.removeListener(_onFullscreenChanged);
    controllerState.dispose();
    player.dispose();
    // 确保退出时恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayItem currentItem = widget.videoModel.playUrls[currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: ChangeNotifierProvider.value(
        value: controllerState,
        child: Consumer<VideoControllerState>(
          builder: (context, state, child) {
            // 全屏模式：只显示播放器
            if (state.isFullscreen) {
              return SafeArea(
                child: CustomVideoPlayer(
                  controller: controller,
                  videoTitle: currentItem.name,
                  episode: currentItem.episode,
                ),
              );
            }
            
            // 非全屏模式：正常布局
            return SafeArea(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomVideoPlayer(
                      controller: controller,
                      videoTitle: currentItem.name,
                      episode: currentItem.episode,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.name,
                              style: TextStyle(
                                fontSize: 60.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '当前播放：${currentItem.episode}',
                              style: TextStyle(
                                fontSize: 40.sp,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '选集',
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _showEpisodeDialog,
                                      child: Text(
                                        '共 ${widget.videoModel.playUrls.length}集 >',
                                        style: TextStyle(
                                          fontSize: 38.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                _buildEpisodeSelector(),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              '视频简介',
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              widget.videoModel.detail ?? '',
                              style: TextStyle(
                                fontSize: 38.sp,
                                height: 1.5,
                                color: Colors.black87,
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
        ),
      ),
    );
  }

  Widget _buildEpisodeSelector() {
    final scrollController = ScrollController();

    return SizedBox(
      height: 90.w,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Row(
            children: List.generate(widget.videoModel.playUrls.length, (index) {
              final item = widget.videoModel.playUrls[index];
              final selected = index == currentIndex;
              final label = item.episode.isNotEmpty
                  ? item.episode
                  : (item.name.isNotEmpty ? item.name : '第${index + 1}集');
              return Padding(
                padding: EdgeInsets.only(right: 25.w),
                child: ChoiceChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      fontSize: 35.sp,
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) => _loadVideo(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showEpisodeDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
      ),
      builder: (ctx) {
        final playUrls = widget.videoModel.playUrls;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  '${widget.videoModel.title} (${playUrls.length}集)',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1.h),
              Flexible(
                child: GridView.builder(
                  padding: EdgeInsets.all(12.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12.w,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: playUrls.length,
                  itemBuilder: (_, index) {
                    final item = playUrls[index];
                    final bool selected = index == currentIndex;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _loadVideo(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(8.w),
                          border: Border.all(
                            color: selected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                item.episode.isNotEmpty
                                    ? item.episode
                                    : item.name,
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected ? Colors.blue : Colors.black87,
                                  fontSize: 38.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selected) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.check,
                                size: 30.w,
                                color: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}