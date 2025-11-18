import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


part 'drive_config_base_template.freezed.dart';

/// 驱动器配置模板
@freezed
abstract class DriveConfigBaseTemplate with _$DriveConfigBaseTemplate {

  const factory  DriveConfigBaseTemplate({
    required FilePlatform driveType,
    required String displayName,
    required String description,
    required IconData icon,
    required  List<DriveConfigField> fields,
    required Function(MountConfig) onSave, //点击保存回调方法,return返回空字符则代表保存成功
    Color? primaryColor,
  })= _DriveConfigBaseTemplate;
}

/// 驱动器配置字段
class DriveConfigField {
  final String key;
  final String label;
  final String? hint;
  final DriveFieldType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? options; // 用于下拉框
  final String? Function(String?)? validator;
  final IconData? icon;
  final int? maxLines;
  final int? minLines;

  const DriveConfigField({
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validator,
    this.icon,
    this.maxLines,
    this.minLines,
  });
}


/// 驱动器配置字段类型
enum DriveFieldType {
  text,
  password,
  email,
  url,
  number,
  dropdown,
  checkbox,
  multiline,
}