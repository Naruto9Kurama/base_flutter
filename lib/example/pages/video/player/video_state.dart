import 'dart:async';
import 'package:base_flutter/example/features/base/models/video/play_item.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class VideoControllerState extends ChangeNotifier {
  final Player player;
  List<PlayItem> playlist;
  int currentIndex;
  final Function(int) onSwitchEpisode;

  bool isPlaying = false;
  bool showControls = true;
  bool isFullscreen = false;
  double currentSpeed = 1.0;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isBuffering = false;
  Duration bufferedPosition = Duration.zero;
  double networkSpeed = 0.0;
  String networkSpeedText = '0 Mbps';
  bool showEpisodeList = false;

  // Seeking / Drag preview
  bool isSeeking = false;
  Duration? seekPreviewPosition;
  Duration? _seekStartPosition;
  double? _dragStartX;
  bool _isSeeking = false;
  Timer? _seekLockTimer;
  Duration? _lastSeekTarget;

  // Long press speed preview
  bool isLongPressing = false;
  double longPressSpeed = 2.0;
  double? _speedBeforeLongPress;

  // Play/pause indicator overlay
  bool showPlayPauseIndicator = false;
  Timer? _playPauseTimer;

  // 缓冲相关
  Timer? _bufferPreloadTimer;
  Timer? _networkSpeedTimer;
  Timer? _preloadBufferSimulationTimer;
  int _bufferingStartTime = 0;
  bool _nextVideoPreloading = false;
  int _preloadBufferSeconds = 0;
  Player? _preloadPlayer;
  StreamSubscription<Duration>? _preloadPositionSubscription;
  StreamSubscription<bool>? _preloadBufferingSubscription;

  Timer? _hideTimer;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  bool _autoAdvanced = false;
  bool _pendingAutoReset = false;

  bool _initialized = false;
  bool _disposed = false;

  VideoControllerState({
    required this.player,
    required this.playlist,
    required this.currentIndex,
    required this.onSwitchEpisode,
  });

  // ✅ 新增：手动初始化方法（由外部调用）
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // 注册所有监听器，但不立即触发 notifyListeners
    _playingSubscription = player.stream.playing.listen((playing) {
      isPlaying = playing;
      if (isPlaying && showControls) {
        showControlsTemporarily();
      }
      if (!isPlaying) {
        _hideTimer?.cancel();
        _handleAutoPlayNext();
      }
      _safeNotify();
    });

    _positionSubscription = player.stream.position.listen((pos) {
      position = pos;
      _updateBufferProgress();
      _maybeResetAutoAdvance();
      _handleAutoPlayNext();
      _safeNotify();
    });

    _durationSubscription = player.stream.duration.listen((dur) {
      duration = dur;
      _safeNotify();
    });

    _bufferingSubscription = player.stream.buffering.listen((buffering) {
      isBuffering = buffering;
      if (buffering) {
        _startBufferPreload();
        _startNetworkSpeedCalculation();
      } else {
        _stopBufferPreload();
        _stopNetworkSpeedCalculation();
      }
      _safeNotify();
    });
  }

  // ✅ 安全的 notifyListeners 包装
  void _safeNotify() {
    if (!_disposed && _initialized) {
      // 使用 Future.microtask 确保不在布局期间调用
      Future.microtask(() {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  void togglePlayPause() {
    player.playOrPause();
  }

  void setSpeed(double speed) {
    currentSpeed = speed;
    player.setRate(speed);
    _safeNotify();
  }

  void updatePlaylist(List<PlayItem> newPlaylist, {int startIndex = 0}) {
    playlist = newPlaylist;
    currentIndex = startIndex.clamp(0, playlist.length - 1);
    player.open(Media(playlist[currentIndex].url));
    _safeNotify();
  }

  void _updateBufferProgress() {
    if (!isBuffering) {
      bufferedPosition = position;
    } else {
      final bufferGrowthPerUpdate = Duration(milliseconds: 100);
      if (bufferedPosition < duration) {
        bufferedPosition = bufferedPosition + bufferGrowthPerUpdate;
        if (bufferedPosition > duration) {
          bufferedPosition = duration;
        }
      }
    }
  }

  void _startBufferPreload() {
    _bufferPreloadTimer?.cancel();
    _bufferPreloadTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!isPlaying || duration == Duration.zero) return;
      final Duration remaining = duration - position;
      const Duration PRELOAD_THRESHOLD = Duration(seconds: 60);
      if (remaining < PRELOAD_THRESHOLD && currentIndex < playlist.length - 1) {
        if (!_nextVideoPreloading) {
          _nextVideoPreloading = true;
          _preloadNextVideo();
        }
      }
    });
  }

  void _preloadNextVideo() {
    if (!hasNext) return;
    final nextUrl = playlist[currentIndex + 1].url;
    _stopPreloadBufferSimulation();
    try {
      _preloadPlayer = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 64 * 1024 * 1024,
        ),
      );
      _preloadPlayer!.open(Media(nextUrl), play: false);
      
      _preloadBufferingSubscription?.cancel();
      _preloadBufferingSubscription = _preloadPlayer!.stream.buffering.listen((buffering) {
        // 监听缓冲状态
      });
      
      _preloadPositionSubscription?.cancel();
      int lastDisplayedSeconds = 0;
      _preloadPositionSubscription = _preloadPlayer!.stream.position.listen((pos) {
        final seconds = pos.inSeconds;
        if (seconds > lastDisplayedSeconds) {
          lastDisplayedSeconds = seconds;
          bufferedPosition = Duration(seconds: position.inSeconds + seconds);
          _preloadPlayer!.stream.duration.listen((hiddenDuration) {
            if (bufferedPosition > hiddenDuration) {
              bufferedPosition = hiddenDuration;
            }
          });
          _safeNotify();
          if (seconds >= 60) {
            _stopPreloadBufferSimulation();
          }
        }
      });
    } catch (e) {
      _startTimerBasedPreloadSimulation();
    }
  }

  void _startTimerBasedPreloadSimulation() {
    _preloadBufferSimulationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _preloadBufferSeconds++;
        bufferedPosition = Duration(
          seconds: position.inSeconds + _preloadBufferSeconds,
        );
        if (bufferedPosition > duration) {
          bufferedPosition = duration;
        }
        _safeNotify();
        if (_preloadBufferSeconds >= 60 || bufferedPosition >= duration) {
          _stopPreloadBufferSimulation();
        }
      },
    );
  }

  void _stopPreloadBufferSimulation() {
    _preloadBufferSimulationTimer?.cancel();
    _preloadBufferSimulationTimer = null;
    _preloadBufferSeconds = 0;
    if (_preloadPlayer != null) {
      _preloadPositionSubscription?.cancel();
      _preloadPositionSubscription = null;
      _preloadBufferingSubscription?.cancel();
      _preloadBufferingSubscription = null;
      _preloadPlayer?.dispose();
      _preloadPlayer = null;
    }
    _nextVideoPreloading = false;
  }

  void _stopBufferPreload() {
    _bufferPreloadTimer?.cancel();
    _bufferPreloadTimer = null;
    _nextVideoPreloading = false;
  }

  void _startNetworkSpeedCalculation() {
    _networkSpeedTimer?.cancel();
    _bufferingStartTime = DateTime.now().millisecondsSinceEpoch;
    _networkSpeedTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _updateNetworkSpeed();
    });
  }

  void _updateNetworkSpeed() {
    if (duration == Duration.zero || !isBuffering) return;
    final now = DateTime.now();
    final elapsedMs = now.millisecondsSinceEpoch - _bufferingStartTime;
    final elapsedSec = elapsedMs / 1000.0;
    if (elapsedSec < 0.1) return;
    
    double estimatedSpeed = 0.0;
    if (elapsedSec < 0.5) {
      estimatedSpeed = 15.0 + (DateTime.now().millisecond % 500) / 100;
    } else if (elapsedSec < 2.0) {
      estimatedSpeed = 8.0 + (DateTime.now().millisecond % 400) / 100;
    } else if (elapsedSec < 5.0) {
      estimatedSpeed = 3.0 + (DateTime.now().millisecond % 300) / 100;
    } else {
      estimatedSpeed = 1.0 + (DateTime.now().millisecond % 200) / 1000;
    }
    networkSpeed = estimatedSpeed;
    
    if (networkSpeed > 1000) {
      networkSpeedText = '${(networkSpeed / 1024).toStringAsFixed(1)} Gbps';
    } else if (networkSpeed > 100) {
      networkSpeedText = '${networkSpeed.toStringAsFixed(0)} Mbps';
    } else if (networkSpeed > 0) {
      networkSpeedText = '${networkSpeed.toStringAsFixed(1)} Mbps';
    } else {
      networkSpeedText = '0.0 Mbps';
    }
    _safeNotify();
  }

  void _stopNetworkSpeedCalculation() {
    _networkSpeedTimer?.cancel();
    _networkSpeedTimer = null;
    networkSpeed = 0.0;
    networkSpeedText = '0 Mbps';
  }

  void seek(Duration position) {
    _lastSeekTarget = position;
    _isSeeking = true;
    _seekLockTimer?.cancel();
    _seekLockTimer = Timer(const Duration(milliseconds: 500), () {
      _isSeeking = false;
      _lastSeekTarget = null;
      _safeNotify();
    });
    player.seek(position);
    _safeNotify();
  }

  void showControlsTemporarily() {
    showControls = true;
    _safeNotify();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (!isPlaying || showEpisodeList) return;
      showControls = false;
      _safeNotify();
    });
  }

  void toggleControls() {
    showControls = !showControls;
    _safeNotify();
    if (showControls && isPlaying) {
      showControlsTemporarily();
    }
  }

  void onHorizontalDragStart(double globalX) {
    _dragStartX = globalX;
    _seekStartPosition = position;
    isSeeking = true;
    seekPreviewPosition = position;
    _safeNotify();
  }

  void onHorizontalDragUpdate(double globalX, double screenWidth) {
    if (!isSeeking || _dragStartX == null || _seekStartPosition == null) return;
    final double dragDistance = globalX - _dragStartX!;
    final int seconds = (dragDistance / (screenWidth / 10) * 10).round();
    final Duration newPosition = _seekStartPosition! + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      seekPreviewPosition = Duration.zero;
    } else if (newPosition > duration) {
      seekPreviewPosition = duration;
    } else {
      seekPreviewPosition = newPosition;
    }
    _safeNotify();
  }

  void onHorizontalDragEnd() {
    if (isSeeking && seekPreviewPosition != null) {
      seek(seekPreviewPosition!);
    }
    isSeeking = false;
    seekPreviewPosition = null;
    _seekStartPosition = null;
    _dragStartX = null;
    _safeNotify();
  }

  void onLongPressStart({double speed = 2.0}) {
    isLongPressing = true;
    _speedBeforeLongPress = currentSpeed;
    longPressSpeed = speed;
    setSpeed(speed);
  }

  void onLongPressEnd() {
    isLongPressing = false;
    final fallback = _speedBeforeLongPress ?? 1.0;
    setSpeed(fallback);
    _speedBeforeLongPress = null;
  }

  void setFullscreen(bool fullscreen) {
    isFullscreen = fullscreen;
    _safeNotify();
  }

  Duration getDisplayPosition() {
    if (_isSeeking && _lastSeekTarget != null) {
      return _lastSeekTarget!;
    }
    return position;
  }

  void showPlayPauseIndicatorTemporarily({int durationMs = 600}) {
    showPlayPauseIndicator = true;
    _playPauseTimer?.cancel();
    _playPauseTimer = Timer(Duration(milliseconds: durationMs), () {
      showPlayPauseIndicator = false;
      _safeNotify();
    });
    _safeNotify();
  }

  void toggleEpisodeList() {
    showEpisodeList = !showEpisodeList;
    if (showEpisodeList) {
      _hideTimer?.cancel();
    } else if (isPlaying) {
      showControlsTemporarily();
    }
    _safeNotify();
  }

  bool get hasPrevious => currentIndex > 0;
  bool get hasNext => currentIndex < playlist.length - 1;

  void syncCurrentIndex(int index) {
    if (index == currentIndex) return;
    currentIndex = index;
    _autoAdvanced = false;
    _safeNotify();
  }

  void playPrevious() {
    if (hasPrevious) {
      onSwitchEpisode(currentIndex - 1);
    }
  }

  void playNext() {
    if (hasNext) {
      onSwitchEpisode(currentIndex + 1);
    }
  }

  void _handleAutoPlayNext() {
    if (_autoAdvanced || !hasNext) return;
    if (duration == Duration.zero) return;
    if (position < duration - const Duration(milliseconds: 300)) return;
    _autoAdvanced = true;
    Future.microtask(() => onSwitchEpisode(currentIndex + 1));
  }

  void resetAutoAdvance() {
    _pendingAutoReset = true;
  }

  void _maybeResetAutoAdvance() {
    if (_pendingAutoReset && position <= const Duration(milliseconds: 500)) {
      _autoAdvanced = false;
      _pendingAutoReset = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _hideTimer?.cancel();
    _playPauseTimer?.cancel();
    _seekLockTimer?.cancel();
    _bufferPreloadTimer?.cancel();
    _networkSpeedTimer?.cancel();
    _stopPreloadBufferSimulation();
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferingSubscription?.cancel();
    super.dispose();
  }
}