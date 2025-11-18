
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mount_config.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class MountConfig extends HiveObject {
  @HiveField(0)
  final FilePlatform driveType;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Map<String, dynamic> config;

  @HiveField(3)
  final String id;

  // // id字段：动态生成
  // @HiveField(4)
  // final String id;

  MountConfig({
    required this.driveType,
    required this.name,
    required this.config,
    // required this.id,
    String? id, // 可选传入
  }) : id = id ?? const Uuid().v4(); // 如果没传就生成 UUID

  factory MountConfig.fromJson(Map<String, dynamic> json) =>
      _$MountConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MountConfigToJson(this);
}



// @freezed
// @HiveType(typeId: 2) // 为DriveConfig分配一个唯一的typeId
// abstract class DriveConfig with _$DriveConfig {
//   @JsonSerializable(explicitToJson: true)
//   const factory DriveConfig({
//     @HiveField(0) required FilePlatform driveType,
//     @HiveField(1) required String name,
//     @HiveField(2) required Map<String, dynamic> config,
//   }) = _DriveConfig;
//
//   factory DriveConfig.fromJson(Map<String, dynamic> json) =>
//       _$DriveConfigFromJson(json);
// }