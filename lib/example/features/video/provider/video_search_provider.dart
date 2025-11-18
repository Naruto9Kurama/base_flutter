import 'package:base_flutter/example/features/video/models/video_model.dart';
import 'package:flutter/material.dart';

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
      // TODO: 在这里添加实际的视频搜索API请求
      // 示例：
      // final response = await VideoService.searchVideos(keyword);
      // _videoList = response;

      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // 模拟搜索结果数据
      _videoList = _generateMockVideos(keyword);
      _isLoading = false;
      notifyListeners();
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

  // 生成模拟数据
  List<VideoModel> _generateMockVideos(String keyword) {
    return List.generate(
      10,
      (index) => VideoModel(
        id: 'video_${index + 1}',
        title: '${keyword}相关视频 ${index + 1}',
        thumbnail: 'https://via.placeholder.com/160x90',
        duration: '${(index + 1) * 2}:30',
        author: '作者${index + 1}',
      ),
    );
  }
}