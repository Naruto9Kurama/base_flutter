

import 'package:hive_ce/hive.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drive_config.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class DriveConfig extends HiveObject {
  @HiveField(0)
  final FilePlatform driveType;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Map<String, dynamic> config;

  @HiveField(3)
  final String key;

  DriveConfig({
    required this.driveType,
    required this.name,
    required this.config,
    required this.key,
  });


  factory DriveConfig.fromJson(Map<String, dynamic> json) => _$DriveConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DriveConfigToJson(this);
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