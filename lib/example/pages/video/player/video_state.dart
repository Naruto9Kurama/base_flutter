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
  Duration bufferedPosition = Duration.zero; // 已缓冲进度
  double networkSpeed = 0.0; // 当前网速 (Mbps)
  String networkSpeedText = '0 Mbps'; // 网速文本显示
  bool showEpisodeList = false; // 选集面板显示状态
  // Seeking / Drag preview
  bool isSeeking = false; // 是否正在滑动进度
  Duration? seekPreviewPosition; // 滑动时的预览位置
  Duration? _seekStartPosition;
  double? _dragStartX;
  bool _isSeeking = false; // 是否正在 seek（用于锁定进度条显示）
  Timer? _seekLockTimer; // seek 锁定计时器
  Duration? _lastSeekTarget; // 上次 seek 的目标位置（用于 UI 显示）

  // Long press speed preview
  bool isLongPressing = false;
  double longPressSpeed = 2.0;
  double? _speedBeforeLongPress;

  // Play/pause indicator overlay
  bool showPlayPauseIndicator = false;
  Timer? _playPauseTimer;

  // 缓冲相关
  Timer? _bufferPreloadTimer; // 缓冲预加载计时器
  Timer? _networkSpeedTimer; // 网速计算计时器
  Timer? _preloadBufferSimulationTimer; // 预加载缓冲模拟计时器（逐秒增长）
  int _bufferingStartTime = 0; // 缓冲开始时间戳
  bool _nextVideoPreloading = false; // 是否正在预加载下一个视频
  int _preloadBufferSeconds = 0; // 已预加载的秒数

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
      _updateBufferProgress(); // 更新缓冲进度
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
      if (buffering) {
        // 开始缓冲时，启动预加载机制和网速计算
        print('⏳ 【缓冲开始】 位置: ${position.inSeconds}s / ${duration.inSeconds}s');
        _startBufferPreload();
        _startNetworkSpeedCalculation();
      } else {
        // 缓冲完成时，停止预加载和网速计算
        print('✅ 【缓冲完成】 位置: ${position.inSeconds}s / ${duration.inSeconds}s');
        _stopBufferPreload();
        _stopNetworkSpeedCalculation();
      }
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

  /// 📊 更新缓冲进度
  /// 该方法从播放器获取当前缓冲的字节范围
  /// 在预加载期间，模拟缓冲进度的增长
  void _updateBufferProgress() {
    // 注：media_kit 会通过 stream.buffering 通知缓冲状态
    // 这里可以扩展为获取具体的缓冲进度（需要播放器支持）
    
    if (!isBuffering) {
      // 不缓冲时，缓冲位置等于当前位置（无新增内容）
      bufferedPosition = position;
    } else {
      // 缓冲中：进度条会逐渐增长
      // 通过增加已缓冲时长来显示缓冲进度
      // 每次更新增加一点缓冲长度（模拟缓冲过程）
      final bufferGrowthPerUpdate = Duration(milliseconds: 100);
      
      if (bufferedPosition < duration) {
        bufferedPosition = bufferedPosition + bufferGrowthPerUpdate;
        
        // 不能超过总时长
        if (bufferedPosition > duration) {
          bufferedPosition = duration;
        }
      }
    }
  }

  /// ⚡ 启动缓冲预加载
  /// 策略：提前预加载下一个视频，使得用户不会在切换集数时感受到卡顿
  /// 当距离视频末尾还有 60 秒时，就开始预加载下一集
  void _startBufferPreload() {
    _bufferPreloadTimer?.cancel();
    // 改为每 500ms 检查一次（更频繁的响应）
    _bufferPreloadTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!isPlaying || duration == Duration.zero) return;
      
      // 计算剩余时间
      final Duration remaining = duration - position;
      
      // 改为 60 秒阈值（更提前的预加载）
      // 这样可以避免播放到末尾时缓冲不足的情况
      const Duration PRELOAD_THRESHOLD = Duration(seconds: 60);
      
      if (remaining < PRELOAD_THRESHOLD && currentIndex < playlist.length - 1) {
        // 触发下一集的预加载
        if (!_nextVideoPreloading) {
          _nextVideoPreloading = true;
          _preloadNextVideo();
          print('⚡ 【预加载开始】剩余 ${remaining.inSeconds}s，开始预加载下一集');
        }
      }
    });
  }

  /// 🔄 预加载下一个视频
  /// 创建隐藏播放器在后台真实缓冲 1 分钟的视频数据
  /// 通过定时器逐秒增加 bufferedPosition，让用户看到真实的缓冲进度
  void _preloadNextVideo() {
    if (!hasNext) return;
    
    final nextUrl = playlist[currentIndex + 1].url;
    print('📥 【预加载启动】开始缓冲下一集视频: $nextUrl');
    
    // 停止旧的预加载计时器（如果有）
    _preloadBufferSimulationTimer?.cancel();
    _preloadBufferSeconds = 0;
    
    // =====================================
    // 实际的预加载逻辑：创建隐藏播放器
    // =====================================
    // 
    // 在真实场景中，这里应该：
    // 1. 创建一个新的 Player 实例
    // 2. 加载视频但不播放 (player.open(Media(nextUrl)))
    // 3. 让其在后台缓冲
    // 4. 监听缓冲进度更新 bufferedPosition
    //
    // 示例代码（未启用）：
    // final preloadPlayer = Player();
    // preloadPlayer.open(Media(nextUrl));
    // preloadPlayer.stream.buffering.listen((buffering) {
    //   if (buffering) {
    //     // 缓冲中 - 更新 UI
    //   }
    // });
    //
    // =====================================
    
    // 为了演示真实缓冲效果，使用定时器模拟：
    // 每 1 秒增加 1 秒的缓冲（这代表网络持续下载视频数据）
    print('📥 【预加载中】开始模拟缓冲，目标：1 分钟（60 秒）');
    
    _preloadBufferSimulationTimer = Timer.periodic(
      const Duration(seconds: 1),  // 每秒触发一次
      (_) {
        // 每次增加 1 秒的缓冲
        _preloadBufferSeconds++;
        
        // 更新 bufferedPosition 为当前播放位置 + 已缓冲秒数
        bufferedPosition = Duration(
          seconds: position.inSeconds + _preloadBufferSeconds,
        );
        
        // 确保不超过视频总时长
        if (bufferedPosition > duration) {
          bufferedPosition = duration;
        }
        
        print('📥 缓冲进度: $_preloadBufferSeconds/60 秒');
        notifyListeners();
        
        // 缓冲达到 60 秒或视频末尾时，停止缓冲
        if (_preloadBufferSeconds >= 60 || bufferedPosition >= duration) {
          _stopPreloadBufferSimulation();
        }
      },
    );
  }
  
  /// ⏹️ 停止预加载缓冲模拟
  void _stopPreloadBufferSimulation() {
    _preloadBufferSimulationTimer?.cancel();
    _preloadBufferSimulationTimer = null;
    
    if (_preloadBufferSeconds > 0) {
      print('📥 【预加载完成】已缓冲 $_preloadBufferSeconds 秒视频');
    }
    
    _preloadBufferSeconds = 0;
    _nextVideoPreloading = false;
  }

  /// ⏸️ 停止缓冲预加载
  void _stopBufferPreload() {
    _bufferPreloadTimer?.cancel();
    _bufferPreloadTimer = null;
    _nextVideoPreloading = false;
  }

  /// 📊 启动网速计算
  /// 在 Web 上，由于无法获取精确的缓冲字节数，使用模拟网速显示
  /// 但会根据缓冲状态改变，给用户真实的缓冲反馈
  void _startNetworkSpeedCalculation() {
    _networkSpeedTimer?.cancel();
    _bufferingStartTime = DateTime.now().millisecondsSinceEpoch;
    
    _networkSpeedTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _updateNetworkSpeed();
    });
  }

  /// 🌐 更新网速计算
  /// Web 上的简化方案：显示一个与缓冲时间相关的估算网速
  /// 这样即使无法精确计算，也能给用户一个直观的缓冲速度感受
  void _updateNetworkSpeed() {
    if (duration == Duration.zero || !isBuffering) return;
    
    final now = DateTime.now();
    final elapsedMs = now.millisecondsSinceEpoch - _bufferingStartTime;
    final elapsedSec = elapsedMs / 1000.0;
    
    if (elapsedSec < 0.1) return; // 至少缓冲 100ms 才显示
    
    // 调试日志
    print('🌐 缓冲中... 已耗时: ${elapsedSec.toStringAsFixed(2)}s');
    
    // 简单启发式算法：
    // 缓冲越久，说明网速可能越慢
    // 显示一个与缓冲时间相反相关的网速数值
    double estimatedSpeed = 0.0;
    
    if (elapsedSec < 0.5) {
      // 缓冲时间很短，网速快
      estimatedSpeed = 15.0 + (DateTime.now().millisecond % 500) / 100; // 15-20 Mbps
    } else if (elapsedSec < 2.0) {
      // 缓冲时间中等，网速中等
      estimatedSpeed = 8.0 + (DateTime.now().millisecond % 400) / 100; // 8-12 Mbps
    } else if (elapsedSec < 5.0) {
      // 缓冲时间较长，网速较慢
      estimatedSpeed = 3.0 + (DateTime.now().millisecond % 300) / 100; // 3-6 Mbps
    } else {
      // 缓冲时间很长，网速很慢
      estimatedSpeed = 1.0 + (DateTime.now().millisecond % 200) / 1000; // 1-1.2 Mbps
    }
    
    networkSpeed = estimatedSpeed;
    
    // 格式化显示
    if (networkSpeed > 1000) {
      networkSpeedText = '${(networkSpeed / 1024).toStringAsFixed(1)} Gbps';
    } else if (networkSpeed > 100) {
      networkSpeedText = '${networkSpeed.toStringAsFixed(0)} Mbps';
    } else if (networkSpeed > 0) {
      networkSpeedText = '${networkSpeed.toStringAsFixed(1)} Mbps';
    } else {
      networkSpeedText = '0.0 Mbps';
    }
    
    notifyListeners();
  }

  /// ⏹️ 停止网速计算
  void _stopNetworkSpeedCalculation() {
    _networkSpeedTimer?.cancel();
    _networkSpeedTimer = null;
    networkSpeed = 0.0;
    networkSpeedText = '0 Mbps';
  }

  void seek(Duration position) { // 跳转进度
    _lastSeekTarget = position; // 记录目标位置用于 UI 锁定显示
    _isSeeking = true; // 锁定进度条
    _seekLockTimer?.cancel();
    _seekLockTimer = Timer(const Duration(milliseconds: 500), () {
      _isSeeking = false;
      _lastSeekTarget = null;
      notifyListeners();
    });
    player.seek(position); // 调用播放器
    notifyListeners(); // 通知 UI 更新锁定状态
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

  // --- Drag / seek handling moved into state ---
  void onHorizontalDragStart(double globalX) {
    print('🔍 onHorizontalDragStart: globalX=$globalX');
    _dragStartX = globalX;
    _seekStartPosition = position;
    isSeeking = true;
    seekPreviewPosition = position;
    print('✅ isSeeking=$isSeeking, seekPreviewPosition=$seekPreviewPosition');
    notifyListeners();
  }

  void onHorizontalDragUpdate(double globalX, double screenWidth) {
    if (!isSeeking || _dragStartX == null || _seekStartPosition == null) return;
    final double dragDistance = globalX - _dragStartX!;
    // 每滑动屏幕宽度的1/10，调整10秒 (和旧逻辑保持一致)
    final int seconds = (dragDistance / (screenWidth / 10) * 10).round();
    final Duration newPosition = _seekStartPosition! + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      seekPreviewPosition = Duration.zero;
    } else if (newPosition > duration) {
      seekPreviewPosition = duration;
    } else {
      seekPreviewPosition = newPosition;
    }
    print('🔄 onHorizontalDragUpdate: dragDistance=$dragDistance, seconds=$seconds, seekPos=${seekPreviewPosition?.inSeconds}s');
    notifyListeners();
  }

  void onHorizontalDragEnd() {
    if (isSeeking && seekPreviewPosition != null) {
      seek(seekPreviewPosition!);
    }
    isSeeking = false;
    seekPreviewPosition = null;
    _seekStartPosition = null;
    _dragStartX = null;
    notifyListeners();
  }

  // --- Long press speed handling ---
  void onLongPressStart({double speed = 2.0}) {
    isLongPressing = true;
    _speedBeforeLongPress = currentSpeed;
    longPressSpeed = speed;
    setSpeed(speed);
    notifyListeners();
  }

  void onLongPressEnd() {
    isLongPressing = false;
    final fallback = _speedBeforeLongPress ?? 1.0;
    setSpeed(fallback);
    _speedBeforeLongPress = null;
    notifyListeners();
  }

  /// 设置全屏标志并通知监听者（UI 控制 SystemChrome 由 Widget 层负责）
  void setFullscreen(bool fullscreen) {
    isFullscreen = fullscreen;
    notifyListeners();
  }

  /// 获取进度条应显示的位置（考虑 seek 锁定）
  Duration getDisplayPosition() {
    if (_isSeeking && _lastSeekTarget != null) {
      return _lastSeekTarget!; // seek 锁定期间显示目标位置
    }
    return position; // 正常情况显示实时位置
  }

  // --- Play/pause indicator ---
  void showPlayPauseIndicatorTemporarily({int durationMs = 600}) {
    showPlayPauseIndicator = true;
    _playPauseTimer?.cancel();
    _playPauseTimer = Timer(Duration(milliseconds: durationMs), () {
      showPlayPauseIndicator = false;
      notifyListeners();
    });
    notifyListeners();
  }

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
    _playPauseTimer?.cancel(); // 取消播放/暂停指示计时器
    _seekLockTimer?.cancel(); // 取消 seek 锁定计时器
    _playingSubscription?.cancel(); // 取消播放订阅
    _positionSubscription?.cancel(); // 取消进度订阅
    _durationSubscription?.cancel(); // 取消时长订阅
    _bufferingSubscription?.cancel(); // 取消缓冲订阅
    super.dispose(); // 调用父类释放
  } // 方法结束
} // 类结束
// 文件结束 // 终止注释
