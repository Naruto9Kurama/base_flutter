import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final Map<String, dynamic> _config;

  AppConfig._(this._config);

  static Future<AppConfig> load() async {
    final jsonStr = await rootBundle.loadString('assets/config/config.json');
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return AppConfig._(map);
  }

  dynamic operator [](String key) => _config[key];

  /// 获取 vod 源配置，转换为正确的类型
  Map<String, Map<String, String>> getVodOptions() {
    final vodData = _config['vod'] as Map<String, dynamic>?;
    if (vodData == null) return {};
    
    final result = <String, Map<String, String>>{};
    vodData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = value.cast<String, String>();
      }
    });
    return result;
  }

  get aliyun=> _config['drives']['aliyundrive'];
}

