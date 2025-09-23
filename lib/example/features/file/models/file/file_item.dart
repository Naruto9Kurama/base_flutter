// models/file_item.dart
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_drive_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_item.g.dart';

@JsonSerializable()
class FileItem {
  final String id;
  String filename;
  final bool isDirectory;
  final String mountName;
  final String? ext;
  final int? size; // 字节
  final DateTime? modifiedAt;

  FileItem({
    required this.id,
    required this.filename,
    required this.isDirectory,
    required this.mountName,
    this.ext,
    this.size,
    this.modifiedAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) =>
      _$FileItemFromJson(json);
  Map<String, dynamic> toJson() => _$FileItemToJson(this);

  /// 显示名称：文件夹显示名称，文件显示带扩展名
  String get displayName {
    if (isDirectory || ext == null || ext!.isEmpty) {
      return filename;
    }
    return '$filename.$ext';
  }

  /// 可读大小字符串，例如 "1.2 MB"
  String get readableSize {
    if (isDirectory || size == null) return '';
    final kb = 1024;
    final mb = kb * 1024;
    final gb = mb * 1024;

    if (size! >= gb) return '${(size! / gb).toStringAsFixed(2)} GB';
    if (size! >= mb) return '${(size! / mb).toStringAsFixed(2)} MB';
    if (size! >= kb) return '${(size! / kb).toStringAsFixed(2)} KB';
    return '$size B';
  }

  /// 文件是否是图片类型
  bool get isImage {
    if (isDirectory || ext == null) return false;
    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExts.contains(ext!.toLowerCase());
  }

  /// 文件是否是视频类型
  bool get isVideo {
    if (isDirectory || ext == null) return false;
    const videoExts = ['mp4', 'avi', 'mkv', 'mov', 'flv', 'wmv'];
    return videoExts.contains(ext!.toLowerCase());
  }

  /// 判断文件是否有扩展名
  bool get hasExtension => !isDirectory && ext != null && ext!.isNotEmpty;

  /// 判断文件是否可预览（图片或视频）
  bool get isPreviewable => isImage || isVideo;

  static List<FileItem> toFileItemList(
    List<AliDriveItem> items,
    String ssMountName,
  ) {
    return items.map((e) => e.toFileItem(ssMountName)).toList();
  }
}
