import 'package:base_flutter/example/pages/drive/drive_main_page.dart';
import 'package:base_flutter/example/pages/login/login_page.dart';
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
  ],
);
