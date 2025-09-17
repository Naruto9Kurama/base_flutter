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
}
