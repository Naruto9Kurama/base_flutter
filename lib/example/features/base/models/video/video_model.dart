import 'package:base_flutter/example/features/base/models/video/play_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

// 视频数据模型类
@JsonSerializable()
class VideoModel {
  final String id;
  final String title;
  final String thumbnail;
  final String duration;
  final String? pic;
  final String? detail;
  final String from;

  @JsonKey(ignore: true)  // 忽略 JSON 序列化时的反序列化
  final String? _vodPlayUrl;  // 可为 null 的原始字符串字段

  // 通过 getter 自动解析
  List<PlayItem> get playUrls {
    if (_vodPlayUrl == null || _vodPlayUrl.isEmpty) {
      return [];  // 如果没有数据，返回空列表
    }
    return _parseVodPlayUrl(title,_vodPlayUrl);
  }

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    String? vodPlayUrl, // 可选的 vodPlayUrl 字段
    this.pic,
    this.detail,
    required this.from, // 可选的 vodPlayUrl 字段
  }) : _vodPlayUrl = vodPlayUrl;  // 直接传入 vodPlayUrl，保持 null 可用

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  // 静态工具方法，避免实例化前调用问题
  static List<PlayItem> _parseVodPlayUrl(String title,String vodPlayUrl) {
    print(vodPlayUrl);
    return vodPlayUrl
        .split('#') // 每一集
        .where((e) => e.contains('\$')) // 过滤无效项
        .map((e) {
          final parts = e.split('\$');
          if (parts.length < 2) return null;
          return PlayItem(title, parts[1],parts[0]); // 返回 PlayItem
        })
        .whereType<PlayItem>() // 过滤 null 值
        .toList();
  }
}
