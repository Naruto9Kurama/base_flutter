import 'package:base_flutter/core/di/injection.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:base_flutter/example/features/file/providers/file_item/file_item_provider.dart';
import 'package:base_flutter/example/pages/drive/drive_main_page.dart';
import 'package:base_flutter/example/pages/file/video/video_player_screen.dart';
import 'package:base_flutter/example/pages/login/login_page.dart';
import 'package:base_flutter/example/pages/video/video_search.dart';
import 'package:base_flutter/pages/tab_page.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
// import 'pages/detail_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/tab-page', // 默认首页
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/tab-page',
      builder: (context, state) => const TabPage(),
    ),
    GoRoute(
      path: '/drive',
      builder: (context, state) => const DriveMainScreen(),
    ),
    GoRoute(
      path: '/video-player',
      builder: (context, state) {
        final FileItem fileItem = state.extra as FileItem; // 获取传递的 videoUrl
        FileItemProvider _fileItemProvider = getIt<FileItemProvider>();
        _fileItemProvider.setFileItem( fileItem);
        return VideoPlayerScreen(fileItemProvider:_fileItemProvider);
      },
    ),
    GoRoute(
      path: '/video-search',
       builder: (context, state) => const VideoSearchPage(),
    ),
  ],
);
