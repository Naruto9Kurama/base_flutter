import 'package:base_flutter/example/features/video/models/vod_video_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vod_videos.g.dart';

@JsonSerializable()
class VodVideos {
  @JsonKey(fromJson: _toInt)
  final int code;
  
  final String msg;
  
  @JsonKey(fromJson: _toInt)
  final int page;
  
  @JsonKey(fromJson: _toInt)
  final int pagecount;
  
  @JsonKey(fromJson: _toInt)
  final int limit;
  
  @JsonKey(fromJson: _toInt)
  final int total;
  
  final List<VodVideoInfo> list;

  VodVideos({
    required this.code,
    required this.msg,
    required this.page,
    required this.pagecount,
    required this.limit,
    required this.total,
    required this.list,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory VodVideos.fromJson(Map<String, dynamic> json) =>
      _$VodVideosFromJson(json);

  Map<String, dynamic> toJson() => _$VodVideosToJson(this);
}