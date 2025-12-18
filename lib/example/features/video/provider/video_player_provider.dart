import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';

class SourceProvider extends ChangeNotifier {
  String selectedSource = "jy";
  List<String> sources = ["jy"];
  VideoModel? searchedVideo;     // 搜索到的新视频数据
  bool loading = false;

  Future<void> changeSource(String newSource, String title) async {
    selectedSource = newSource;
    loading = true;
    notifyListeners();

    try {
      final result = await GetIt.instance
          .get<BaseVodRespository>()
          .searchVideo(newSource, title, 1, 1);

      searchedVideo = result.first;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
