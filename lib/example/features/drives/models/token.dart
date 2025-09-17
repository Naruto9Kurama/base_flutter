import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:hive_ce/hive.dart';

part 'token.g.dart'; // 生成适配器

@HiveType(typeId: 0)
class Token {
  @HiveField(0)
  final FilePlatform platform;

  @HiveField(1)
  final String value;

  Token({required this.platform, required this.value});

  String getBearerToken(){
    return 'Bearer $value';
  }
   String getToken(){
    return value;
  }
}
