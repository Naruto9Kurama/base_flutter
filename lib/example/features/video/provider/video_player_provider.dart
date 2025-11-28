import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/respository/vod/base_vod_respository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dart:convert';

// @LazySingleton()
class VideoPlayerProvider extends ChangeNotifier {
  late VideoModel videoModel;
  BaseVodRespository baseVodRespository = GetIt.instance
      .get<BaseVodRespository>();
  Future<void> setVideoModel(VideoModel videoModel) async {
    this.videoModel = videoModel;
    baseVodRespository.videoDetail(videoModel.from, videoModel.id).then((
      value,
    ) {
      this.videoModel = value;
      notifyListeners();
    });
  }
}
