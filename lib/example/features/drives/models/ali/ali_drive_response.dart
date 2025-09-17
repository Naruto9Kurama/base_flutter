import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ali_drive_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AliDriveResponse {
  final List<AliDriveItem> items;
  final String? next_marker;

  AliDriveResponse({
    required this.items,
    this.next_marker,
  });

  factory AliDriveResponse.fromJson(Map<String, dynamic> json) =>
      _$AliDriveResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AliDriveResponseToJson(this);
}

@JsonSerializable()
class AliDriveItem {
  final bool? trashed;
  final String? name;
  final String? thumbnail;
  final String? type;
  final String? category;
  final bool? hidden;
  final String? status;
  final String? description;
  final String? meta;
  final String? url;
  final int? size;
  final bool? starred;
  final String? location;
  final String? deleted;
  final String? channel;
  final String? user_tags;
  final String? mime_type;
  final String? parent_file_id;
  final String? drive_id;
  final String? file_id;
  final String? file_extension;
  final String? revision_id;
  final String? content_hash;
  final String? content_hash_name;
  final String? encrypt_mode;
  final String? domain_id;
  final String? download_url;
  final String? user_meta;
  final String? content_type;
  final String? created_at;
  final String? updated_at;
  final String? local_created_at;
  final String? local_modified_at;
  final String? trashed_at;
  final String? punish_flag;
  final String? id_path;
  final String? name_path;
  final String? video_media_metadata;
  final String? image_media_metadata;
  final String? video_preview_metadata;
  final String? streams_info;
  final String? play_cursor;

  AliDriveItem({
    this.trashed,
    this.name,
    this.thumbnail,
    this.type,
    this.category,
    this.hidden,
    this.status,
    this.description,
    this.meta,
    this.url,
    this.size,
    this.starred,
    this.location,
    this.deleted,
    this.channel,
    this.user_tags,
    this.mime_type,
    this.parent_file_id,
    this.drive_id,
    this.file_id,
    this.file_extension,
    this.revision_id,
    this.content_hash,
    this.content_hash_name,
    this.encrypt_mode,
    this.domain_id,
    this.download_url,
    this.user_meta,
    this.content_type,
    this.created_at,
    this.updated_at,
    this.local_created_at,
    this.local_modified_at,
    this.trashed_at,
    this.punish_flag,
    this.id_path,
    this.name_path,
    this.video_media_metadata,
    this.image_media_metadata,
    this.video_preview_metadata,
    this.streams_info,
    this.play_cursor,
  });

  factory AliDriveItem.fromJson(Map<String, dynamic> json) =>
      _$AliDriveItemFromJson(json);

  Map<String, dynamic> toJson() => _$AliDriveItemToJson(this);

  // 将 AliDriveItem 转换为 FileItem
  FileItem toFileItem() {
    return FileItem(
      id: file_id ?? '',
      filename: name ?? '',
      ext: file_extension,
      isDirectory: type == 'folder',
      size: size,
      origin: FilePlatform.aliyun,
    );
  }

  /// 批量转换
  static List<FileItem> toFileItemList(
      List<AliDriveItem> items) {
    return items.map((e) => e.toFileItem()).toList();
  }

  /// 工具属性
  bool get isFolder => type == "folder";
  bool get isFile => type == "file";
}
