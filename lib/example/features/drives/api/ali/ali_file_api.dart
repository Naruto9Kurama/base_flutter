// api/file_api_retrofit.dart
import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_token_response.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_video_preview_response.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_drive_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../../file/models/file/file_item.dart';
import 'package:injectable/injectable.dart';
import '../file_api.dart';

part 'ali_file_api.g.dart';

@RestApi()
@LazySingleton()
abstract class AliFileApi {

  @factoryMethod
  factory AliFileApi(DioClient client, AppConfig config) =>
      _AliFileApi(client.dio, baseUrl: config.aliyun['baseUrl']);

  @POST("/adrive/v1.0/openFile/list")
  Future<AliDriveResponse> listFiles(@Body() Map<String, dynamic> body,@Header("Authorization") String token);

  @POST("/oauth/access_token")
  Future<AliTokenResponse> token( @Body() Map<String, dynamic> body);

  @POST("/adrive/v1.0/openFile/copy")
  Future<void> copyFile(@Body() Map<String, dynamic> body,@Header("Authorization") String token);
  
  @POST("/adrive/v1.0/openFile/move")
  Future<void> moveFile(@Body() Map<String, dynamic> body,@Header("Authorization") String token);

  @POST("/adrive/v1.0/openFile/delete")
  Future<void> deleteFile(@Body() Map<String, dynamic> body,@Header("Authorization") String token);

  @POST("/file/rename")
  Future<void> renameFile(@Body() Map<String, dynamic> body,@Header("Authorization") String token);

  @POST("/adrive/v1.0/openFile/getVideoPreviewPlayInfo")
  Future<AliVideoPreviewResponse> videoPlayInfo(@Body() Map<String, dynamic> body,@Header("Authorization") String token);
}
//eyJraWQiOiJLcU8iLCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMmRkZDRlZDBiNDQ0NjkyOGEzMGUyYTYxYTljMTAxZiIsImF1ZCI6IjEyY2YyMTE4YmMzZTQ0NWFhYWViMzgwNzAwNTk4M2UyIiwicyI6ImNkYSIsImQiOiI3Mzk5ODAwODIsNzg4MjE5NTQyIiwiaXNzIjoiYWxpcGFuIiwiZXhwIjoxNzU4MDg4NTkzLCJpYXQiOjE3NTgwODEzOTAsImp0aSI6IjQwOTRmZDhkMmMxYjQ3NmFhYjAxYWU3ZGJhODU5MGEyIn0.9T5G9xPW5Gbs_4Ar220LhgJlM8kUoyz8BJxMm-EcTXo
