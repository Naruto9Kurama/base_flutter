// example/pages/file/file_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/file/providers/file_provider.dart';
import '../../../core/di/injection.dart';
import 'file_list_item.dart';
import 'file_list_bottom_bar.dart';
import '../../features/file/models/file/file_item.dart';

class FileListPage extends StatefulWidget {
  const FileListPage({super.key});

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  late final FileProvider _fileProvider;
  late FileItem fileItem;
  final List<FileItem> pathStack = [];

  @override
  void initState() {
    super.initState();
    _fileProvider = getIt<FileProvider>();
    fileItem = FileItem(
      id: 'root',
      filename: '根目录',
      isDirectory: true,
      mountId: '',
    );
    pathStack.clear();
    pathStack.add(fileItem);
    _fileProvider.loadDrives();
  }

  void _handleFileTap(FileItem tapped) async {
    if (tapped.isDirectory) {
      setState(() {
        fileItem = tapped;
        pathStack.add(tapped);
      });
      if (tapped.id == 'root') {
        await _fileProvider.loadDrives();
      } else {
        await _fileProvider.loadFiles(tapped);
      }
    } else {
      _fileProvider.handleFileTap(tapped,context);
    }
  }

  void _handleBack() async {
    if (pathStack.length > 1) {
      setState(() {
        pathStack.removeLast();
        fileItem = pathStack.last;
      });
      if (fileItem.id == 'root') {
        await _fileProvider.loadDrives();
      } else {
        await _fileProvider.loadFiles(fileItem);
      }
    }
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
                : pathStack.length > 1
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _handleBack,
                      )
                    : null,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    if (fileItem.id == 'root') {
                      await _fileProvider.loadDrives();
                    } else {
                      await _fileProvider.loadFiles(fileItem);
                    }
                  },
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
                              onTap: () => _handleFileTap(file),
                              onLongPress: () =>
                                  provider.toggleSelection(index),
                            );
                          },
                        ),
                ),
          bottomNavigationBar: FileListBottomBar(
            hasSelection: provider.isSelectionMode,
            onDelete: provider.isSelectionMode
                ? () => provider.deleteSelected(provider.selectedFiles)
                : null,
          ),
        ),
      ),
    );
  }
}
