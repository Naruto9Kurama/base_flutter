import 'package:base_flutter/example/pages/video/search/video_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/config/app_config.dart';
import '../../../features/video/provider/video_search_provider.dart';
import '../../../features/base/models/video/video_model.dart';

// 视频搜索视图
class VideoSearchView extends StatefulWidget {
  const VideoSearchView({Key? key}) : super(key: key);

  @override
  State<VideoSearchView> createState() => _VideoSearchViewState();
}

class _VideoSearchViewState extends State<VideoSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, Map<String, String>> _vodOptions = {};
  String _selectedVod = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 从 AppConfig 中读取 vod 源配置
    try {
      final appConfig = GetIt.instance.get<AppConfig>();
      _vodOptions = appConfig.getVodOptions();
      if (_vodOptions.isNotEmpty) {
        _selectedVod = _vodOptions.keys.first;
        print('VOD options loaded: ${_vodOptions.keys.join(', ')}');
      } else {
        print('No vod options found');
      }
    } catch (e, stackTrace) {
      print('Error loading vod config: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // 搜索按钮点击事件
  void _onSearchButtonPressed(BuildContext context) {
    final provider = context.read<VideoSearchProvider>();
    // 使用选中的视频源进行搜索
    provider.searchVideos(
      _selectedVod.isNotEmpty ? _selectedVod : 'jy',
      _searchController.text.trim(),
    );
  }

  // 视频项点击事件 - 预留给实际的视频播放逻辑
  void _onVideoItemTapped(BuildContext context, VideoModel video) {
    final episodeList = video.playUrls
        .map((play) => play.url)
        .where((url) => url.isNotEmpty)
        .toList();
    if (episodeList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该视频暂无可用播放源')));
      return;
    }
    context.push('/video-player', extra: video);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: const Text('视频搜索')),
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchBar(
                  controller: _searchController,
                  onSearch: () => _onSearchButtonPressed(context),
                ),
              ),
              if (_vodOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '视频源：',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _vodOptions.keys.map((key) {
                                final value = _vodOptions[key]!;
                                final selected = key == _selectedVod;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    label: Text(
                                      value['name']??key,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    selected: selected,
                                    onSelected: (v) {
                                      setState(() {
                                        _selectedVod = key;
                                        _onSearchButtonPressed(context);
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // 列表区域
              Expanded(
                child: _VideoListContent(
                  onVideoTap: (video) => _onVideoItemTapped(context, video),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 搜索栏组件
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({Key? key, required this.controller, required this.onSearch})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VideoSearchProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PlatformProvider.of(context)?.platform == TargetPlatform.iOS
            ? const Color(0xFFF2F2F7)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PlatformTextField(
              controller: controller,
              material: (_, __) => MaterialTextFieldData(
                decoration: const InputDecoration(
                  hintText: '输入视频名称',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              cupertino: (_, __) => CupertinoTextFieldData(
                placeholder: '输入视频名称',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.search, size: 20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 12),
          PlatformElevatedButton(
            onPressed: isLoading ? null : onSearch,
            material: (_, __) => MaterialElevatedButtonData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            cupertino: (_, __) => CupertinoElevatedButtonData(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('搜索'),
          ),
        ],
      ),
    );
  }
}

// 视频列表内容组件
class _VideoListContent extends StatefulWidget {
  final Function(VideoModel) onVideoTap;

  const _VideoListContent({Key? key, required this.onVideoTap})
    : super(key: key);

  @override
  State<_VideoListContent> createState() => _VideoListContentState();
}

class _VideoListContentState extends State<_VideoListContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<VideoSearchProvider>();
    if (!_scrollController.hasClients) return;
    final threshold = 200.0; // 距离底部阈值
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (maxScroll - current <= threshold) {
      // 触发加载下一页
      provider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoSearchProvider>(
      builder: (context, provider, child) {
        // 加载中状态
        if (provider.isLoading) {
          return Center(child: PlatformCircularProgressIndicator());
        }

        // 有错误信息时显示在列表区域
        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '搜索失败',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PlatformElevatedButton(
                  onPressed: () {
                    // 用户可以点击重试
                  },
                  child: const Text('关闭错误'),
                ),
              ],
            ),
          );
        }

        // 空状态
        if (!provider.hasSearched || provider.videoList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PlatformIcons(context).search,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                PlatformText(
                  provider.hasSearched && provider.videoList.isEmpty
                      ? '未找到相关视频'
                      : '输入关键词搜索视频',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 视频列表
        final itemCount =
            provider.videoList.length + (provider.isLoadingMore ? 1 : 0);
        return ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            if (index < provider.videoList.length) {
              return VideoListItem(
                video: provider.videoList[index],
                onTap: () => widget.onVideoTap(provider.videoList[index]),
              );
            } else {
              // 底部加载指示器
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: PlatformCircularProgressIndicator()),
              );
            }
          },
        );
      },
    );
  }
}
