import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/constants/hive_boxes.dart';
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:hive_ce/hive.dart';

import 'package:injectable/injectable.dart';

@LazySingleton()
class DriveService {

  // 保存 驱动配置
  Future<void> saveDrive(DriveConfig driveConfig) async {
    Box<DriveConfig> box = await HiveManager.openBox<DriveConfig>(HiveBoxes.driveConfig);
    // 先删除原有 key（如果存在）
    if (box.containsKey(driveConfig.key)) {
      await box.delete(driveConfig.key);
    }
    await HiveManager.save(box, driveConfig, key: driveConfig.key);
  }

  // 保存 驱动配置
  Future<List<DriveConfig>> getAllDrive() async {
    Box<DriveConfig> box= await HiveManager.openBox<DriveConfig>(HiveBoxes.driveConfig);
    return HiveManager.getAll<DriveConfig>(box);
  }

  Future<DriveConfig?> getDrive(String mountName) async {
    Box<DriveConfig> box= await HiveManager.openBox<DriveConfig>(HiveBoxes.driveConfig);
    return HiveManager.get<DriveConfig>(box,mountName);
  }

}