import 'package:json_annotation/json_annotation.dart';

part 'vod_video_info.g.dart';

@JsonSerializable()
class VodVideoInfo {
  @JsonKey(name: 'vod_id')
  final int vodId;

  @JsonKey(name: 'vod_name')
  final String vodName;

  @JsonKey(name: 'type_id')
  final int typeId;

  @JsonKey(name: 'type_name')
  final String typeName;

  @JsonKey(name: 'vod_en')
  final String? vodEn; // 改为可空

  @JsonKey(name: 'vod_time')
  final String? vodTime; // 改为可空

  @JsonKey(name: 'vod_remarks')
  final String? vodRemarks; // 改为可空

  @JsonKey(name: 'vod_play_from')
  final String? vodPlayFrom; // 改为可空

  @JsonKey(name: 'vod_pic')
  final String? vodPic; // 改为可空

  @JsonKey(name: 'vod_blurb')
  final String? vodBlurb; // 改为可空

  @JsonKey(name: 'vod_content')
  final String? vodContent; // 改为可空

  @JsonKey(name: 'vod_play_url')
  final String? vodPlayUrl; // 改为可空

  VodVideoInfo({
    required this.vodId,
    required this.vodName,
    required this.typeId,
    required this.typeName,
    this.vodEn,
    this.vodTime,
    this.vodRemarks,
    this.vodPlayFrom,
    this.vodPic,
    this.vodBlurb,
    this.vodContent,
    this.vodPlayUrl,
  });

  factory VodVideoInfo.fromJson(Map<String, dynamic> json) =>
      _$VodVideoInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VodVideoInfoToJson(this);
}