import 'package:json_annotation/json_annotation.dart';

part 'ali_video_preview_response.g.dart';

@JsonSerializable(explicitToJson: true)
class AliVideoPreviewResponse {
  final String? domain_id;
  final String drive_id;
  final String file_id;
  final AliVideoPreviewPlayInfo video_preview_play_info;

  AliVideoPreviewResponse({
    this.domain_id,
    required this.drive_id,
    required this.file_id,
    required this.video_preview_play_info,
  });

  factory AliVideoPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$AliVideoPreviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AliVideoPreviewResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AliVideoPreviewPlayInfo {
  final String category;
  final List<LiveTranscodingTask> live_transcoding_task_list;
  final List<LiveTranscodingSubtitleTask>? liveTranscodingSubtitleTaskList;
  final String? playCursor;

  AliVideoPreviewPlayInfo({
    required this.category,
    required this.live_transcoding_task_list,
    this.liveTranscodingSubtitleTaskList,
    this.playCursor,
  });

  factory AliVideoPreviewPlayInfo.fromJson(Map<String, dynamic> json) =>
      _$AliVideoPreviewPlayInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AliVideoPreviewPlayInfoToJson(this);
}

@JsonSerializable()
class LiveTranscodingTask {
  final String template_id;
  final String status;
  final String url;
  final String? description;

  LiveTranscodingTask({
    required this.template_id,
    required this.status,
    required this.url,
    this.description,
  });

  factory LiveTranscodingTask.fromJson(Map<String, dynamic> json) =>
      _$LiveTranscodingTaskFromJson(json);

  Map<String, dynamic> toJson() => _$LiveTranscodingTaskToJson(this);
}

@JsonSerializable()
class LiveTranscodingSubtitleTask {
  final String language;
  final String status;
  final String? url;

  LiveTranscodingSubtitleTask({
    required this.language,
    required this.status,
    this.url,
  });

  factory LiveTranscodingSubtitleTask.fromJson(Map<String, dynamic> json) =>
      _$LiveTranscodingSubtitleTaskFromJson(json);

  Map<String, dynamic> toJson() => _$LiveTranscodingSubtitleTaskToJson(this);
}
