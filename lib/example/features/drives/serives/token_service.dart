import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/features/drives/api/ali/ali_file_api.dart';
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/features/drives/models/token.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';

import 'package:injectable/injectable.dart';

@LazySingleton()
class TokenService {
  String key = "TokenService_";
  // 保存 Token
  Future<void> saveToken(Token token) async {
    var box = await Hive.openBox<Token>('tokenBox');
    await box.put(key + token.platform.name, token); // 根据平台来存储 token
    await box.close();
  }

  // 根据平台获取 Token
  Future<String?> getToken(String ssMountName) async {
    DriveService driveService = GetIt.instance<DriveService>();

    return driveService.getDrive(ssMountName).then((driveConfig) {
      // Map<String, dynamic> map = driveConfig?.config??{};
      AliFileApi aliFileApi = GetIt.instance<AliFileApi>();
      // String refreshToken = map['refresh_token'];
      return aliFileApi.token({
            "client_id": "12cf2118bc3e445aaaeb3807005983e2",
            "client_secret": "86f83dfd84a94d93873bab44f3b6af7a",
            "grant_type": "refresh_token",
            "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIwMmRkZDRlZDBiNDQ0NjkyOGEzMGUyYTYxYTljMTAxZiIsImF1ZCI6IjEyY2YyMTE4YmMzZTQ0NWFhYWViMzgwNzAwNTk4M2UyIiwiZXhwIjoxNzY2MjI1MzM1LCJpYXQiOjE3NTg0NDkzMzUsImp0aSI6IjNhZGQ3NTEzYzgyYjQzYjI5ZDFmMTE1MGQ5ZGM1NzM2In0.E1cZhVd8QdUrRRvmhMhSrRy_iMCmXCZrlWFtssDdPTkojOXR_rv3wDw_AKdaovdFCJRrNdhJiZDhgtjWHBfXxg",
            // "refresh_token": refreshToken,
          })
          .then((aliTokenResponse) {
            return aliTokenResponse.access_token;
          });
    });
  }
}
