// example/pages/file/file_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/file/providers/file_provider.dart';
import '../../../core/di/injection.dart';
import 'file_list_item.dart';
import 'file_list_bottom_bar.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  late final FileProvider _fileProvider;

  @override
  void initState() {
    super.initState();
    _fileProvider = getIt<FileProvider>();
    _fileProvider.loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FileProvider>.value(
      value: _fileProvider,
      child: Consumer<FileProvider>(
        builder: (context, provider, child) => Scaffold(
          appBar: AppBar(
            title: Text(provider.isSelectionMode
                ? '已选择 ${provider.selectedFiles.length} 个项目'
                : '文件管理器'),
            leading: provider.isSelectionMode
                ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: provider.clearSelection,
            )
                : null,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator()) // 👈 加载时显示旋转条
              : RefreshIndicator(
            onRefresh: () async => await provider.loadFiles(),
            child: provider.files.isEmpty
                ? const Center(child: Text('暂无文件'))
                : ListView.separated(
              itemCount: provider.files.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final file = provider.files[index];
                final isSelected =
                provider.selectedFiles.contains(file);
                return FileListItem(
                  file: file,
                  isSelected: isSelected,
                  isSelectionMode: provider.isSelectionMode,
                  onTap: () => provider.toggleSelection(index),
                  onLongPress: () =>
                      provider.toggleSelection(index),
                );
              },
            ),
          ),
          bottomNavigationBar: FileListBottomBar(
            hasSelection: provider.isSelectionMode,
            onDelete:
            provider.isSelectionMode ? provider.deleteSelected : null,
          ),
        ),
      ),
    );
  }
}
