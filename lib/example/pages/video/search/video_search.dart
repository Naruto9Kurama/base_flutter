import 'package:base_flutter/example/pages/video/search/video_search_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../../features/video/provider/video_search_provider.dart';
// 视频搜索页面
class VideoSearchPage extends StatelessWidget {
  const VideoSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoSearchProvider(),
      child: const VideoSearchView(),
    );
  }
}