import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/provider/player_provider.dart';
import 'package:base_flutter/example/pages/video/player/custom_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoModel videoModel;
  final int initialEpisodeIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videoModel,
    this.initialEpisodeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final p = PlayerProvider();
        p.init(videoModel, initialEpisodeIndex);
        return p;
      },
      child: const _VideoPlayerScreenContent(),
    );
  }
}

class _VideoPlayerScreenContent extends StatelessWidget {
  const _VideoPlayerScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            isLandscape
                ? Expanded(
                    child: CustomVideoPlayer(
                      videoTitle: provider.videoModel?.title ?? '',
                      episode: provider.playlist[provider.currentIndex].episode,
                      controllerState: provider.controllerState,
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: CustomVideoPlayer(
                      videoTitle: provider.videoModel?.title ?? '',
                      episode: provider.playlist[provider.currentIndex].episode,
                      controllerState: provider.controllerState,
                    ),
                  ),

            if (!isLandscape) ...[
              // 选源 + 选集按钮
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '选集',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        DropdownButton<String>(
                          value: provider.selectedSource,
                          items: provider.videoSources
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: TextStyle(fontSize: 32.sp),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) provider.changeSource(value);
                          },
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showEpisodeDialog(provider, context),
                      child: Text(
                        '共 ${provider.playlist.length} 集 >',
                        style: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 横向选集条
              SizedBox(
                height: 90.w,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: provider.playlist.length,
                  itemBuilder: (_, index) {
                    final item = provider.playlist[index];
                    final selected = index == provider.currentIndex;
                    return Padding(
                      padding: EdgeInsets.only(right: 15.w),
                      child: ChoiceChip(
                        label: Text(
                          item.episode.isNotEmpty ? item.episode : item.name,
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
                        onSelected: (_) => provider.loadVideo(index),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.playlist[provider.currentIndex].name,
                        style: TextStyle(
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '当前播放：${provider.playlist[provider.currentIndex].episode}',
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.black54,
                        ),
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
                        provider.videoModel?.detail ?? '',
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
            ],
          ],
        ),
      ),
    );
  }

  void _showEpisodeDialog(PlayerProvider provider, BuildContext context) {
    final playlist = provider.playlist;
    final currentIndex = provider.currentIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.w)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                '${provider.videoModel?.title ?? ""} (${playlist.length}集)',
                style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: GridView.builder(
                padding: EdgeInsets.all(12.w),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12.w,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.2,
                ),
                itemCount: playlist.length,
                itemBuilder: (_, index) {
                  final item = playlist[index];
                  final selected = index == currentIndex;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      provider.loadVideo(index);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.grey.shade300,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        item.episode.isNotEmpty ? item.episode : item.name,
                        style: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected ? Colors.blue : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
