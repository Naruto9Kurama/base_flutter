import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';


@LazySingleton()
class Global {
  // 内存缓存
  final Map<String, dynamic> _memoryCache = {};
  // Hive 持久化
  Box? _box;

  List<MountConfig> driveConfigs = [];


  /// 初始化 Hive
  Future<void> init() async {
    MountService service=GetIt.instance.get<MountService>();
    service.getAllMount().then((drives) {
      driveConfigs = drives;
    });
  }

  /// 动态缓存
  void set(String key, dynamic value, {bool persist = false}) {
    _memoryCache[key] = value;
    if (persist) _box?.put(key, value);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    return _box?.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 清空缓存
  void clear() {
    _memoryCache.clear();
    _box?.clear();
  }
}
