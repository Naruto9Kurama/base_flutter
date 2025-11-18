
import 'package:base_flutter/example/pages/video/video_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import '../../features/video/provider/video_search_provider.dart';
import '../../features/video/models/video_model.dart';


// 视频搜索视图
class VideoSearchView extends StatefulWidget {
  const VideoSearchView({Key? key}) : super(key: key);

  @override
  State<VideoSearchView> createState() => _VideoSearchViewState();
}

class _VideoSearchViewState extends State<VideoSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 搜索按钮点击事件
  void _onSearchButtonPressed(BuildContext context) {
    final provider = context.read<VideoSearchProvider>();
    provider.searchVideos(_searchController.text.trim());
  }

  // 视频项点击事件 - 预留给实际的视频播放逻辑
  void _onVideoItemTapped(BuildContext context, VideoModel video) {
    // TODO: 在这里添加视频点击后的逻辑
    // 示例：
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VideoPlayerPage(videoId: video.id),
    //   ),
    // );

    _showMessage(context, '点击了视频: ${video.title}');
    print('视频ID: ${video.id}');
  }

  // 显示提示信息
  void _showMessage(BuildContext context, String message) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          PlatformDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('视频搜索'),
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onSearch: () => _onSearchButtonPressed(context),
          ),
          Expanded(
            child: _VideoListContent(
              onVideoTap: (video) => _onVideoItemTapped(context, video),
            ),
          ),
        ],
      ),
    );
  }
}


// 搜索栏组件
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
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
class _VideoListContent extends StatelessWidget {
  final Function(VideoModel) onVideoTap;

  const _VideoListContent({
    Key? key,
    required this.onVideoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoSearchProvider>(
      builder: (context, provider, child) {
        // 显示错误信息
        if (provider.errorMessage.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: const Text('提示'),
                content: Text(provider.errorMessage),
                actions: [
                  PlatformDialogAction(
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          });
        }

        // 加载中状态
        if (provider.isLoading) {
          return Center(
            child: PlatformCircularProgressIndicator(),
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // 视频列表
        return ListView.builder(
          itemCount: provider.videoList.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return VideoListItem(
              video: provider.videoList[index],
              onTap: () => onVideoTap(provider.videoList[index]),
            );
          },
        );
      },
    );
  }
}
