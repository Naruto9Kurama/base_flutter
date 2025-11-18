
import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/drives/models/ali/ali_drive_response.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_file.g.dart';

@JsonSerializable()
class VideoFile extends FileItem {
  
  final String videoPlayUrl;
  VideoFile({required super.id, required super.filename, required super.isDirectory, required super.mountId, required this.videoPlayUrl});


  factory VideoFile.fromJson(Map<String, dynamic> json) =>
      _$VideoFileFromJson(json);
  Map<String, dynamic> toJson() => _$VideoFileToJson(this);
}