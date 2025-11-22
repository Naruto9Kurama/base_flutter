import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:base_flutter/example/features/video/respository/vod_respository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:injectable/injectable.dart';

// 视频搜索状态管理类
@LazySingleton()
class VideoSearchProvider extends ChangeNotifier {
  List<VideoModel> _videoList = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentKeyword = '';

  List<VideoModel> get videoList => _videoList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentKeyword => _currentKeyword;
  bool get hasSearched => _currentKeyword.isNotEmpty;

  // 搜索视频的方法 - 预留给实际的API请求
  Future<void> searchVideos(String keyword) async {
    if (keyword.trim().isEmpty) {
      _errorMessage = '请输入搜索关键词';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _currentKeyword = keyword;
    notifyListeners();

    try {
      // 模拟搜索结果数据
      getIt
          .get<BaseVodRespository>()
          .searchVideo("jy", keyword, 1, 10)
          .then((onValue) {
            _videoList = onValue;
            _isLoading = false;
            notifyListeners();
          });
    } catch (e) {
      _isLoading = false;
      _errorMessage = '搜索失败: $e';
      _videoList = [];
      notifyListeners();
    }
  }

  // 清除搜索结果
  void clearSearch() {
    _videoList = [];
    _currentKeyword = '';
    _errorMessage = '';
    notifyListeners();
  }

}
