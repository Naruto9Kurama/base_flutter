import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/file/file_item.dart';
import '../../repository/file/file_repository.dart';

class FileProvider extends ChangeNotifier {
  final FileRepository repository=GetIt.instance<FileRepository>();

  FileProvider();

  List<FileItem> files = [];
  final List<FileItem> selectedFiles = [];

  bool get isSelectionMode => selectedFiles.isNotEmpty;
  bool isLoading = false; // 👈 新增加载状态
  Future<void> loadFiles() async {
    try {
      isLoading = true;
      notifyListeners();

      files = await repository.fetchFiles();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void toggleSelection(int index) {
    final file = files[index];
    if (selectedFiles.contains(file)) {
      selectedFiles.remove(file);
    } else {
      selectedFiles.add(file);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedFiles.clear();
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    for (final file in selectedFiles) {
      await repository.deleteFile(file.id);
      files.remove(file);
    }
    clearSelection();
    notifyListeners();
  }

  Future<void> renameFile(FileItem file, String newName) async {
    await repository.renameFile(file.id, newName);
    final index = files.indexOf(file);
    if (index != -1) {
      files[index] = FileItem(
        id: file.id,
        filename: newName,
        isDirectory: file.isDirectory,
        ext: file.ext,
        size: file.size,
        modifiedAt: file.modifiedAt,
        origin: file.origin,
      );
    }
    notifyListeners();
  }

// move / copy 可仿 deleteSelected 实现
}
