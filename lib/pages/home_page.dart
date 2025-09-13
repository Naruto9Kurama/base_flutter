import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/providers/theme_provider.dart';
import 'package:get_it/get_it.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeProvider = context.watch<ThemeProvider>();
    final themeProvider = GetIt.instance<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('hello'.tr())), // 多语言
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'hello'.tr(), // 显示翻译
            style: Theme.of(context).textTheme.headlineMedium, // 使用主题
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {themeProvider.toggleTheme();},
            child: Text('toggle_theme'.tr()),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('zh'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            child: Text('toggle_language'.tr()),
          ),
        ],
      ),
    );
  }
}
