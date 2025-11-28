import 'dart:async'; // 导入异步与定时器支持
import 'package:base_flutter/example/features/base/models/video/play_item.dart'; // 导入播放条目模型
import 'package:flutter/foundation.dart'; // 导入 ChangeNotifier 支持
import 'package:media_kit/media_kit.dart'; // 导入 media_kit 播放器
// -------------------------------------------- // 分隔注释
class VideoControllerState extends ChangeNotifier { // 视频控制器状态，负责 UI 与播放器交互
  final Player player; // 播放器实例
  final List<PlayItem> playlist; // 播放列表
  int currentIndex; // 当前剧集索引
  final Function(int) onSwitchEpisode; // 切换剧集回调

  bool isPlaying = false; // 播放状态
  bool showControls = true; // 控制条可见性
  bool isFullscreen = false; // 全屏状态
  double currentSpeed = 1.0; // 当前倍速
  Duration position = Duration.zero; // 当前进度
  Duration duration = Duration.zero; // 视频总时长
  bool isBuffering = false; // 缓冲状态
  bool showEpisodeList = false; // 选集面板显示状态

  Timer? _hideTimer; // 控制条自动隐藏计时器
  StreamSubscription<bool>? _playingSubscription; // 播放状态订阅
  StreamSubscription<Duration>? _positionSubscription; // 进度订阅
  StreamSubscription<Duration>? _durationSubscription; // 时长订阅
  StreamSubscription<bool>? _bufferingSubscription; // 缓冲订阅
  bool _autoAdvanced = false; // 是否已触发自动连播
  bool _pendingAutoReset = false; // 是否等待重置自动连播

  VideoControllerState({ // 构造函数
    required this.player, // 注入播放器
    required this.playlist, // 注入播放列表
    required this.currentIndex, // 注入初始索引
    required this.onSwitchEpisode, // 注入切集回调
  }) {
    _playingSubscription = player.stream.playing.listen((playing) { // 监听播放状态
      isPlaying = playing; // 更新播放标记
      if (isPlaying && showControls) { // 播放时保持控制条可见
        showControlsTemporarily(); // 重置隐藏计时
      } // 结束 if
      if (!isPlaying) { // 暂停或播放完成
        _hideTimer?.cancel(); // 停止自动隐藏
        _handleAutoPlayNext(); // 尝试自动播下一集
      } // 结束 if
      notifyListeners(); // 通知 UI 刷新
    }); // 结束订阅

    _positionSubscription = player.stream.position.listen((pos) { // 监听进度
      position = pos; // 更新进度
      _maybeResetAutoAdvance(); // 检查是否可以重置自动连播
      _handleAutoPlayNext(); // 检查是否需要自动连播
      notifyListeners(); // 刷新 UI
    }); // 结束订阅

    _durationSubscription = player.stream.duration.listen((dur) { // 监听时长
      duration = dur; // 更新总时长
      notifyListeners(); // 刷新 UI
    }); // 结束订阅

    _bufferingSubscription = player.stream.buffering.listen((buffering) { // 监听缓冲
      isBuffering = buffering; // 更新缓冲状态
      notifyListeners(); // 刷新 UI
    }); // 结束订阅
  } // 构造函数结束

  void togglePlayPause() { // 切换播放/暂停
    player.playOrPause(); // 交给播放器处理
  } // 方法结束

  void setSpeed(double speed) { // 设置倍速
    currentSpeed = speed; // 更新状态
    player.setRate(speed); // 应用到播放器
    notifyListeners(); // 刷新 UI
  } // 方法结束

  void seek(Duration position) { // 跳转进度
    player.seek(position); // 调用播放器
  } // 方法结束

  void showControlsTemporarily() { // 临时显示控制条
    showControls = true; // 设为可见
    notifyListeners(); // 刷新 UI
    _hideTimer?.cancel(); // 取消旧定时器
    _hideTimer = Timer(const Duration(seconds: 4), () { // 启动新的 4 秒计时器
      if (!isPlaying || showEpisodeList) return; // 若暂停或在选集界面则忽略
      showControls = false; // 隐藏控制条
      notifyListeners(); // 刷新 UI
    }); // 定时器结束
  } // 方法结束

  void toggleControls() { // 手动切换控制条
    showControls = !showControls; // 取反可见性
    notifyListeners(); // 刷新 UI
    if (showControls && isPlaying) { // 若刚显示且在播放
      showControlsTemporarily(); // 重置隐藏计时
    } // 结束 if
  } // 方法结束

  void toggleEpisodeList() { // 切换选集面板
    showEpisodeList = !showEpisodeList; // 取反显示状态
    if (showEpisodeList) { // 打开面板
      _hideTimer?.cancel(); // 停止自动隐藏
    } else if (isPlaying) { // 关闭面板且仍在播
      showControlsTemporarily(); // 控制条继续自动隐藏
    } // 结束 if
    notifyListeners(); // 刷新 UI
  } // 方法结束

  bool get hasPrevious => currentIndex > 0; // 是否存在上一集
  bool get hasNext => currentIndex < playlist.length - 1; // 是否存在下一集

  void syncCurrentIndex(int index) { // 同步当前剧集索引
    if (index == currentIndex) return; // 若无变化直接返回
    currentIndex = index; // 更新索引
    _autoAdvanced = false; // 重置自动连播标记
    notifyListeners(); // 刷新 UI
  } // 方法结束

  void playPrevious() { // 播放上一集
    if (hasPrevious) { // 确认存在
      onSwitchEpisode(currentIndex - 1); // 调用回调
    } // 结束 if
  } // 方法结束

  void playNext() { // 播放下一集
    if (hasNext) { // 确认存在
      onSwitchEpisode(currentIndex + 1); // 调用回调
    } // 结束 if
  } // 方法结束

  void _handleAutoPlayNext() { // 自动连播处理
    if (_autoAdvanced || !hasNext) return; // 已触发或无下一集则返回
    if (duration == Duration.zero) return; // 没有有效时长不可判断
    if (position < duration - const Duration(milliseconds: 300)) return; // 未到结尾提前返回
    _autoAdvanced = true; // 标记已自动连播
    Future.microtask(() => onSwitchEpisode(currentIndex + 1)); // 异步切到下一集
  } // 方法结束

  void resetAutoAdvance() { // 请求重置自动连播
    _pendingAutoReset = true; // 标记等待下次进度归零时重置
  } // 方法结束

  void _maybeResetAutoAdvance() { // 检查是否可以真正重置
    if (_pendingAutoReset && position <= const Duration(milliseconds: 500)) { // 当进度接近 0
      _autoAdvanced = false; // 允许下一次自动连播
      _pendingAutoReset = false; // 清除等待标记
    } // 结束 if
  } // 方法结束

  @override
  void dispose() { // 资源释放
    _hideTimer?.cancel(); // 取消计时器
    _playingSubscription?.cancel(); // 取消播放订阅
    _positionSubscription?.cancel(); // 取消进度订阅
    _durationSubscription?.cancel(); // 取消时长订阅
    _bufferingSubscription?.cancel(); // 取消缓冲订阅
    super.dispose(); // 调用父类释放
  } // 方法结束
} // 类结束
// 文件结束 // 终止注释
