// api/file_api.dart
import '../../file/models/file/file_item.dart';

abstract class FileApi {
  /// 列出目录下所有文件
  Future<List<FileItem>> listFiles(Map<String, dynamic> body,String token);

  /// 复制文件
  Future<void> copyFile({required String sourceId, required String targetDirId});

  /// 移动文件
  Future<void> moveFile({required String sourceId, required String targetDirId});

  /// 删除文件
  Future<void> deleteFile(String id);

  /// 重命名文件
  Future<void> renameFile({required String id, required String newName});
}
