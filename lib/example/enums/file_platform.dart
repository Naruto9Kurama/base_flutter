import 'package:json_annotation/json_annotation.dart';

/// 文件来源
enum FilePlatform {
  @JsonValue('local')
  local,
  @JsonValue('baidu')
  baidu,
  @JsonValue('ftp')
  ftp,
  @JsonValue('aliyun')
  aliyun,
  @JsonValue('other')
  other,
}