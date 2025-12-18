import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/example/features/base/models/video/video_model.dart';
import 'package:base_flutter/example/pages/drive/drive_main_page.dart';
import 'package:base_flutter/example/pages/video/home/video_home_page.dart';
import 'package:base_flutter/example/pages/video/player/video_player_screen.dart';
import 'package:base_flutter/example/pages/login/login_page.dart';
import 'package:base_flutter/example/pages/video/search/video_search.dart';
import 'package:base_flutter/pages/tab_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
// import 'pages/detail_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/tab-page', // 默认首页
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          GetIt.instance.get<HomePage>(param1: state.pageKey),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) =>
          GetIt.instance.get<LoginPage>(param1: state.pageKey),
    ),
    GoRoute(
      path: '/tab-page',
      builder: (context, state) =>
          GetIt.instance.get<TabPage>(param1: state.pageKey),
    ),
    GoRoute(
      path: '/drive',
      builder: (context, state) =>
          GetIt.instance.get<DriveMainScreen>(param1: state.pageKey),
    ),
    GoRoute(
      path: '/video-player',
      builder: (context, state) {
        final VideoModel videoModel =
            state.extra as VideoModel; // 获取传递的 videoUrl
        return getIt<VideoPlayerScreen>(
          param1: state.pageKey,
          param2: videoModel,
        );
      },
    ),
    GoRoute(
      path: '/video-search',
      builder: (context, state) =>
          GetIt.instance.get<VideoSearchPage>(param1: state.pageKey),
    ),
    GoRoute(
      path: '/video-home',
      builder: (context, state) =>
          GetIt.instance.get<VideoHomePage>(param1: state.pageKey),
    ),
  ],
);
