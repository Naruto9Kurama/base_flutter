import 'package:base_flutter/example/features/drives/respository/file_repository.dart';
import 'package:base_flutter/example/features/drives/serives/file_service.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class FileProvider extends ChangeNotifier {
  final FileService fileService = GetIt.instance<FileService>();
  final List<FileItem> _pathStack = []; // 保存目录导航历史

  List<FileItem> files = [];
  final List<FileItem> selectedFiles = [];
  bool isLoading = false;
  String get currentPath => _pathStack.isEmpty ? '' : _pathStack.last.filename;

  bool get isSelectionMode => selectedFiles.isNotEmpty;

  /// 加载所有驱动器
  Future<void> loadDrives() async {
    isLoading = true;
    notifyListeners();
    try {
      files = await fileService.driveList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 加载指定目录的文件列表，不指定则加载根目录
  Future<void> loadFiles(FileItem file) async {
    try {
      isLoading = true;
      notifyListeners();

      files = await fileService.listFile(file);
      if (!_pathStack.contains(file)) {
        _pathStack.add(file);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 处理文件点击事件
  Future<void> handleFileTap(FileItem file) async {
    if (isSelectionMode) {
      toggleSelection(files.indexOf(file));
      return;
    }

    if (file.isDirectory) {
      await loadFiles(file); // 如果是文件夹，加载其内容
    } else {
      // TODO: 根据文件类型处理打开逻辑
      if (file.ext?.toLowerCase() == 'pdf') {
        // TODO: 打开PDF查看器
      } else if (file.isImage) {
        // TODO: 打开图片查看器
      } else if (file.isVideo) {
        // TODO: 打开视频播放器
      } else {
        // TODO: 其他类型文件的处理
      }
    }
  }

  /// 返回上级目录
  Future<void> navigateUp() async {
    if (_pathStack.isNotEmpty) {
      _pathStack.removeLast();
      final parentId = _pathStack.isEmpty ? null : _pathStack.last;
      await loadFiles(parentId!);
    }
  }

  Future<void> deleteFile(FileItem fileItem) async {
    try {
      await fileService.deleteFile(fileItem);
      files.remove(fileItem);
      notifyListeners();
    } catch (e) {
      debugPrint('删除文件失败: $e');
    }
  }

  Future<void> renameFile(FileItem fileItem, String newName) async {
    try {
      await fileService.renameFile(fileItem, newName);
      final index = files.indexOf(fileItem);
      if (index != -1) {
        // files[index] = FileItem(
        //   id: fileItem.id,
        //   filename: newName,
        //   isDirectory: fileItem.isDirectory,
        //   mountName: fileItem.mountName,
        //   ext: fileItem.ext,
        //   size: fileItem.size,
        //   modifiedAt: fileItem.modifiedAt,
        // );
        files[index].filename=newName;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('重命名文件失败: $e');
    }
  }

  Future<void> deleteSelected(List<FileItem> filesToDelete) async {
    for (final file in filesToDelete) {
      await deleteFile(file);
    }
    selectedFiles.clear();
    notifyListeners();
  }

  /// 清除选择模式
  void clearSelection() {
    selectedFiles.clear();
    notifyListeners();
  }

  /// 切换文件选择状态
  void toggleSelection(int index) {
    if (index < 0 || index >= files.length) return;
    
    final file = files[index];
    if (selectedFiles.contains(file)) {
      selectedFiles.remove(file);
    } else {
      selectedFiles.add(file);
    }
    notifyListeners();
  }
}