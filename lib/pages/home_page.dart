import 'package:base_flutter/example/models/file/file_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/providers/theme_provider.dart';
import 'package:get_it/get_it.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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

  List<FileItem> _sampleFiles() => [
    FileItem(
        id: '1',
        filename: 'main',
        ext: 'dart',
        isDirectory: false,
        size: 1024,
        modifiedAt: DateTime.now()),
    FileItem(
        id: '2', filename: 'index', ext: 'html', isDirectory: false, size: 2048),
    FileItem(
        id: '3', filename: 'document', ext: 'pdf', isDirectory: false, modifiedAt: DateTime.now()),
  ];
}


