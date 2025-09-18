import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveManager {
  /// 初始化 Hive
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  /// 注册 Adapter（每个模型只需注册一次）
  static void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// 打开 Box
  static Future<Box<T>> openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  /// 保存数据（key 可选，如果不传使用 Hive 自增 key）
  static Future<void> save<T>(Box<T> box, T value, {dynamic key}) async {
    if (key != null) {
      await box.put(key, value);
    } else {
      await box.add(value);
    }
  }

  /// 获取所有数据
  static List<T> getAll<T>(Box<T> box) {
    return box.values.toList();
  }

  /// 根据 key 获取单条数据
  static T? get<T>(Box<T> box, dynamic key) {
    return box.get(key);
  }

  /// 删除数据
  static Future<void> delete<T>(Box<T> box, dynamic key) async {
    await box.delete(key);
  }

  /// 清空 Box
  static Future<void> clear<T>(Box<T> box) async {
    await box.clear();
  }
}
