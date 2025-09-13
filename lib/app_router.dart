import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
// import 'pages/detail_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/', // 默认首页
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

  ],
);
