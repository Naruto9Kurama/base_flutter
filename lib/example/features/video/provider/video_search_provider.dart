import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:base_flutter/example/features/video/respository/vod_respository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:injectable/injectable.dart';

// 视频搜索状态管理类
// @LazySingleton()
class VideoSearchProvider extends ChangeNotifier {
  List<VideoModel> _videoList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  String _currentKeyword = '';
  String _currentVodFrom = '';
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = false;

  List<VideoModel> get videoList => _videoList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get errorMessage => _errorMessage;
  String get currentKeyword => _currentKeyword;
  String get currentVodFrom => _currentVodFrom;
  bool get hasSearched => _currentKeyword.isNotEmpty;
  bool get hasMore => _hasMore;

  // 搜索视频的方法 - 预留给实际的API请求
  Future<void> searchVideos(String vodFrom, String keyword) async {
    if (keyword.trim().isEmpty) {
      _errorMessage = '请输入搜索关键词';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    _currentKeyword = keyword;
    _currentVodFrom = vodFrom;
    _currentPage = 1;
    _hasMore = false;
    notifyListeners();

    try {
      // 模拟搜索结果数据
      getIt
          .get<BaseVodRespository>()
          .searchVideo(vodFrom, keyword, _currentPage, _pageSize)
          .then((onValue) {
            _videoList = onValue;
            _isLoading = false;
            // 如果返回条数等于 pageSize，则可能还有更多
            _hasMore = onValue.length >= _pageSize;
            notifyListeners();
          });
    } catch (e) {
      _isLoading = false;
      _errorMessage = '搜索失败: $e';
      _videoList = [];
      notifyListeners();
    }
  }

  // 加载下一页
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore || _currentKeyword.isEmpty) return;
    _isLoadingMore = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final onValue = await getIt
          .get<BaseVodRespository>()
          .searchVideo(_currentVodFrom.isNotEmpty ? _currentVodFrom : 'jy', _currentKeyword, nextPage, _pageSize);
      if (onValue.isNotEmpty) {
        _videoList.addAll(onValue);
        _currentPage = nextPage;
        _hasMore = onValue.length >= _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = '加载更多失败: $e';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // 清除搜索结果
  void clearSearch() {
    _videoList = [];
    _currentKeyword = '';
    _errorMessage = '';
    notifyListeners();
  }

}
