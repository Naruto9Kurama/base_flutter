// 视频数据模型类
class VideoModel {
  final String id;
  final String title;
  final String thumbnail;
  final String duration;
  final String author;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.author,
  });
}