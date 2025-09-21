// api/file_api_retrofit.dart
import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_token_response.dart';
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
      _AliFileApi(client.dio, baseUrl: config['baseUrl']);

  @POST("/adrive/v1.0/openFile/list")
  Future<AliDriveResponse> listFiles(@Body() Map<String, dynamic> body,@Header("Authorization") String token);

  @POST("/oauth/access_token")
  Future<AliTokenResponse> token( @Body() Map<String, dynamic> body);

  @POST("/file/copy")
  Future<void> copyFile({@Query("sourceId") required String sourceId, @Query("targetDirId") required String targetDirId});
  
  @POST("/file/move")
  Future<void> moveFile({@Query("sourceId") required String sourceId, @Query("targetDirId") required String targetDirId});

  @DELETE("/file/delete")
  Future<void> deleteFile(@Query("id") String id);

  @POST("/file/rename")
  Future<void> renameFile({@Query("id") required String id, @Query("newName") required String newName});
}
//eyJraWQiOiJLcU8iLCJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMmRkZDRlZDBiNDQ0NjkyOGEzMGUyYTYxYTljMTAxZiIsImF1ZCI6IjEyY2YyMTE4YmMzZTQ0NWFhYWViMzgwNzAwNTk4M2UyIiwicyI6ImNkYSIsImQiOiI3Mzk5ODAwODIsNzg4MjE5NTQyIiwiaXNzIjoiYWxpcGFuIiwiZXhwIjoxNzU4MDg4NTkzLCJpYXQiOjE3NTgwODEzOTAsImp0aSI6IjQwOTRmZDhkMmMxYjQ3NmFhYjAxYWU3ZGJhODU5MGEyIn0.9T5G9xPW5Gbs_4Ar220LhgJlM8kUoyz8BJxMm-EcTXo
