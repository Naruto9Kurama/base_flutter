import 'package:base_flutter/example/features/video/models/response/vod_videos.dart';
import 'package:get_it/get_it.dart';
import 'package:retrofit/retrofit.dart';
import 'package:base_flutter/core/api/dio_client.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

// @Injectable()
@LazySingleton()
class VodBaseApi {
  // Retrofit 生成的 dio 与 baseUrl
  // VodBaseApi(this.client, this.baseUrl); // 仍然使用 Retrofit 生成类

  // ============== 你手写的变量 ==============
  // Retrofit 不会处理 abstract class 里的普通字段
  DioClient client = GetIt.instance<DioClient>();
  // final String  baseUrl;

  Dio get dio => client.dio;

  // =======================================
  // ⛔️⛔️ 这个方法不使用 Retrofit，而是手写 Dio 请求
  // =======================================

  Future<VodVideos> baseParamApi(
    String fullUrl,
    Map<String, dynamic> param,
  ) async {
    try {
      final response = await dio.get(fullUrl, queryParameters: param);
      return VodVideos.fromJson(response.data);
    } catch (e, s) {
      print("GetVideoList error: $e");
      print(s);
      rethrow;
    }
  }

  Future<VodVideos> baseApi(String fullUrl) async {
    try {
      final response = await dio.get(fullUrl);
      return VodVideos.fromJson(response.data);
    } catch (e, s) {
      print("GetVideoList error: $e");
      print(s);
      rethrow;
    }
  }

  Future<VodVideos> getVideoList(
    String fullUrl,
    String query,
    int page,
    int limit,
  ) async {
    return baseApi(
      fullUrl
          .replaceAll("{wd}", Uri.encodeQueryComponent(query))
          .replaceAll("{pg}", page.toString())
          .replaceAll("{limit}", limit.toString()),
    );
  }

  Future<VodVideos> getVideoDetail(
    String fullUrl,
    String ids
  ) async {
    return baseApi(
      fullUrl.replaceAll("{ids}", ids),
    );
  }
}
