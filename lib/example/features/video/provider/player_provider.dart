// player_provider.dart
import 'package:base_flutter/example/features/base/models/video/play_item.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/pages/video/player/video_state.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:get_it/get_it.dart';
import '../respository/vod/base_vod_respository.dart';

class PlayerProvider extends ChangeNotifier {
  late final Player player;
  late final VideoControllerState controllerState;
  late int currentIndex = 0;

  VideoModel? videoModel;
  List<PlayItem> playlist = [];
  String selectedSource = "jy";
  List<String> videoSources = ["jy","hongniu"];

  bool initialized = false;

  PlayerProvider() {
    player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 64 * 1024 * 1024,
      ),
    );
  }

  void init(VideoModel model, int episodeIndex) {
    if (initialized) return;
    initialized = true;

    videoModel = model;
    playlist = List.from(model.playUrls);
    currentIndex = episodeIndex.clamp(0, playlist.length - 1);

    controllerState = VideoControllerState(
      player: player,
      playlist: playlist,
      currentIndex: currentIndex,
      onSwitchEpisode: loadVideo,
    );

    // ✅ 关键：先加载视频，再初始化监听器
    player.open(Media(playlist[currentIndex].url)).then((_) {
      // 视频加载完成后，再初始化监听器
      controllerState.initialize();
    });
  }

  void loadVideo(int index) {
    if (index < 0 || index >= playlist.length) return;
    currentIndex = index;
    player.open(Media(playlist[currentIndex].url));
    controllerState.syncCurrentIndex(index);
    controllerState.resetAutoAdvance();
    notifyListeners();
  }

  Future<void> changeSource(String newSource) async {
    selectedSource = newSource;
    notifyListeners();

    if (videoModel == null) return;

    final resp = await GetIt.instance
        .get<BaseVodRespository>()
        .searchVideo(selectedSource, videoModel!.title, 1, 1);

    if (resp.isEmpty) return;

    final t = resp.first;
    if (t.playUrls.isEmpty) return;

    playlist = t.playUrls;

    if (currentIndex >= playlist.length) currentIndex = 0;

    player.open(Media(playlist[currentIndex].url));

    controllerState.updatePlaylist(playlist);
    controllerState.syncCurrentIndex(currentIndex);

    notifyListeners();
  }

  @override
  void dispose() {
    controllerState.dispose();
    player.dispose();
    super.dispose();
  }
}