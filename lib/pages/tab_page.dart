import 'package:base_flutter/example/pages/login/login_page.dart';
import 'package:base_flutter/example/pages/video/search/video_search.dart';
import 'package:base_flutter/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../core/providers/theme_provider.dart';
import '../example/pages/file/file_list_page.dart';
import 'package:base_flutter/example/pages/drive/drive_main_page.dart';
import 'package:get_it/get_it.dart';
class TabItem {
  final Widget page;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  final Color lightSelectedColor;
  final Color darkSelectedColor;
  final Color lightUnselectedColor;
  final Color darkUnselectedColor;

  const TabItem({
    required this.page,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.lightSelectedColor,
    required this.darkSelectedColor,
    required this.lightUnselectedColor,
    required this.darkUnselectedColor,
  });
}

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 2;

  late final List<TabItem> _tabs = [
    const TabItem(
      page: HomePage(),
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'tab.home',
      lightSelectedColor: Colors.blue,
      darkSelectedColor: Colors.tealAccent,
      lightUnselectedColor: Colors.grey,
      darkUnselectedColor: Colors.white70,
    ),
    const TabItem(
      page: LoginPage(),
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'tab.profile',
      lightSelectedColor: Colors.green,
      darkSelectedColor: Colors.orangeAccent,
      lightUnselectedColor: Colors.grey,
      darkUnselectedColor: Colors.white70,
    ),
    // 新增 FileListPage
    TabItem(
      page: FileListPage(),
      icon: Icons.folder_open_outlined,
      activeIcon: Icons.folder_open,
      label: 'tab.file_list',
      lightSelectedColor: Colors.purple,
      darkSelectedColor: Colors.purpleAccent,
      lightUnselectedColor: Colors.grey,
      darkUnselectedColor: Colors.white70,
    ),
    TabItem(
      page: DriveMainScreen(),
      icon: Icons.folder_open_outlined,
      activeIcon: Icons.folder_open,
      label: 'tab.drive',
      lightSelectedColor: Colors.purple,
      darkSelectedColor: Colors.purpleAccent,
      lightUnselectedColor: Colors.grey,
      darkUnselectedColor: Colors.white70,
    ),
    TabItem(
      page:  VideoSearchPage(),
      icon: Icons.folder_open_outlined,
      activeIcon: Icons.folder_open,
      label: 'tab.video_search',
      lightSelectedColor: Colors.purple,
      darkSelectedColor: Colors.purpleAccent,
      lightUnselectedColor: Colors.grey,
      darkUnselectedColor: Colors.white70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor:
        isDark ? _tabs[_currentIndex].darkSelectedColor : _tabs[_currentIndex].lightSelectedColor,
        unselectedItemColor:
        isDark ? _tabs[_currentIndex].darkUnselectedColor : _tabs[_currentIndex].lightUnselectedColor,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
            icon: Icon(tab.icon),
            activeIcon: Icon(tab.activeIcon),
            label: tab.label.tr(),
          ),
        )
            .toList(),
      ),
    );
  }

}
