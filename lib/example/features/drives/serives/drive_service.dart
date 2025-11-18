import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/constants/hive_boxes.dart';
import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:hive_ce/hive.dart';

import 'package:injectable/injectable.dart';

@LazySingleton()
class MountService {

  // 保存 驱动配置
  Future<void> saveMount(MountConfig driveConfig) async {
    Box<MountConfig> box = await HiveManager.openBox<MountConfig>(HiveBoxes.driveConfig);
    // 先删除原有 key（如果存在）
    if (box.containsKey(driveConfig.id)) {
      await box.delete(driveConfig.id);
    }
    await HiveManager.save(box, driveConfig, key: driveConfig.id);
  }

  // 保存 驱动配置
  Future<List<MountConfig>> getAllMount() async {
    Box<MountConfig> box= await HiveManager.openBox<MountConfig>(HiveBoxes.driveConfig);
    return HiveManager.getAll<MountConfig>(box);
  }

  Future<MountConfig?> getMount(String mountId) async {
    Box<MountConfig> box= await HiveManager.openBox<MountConfig>(HiveBoxes.driveConfig);
    return HiveManager.get<MountConfig>(box,mountId);
  }

}