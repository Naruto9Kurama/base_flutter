import 'package:base_flutter/example/features/base/models/video/play_item.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/pages/video/player/custom_video_player.dart';
import 'package:base_flutter/example/pages/video/player/video_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '当前播放：${currentItem.episode}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '选集',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _showEpisodeDialog,
                                      child: Text(
                                        '共 ${widget.videoModel.playUrls.length}集 >',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildEpisodeSelector(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '视频简介',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.videoModel.detail ?? '',
                              style: const TextStyle(
                                fontSize: 14,
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
      height: 48,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(widget.videoModel.playUrls.length, (index) {
              final item = widget.videoModel.playUrls[index];
              final selected = index == currentIndex;
              final label = item.episode?.isNotEmpty == true
                  ? item.episode!
                  : (item.name.isNotEmpty ? item.name : '第${index + 1}集');
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(
                    label,
                    style: TextStyle(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final playUrls = widget.videoModel.playUrls;

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${widget.videoModel.title} (${playUrls.length}集)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
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
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                item.episode?.isNotEmpty == true
                                    ? item.episode!
                                    : item.name,
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selected ? Colors.blue : Colors.black87,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check,
                                size: 16,
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