import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/features/drives/api/ali/ali_file_api.dart';
import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:base_flutter/example/features/drives/models/token.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';

import 'package:injectable/injectable.dart';

@LazySingleton()
class TokenService {
  String key = "TokenService_";

  AppConfig config=GetIt.instance<AppConfig>();
  // 保存 Token
  Future<void> saveToken(Token token) async {
    var box = await Hive.openBox<Token>('tokenBox');
    await box.put(key + token.platform.name, token); // 根据平台来存储 token
    await box.close();
  }

  // 根据平台获取 Token
  Future<String?> getToken(String mountId) async {
    MountService driveService = GetIt.instance<MountService>();

    return driveService.getMount(mountId).then((driveConfig) {
      switch (driveConfig?.driveType) {
        case null:
          // TODO: Handle this case.
          throw UnimplementedError();
        case FilePlatform.local:
          // TODO: Handle this case.
          throw UnimplementedError();
        case FilePlatform.baidu:
          // TODO: Handle this case.
          throw UnimplementedError();
        case FilePlatform.ftp:
          // TODO: Handle this case.
          throw UnimplementedError();
        case FilePlatform.aliyun:
          AliFileApi aliFileApi = GetIt.instance<AliFileApi>();
          String refreshToken = driveConfig?.config['refresh_token'];
          return aliFileApi
              .token({
                "client_id": config.aliyun['client_id'],
                "client_secret": config.aliyun['client_secret'],
                "grant_type": "refresh_token",
                // "refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIwMmRkZDRlZDBiNDQ0NjkyOGEzMGUyYTYxYTljMTAxZiIsImF1ZCI6IjEyY2YyMTE4YmMzZTQ0NWFhYWViMzgwNzAwNTk4M2UyIiwiZXhwIjoxNzY2MjI1MzM1LCJpYXQiOjE3NTg0NDkzMzUsImp0aSI6IjNhZGQ3NTEzYzgyYjQzYjI5ZDFmMTE1MGQ5ZGM1NzM2In0.E1cZhVd8QdUrRRvmhMhSrRy_iMCmXCZrlWFtssDdPTkojOXR_rv3wDw_AKdaovdFCJRrNdhJiZDhgtjWHBfXxg",
                "refresh_token": refreshToken,
              })
              .then((aliTokenResponse) {
                return "${aliTokenResponse.token_type} ${aliTokenResponse.access_token}";
              });
        case FilePlatform.other:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }
}
