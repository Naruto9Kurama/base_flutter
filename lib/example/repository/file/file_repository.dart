import '../../models/file/file_item.dart';

class FileRepository {
  // 模拟异步加载文件
  Future<List<FileItem>> fetchFiles() async {
    await Future.delayed(const Duration(seconds: 2)); // 模拟网络/本地延迟
    return [
      FileItem(id:'1', filename: 'main', ext: 'dart', isDirectory:false, size: 1024),
      FileItem(id:'2', filename: 'index', ext: 'html', isDirectory:false, size: 2048),
      FileItem(id:'3', filename: 'document', ext: 'pdf', isDirectory:false),
    ];
  }

  Future<void> deleteFile(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: 删除逻辑
  }

  Future<void> renameFile(String id, String newName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: 重命名逻辑
  }

  Future<void> moveFile(String id, String targetPath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: 移动逻辑
  }

  Future<void> copyFile(String id, String targetPath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: 复制逻辑
  }
}
