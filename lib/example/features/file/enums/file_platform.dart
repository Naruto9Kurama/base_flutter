import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

// 添加这个part指令来生成适配器
part 'file_platform.g.dart';  // 确保文件名匹配你的实际文件名


/// 文件来源
/// 文件来源
@HiveType(typeId: 1)
enum FilePlatform {
  @HiveField(0)
  @JsonValue('local')
  local,
  @HiveField(1)
  @JsonValue('baidu')
  baidu,
  @HiveField(2)
  @JsonValue('ftp')
  ftp,
  @HiveField(3)
  @JsonValue('aliyun')
  aliyun,
  @HiveField(4)
  @JsonValue('other')
  other,
}

/// 扩展方法：获取图标、描述等
extension FilePlatformExt on FilePlatform {
  /// 显示名称
  String get displayName {
    switch (this) {
      case FilePlatform.local:
        return '本地';
      case FilePlatform.baidu:
        return '百度云';
      case FilePlatform.ftp:
        return 'FTP';
      case FilePlatform.aliyun:
        return '阿里云';
      case FilePlatform.other:
        return '其他';
    }
  }

  /// 图标
  IconData get icon {
    switch (this) {
      case FilePlatform.local:
        return Icons.computer;
      case FilePlatform.baidu:
        return Icons.cloud;
      case FilePlatform.ftp:
        return Icons.folder_shared;
      case FilePlatform.aliyun:
        return Icons.cloud_upload;
      case FilePlatform.other:
        return Icons.more_horiz;
    }
  }

  /// 主色
  Color get color {
    switch (this) {
      case FilePlatform.local:
        return Colors.blueGrey;
      case FilePlatform.baidu:
        return Colors.blue;
      case FilePlatform.ftp:
        return Colors.orange;
      case FilePlatform.aliyun:
        return Colors.green;
      case FilePlatform.other:
        return Colors.grey;
    }
  }
}
