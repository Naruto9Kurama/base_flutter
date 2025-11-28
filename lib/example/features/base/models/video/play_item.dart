import 'package:json_annotation/json_annotation.dart';

part 'play_item.g.dart';



@JsonSerializable()
class PlayItem {
  final String name;
  final String url;
  final String episode;
  PlayItem(this.name, this.url,this.episode);

      factory PlayItem.fromJson(Map<String, dynamic> json) =>
      _$PlayItemFromJson(json);

  Map<String, dynamic> toJson() => _$PlayItemToJson(this);
}
