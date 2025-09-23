// templates/aliyun_drive_template.dart
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/constants/hive_boxes.dart';
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/pages/drive/models/drive_config_base_template.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';

class AliyunDriveTemplate {
  static DriveConfigBaseTemplate get template => DriveConfigBaseTemplate(
    driveType: FilePlatform.aliyun,
    displayName: FilePlatform.aliyun.displayName,
    description: '连接到你的阿里云盘账户，访问云端文件',
    icon: Icons.cloud,
    primaryColor: const Color(0xFF1890FF),
    fields: [
      DriveConfigField(
        key: 'refresh_token',
        label: '刷新令牌',
        hint: '从阿里云盘获取的 refresh_token',
        type: DriveFieldType.multiline,
        required: true,
        icon: Icons.key,
        maxLines: 4,
        minLines: 2,
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          if (value.length < 50) {
            return 'refresh_token 长度不足';
          }
          return null;
        },
      ),
      DriveConfigField(
        key: 'root_folder_id',
        label: '根文件夹ID',
        hint: '指定根目录文件夹ID，留空表示使用默认根目录',
        type: DriveFieldType.text,
        required: false,
        icon: Icons.folder_open,
        defaultValue: 'root',
      ),
      DriveConfigField(
        key: 'chunk_size',
        label: '分块大小',
        hint: '文件传输时的分块大小（MB）',
        type: DriveFieldType.number,
        required: false,
        icon: Icons.memory,
        defaultValue: '10',
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final num = int.tryParse(value);
          if (num == null || num <= 0 || num > 100) {
            return '分块大小必须在 1-100 MB 之间';
          }
          return null;
        },
      ),
      DriveConfigField(
        key: 'enable_rapid_upload',
        label: '启用秒传功能',
        hint: '开启后将尝试使用阿里云盘的秒传功能',
        type: DriveFieldType.checkbox,
        required: false,
        defaultValue: 'true',
      ),
      DriveConfigField(
        key: 'cache_expiry',
        label: '缓存过期时间',
        hint: '文件列表缓存的过期时间（分钟）',
        type: DriveFieldType.number,
        required: false,
        icon: Icons.timer,
        defaultValue: '30',
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final num = int.tryParse(value);
          if (num == null || num < 1 || num > 1440) {
            return '缓存时间必须在 1-1440 分钟之间';
          }
          return null;
        },
      ),
      DriveConfigField(
        key: 'download_thread_count',
        label: '下载线程数',
        hint: '同时下载的线程数量',
        type: DriveFieldType.dropdown,
        required: false,
        icon: Icons.download,
        options: ['1', '2', '4', '6', '8', '10'],
        defaultValue: '4',
      ),
      DriveConfigField(
        key: 'enable_thumbnail',
        label: '启用缩略图',
        hint: '为图片和视频文件生成缩略图',
        type: DriveFieldType.checkbox,
        required: false,
        defaultValue: 'true',
      ),
      DriveConfigField(
        key: 'api_base_url',
        label: 'API基础地址',
        hint: '自定义API服务器地址（高级选项）',
        type: DriveFieldType.url,
        required: false,
        icon: Icons.link,
        defaultValue: GetIt.instance<AppConfig>().aliyun['baseUrl'],
        validator: FormBuilderValidators.url(errorText: '请输入有效的URL地址'),
      ),
    ],
    onSave:  (updatedConfig) async {
      DriveService service=GetIt.instance<DriveService>();
      service.saveDrive(updatedConfig);
      return "";
    }
  );
}