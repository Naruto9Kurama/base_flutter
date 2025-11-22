import 'dart:convert';

import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/features/video/api/vod_base_api.dart';
import 'package:base_flutter/example/features/video/models/vod_video_info.dart';
import 'package:base_flutter/example/features/video/respository/vod_respository.dart';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class BaseVodRespository extends VodRespository {
  // final String baseUrl;
  final AppConfig _appConfig = GetIt.instance.get<AppConfig>();
  final VodBaseApi _vodBaseApi = GetIt.instance.get<VodBaseApi>();

  // BaseVodRespository({required this.baseUrl,required this.appConfig}){
  //   vodBaseApi=VodBaseApi(GetIt.instance.get<DioClient>(),baseUrl);
  // }

  @override
  Future<List<VideoModel>> searchVideo(
    String vodFromName,
    String wd,
    int pg,
    int limit,
  ) {
    Map<String, dynamic> map = _appConfig['vod'][vodFromName];
    String searchUrl = map['searchUrl'];
    print(map);
    print(searchUrl);
    return _vodBaseApi.getVideoList(searchUrl, wd, pg, limit).then((videoList) {
      print(json.encode(videoList));
      return videoList.list.map((video) {
        print(video.vodPlayUrl);
        return VideoModel(
          id: video.vodId.toString(),
          title: video.vodName,
          duration: "0",
          thumbnail: "",
          vodPlayUrl: video.vodPlayUrl ?? '',
          from: vodFromName,
        );
      }).toList();
    });
  }

  Future<VideoModel> videoDetail(String vodFromName, String id) {
    Map<String, dynamic> map = _appConfig['vod'][vodFromName];
    String detailUrl = map['detailUrl'];
    return _vodBaseApi.getVideoDetail(detailUrl, id).then((videoList) {
      // print("111111111111111111111111");
      VodVideoInfo video = videoList.list[0];
      // print(videoList);
      // print(video);
      return VideoModel(
        id: video.vodId.toString(),
        title: video.vodName,
        duration: "0",
        thumbnail: "",
        vodPlayUrl: video.vodPlayUrl ?? '',
        from: vodFromName,
      );
    });
  }
}
