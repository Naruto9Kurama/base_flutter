import 'package:base_flutter/example/features/drives/models/token.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:hive_ce/hive.dart';

import 'package:injectable/injectable.dart';

@LazySingleton()
class TokenService {
  String key="TokenService_";
  // 保存 Token
  Future<void> saveToken(Token token) async {
    var box = await Hive.openBox<Token>('tokenBox');
    await box.put(key+token.platform.name, token);  // 根据平台来存储 token
    await box.close();
  }

  // 根据平台获取 Token
  Future<Token?> getToken(FilePlatform platform) async {
    var box = await Hive.openBox<Token>('tokenBox');
    
    // 根据平台获取对应的 Token
    Token? token = await box.get(key+platform.name); // 使用平台的名字作为 key

    await box.close();

    return token;
  }

}