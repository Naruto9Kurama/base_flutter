import 'package:base_flutter/example/features/drives/respository/ali/ali_file_repository.dart';
import 'package:get_it/get_it.dart';

import '../../file/models/file/file_item.dart';
import '../../file/enums/file_platform.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class FileRepository {

  Future<List<FileItem>> fetchFiles() async {
    // await Future.delayed(const Duration(seconds: 2));
    // return [
    //   FileItem(id:'1', filename: 'main', ext: 'dart', isDirectory:false, size: 1024, origin: FilePlatform.aliyun),
    //   FileItem(id:'2', filename: 'index', ext: 'html', isDirectory:false, size: 2048, origin: FilePlatform.aliyun),
    //   FileItem(id:'3', filename: 'document', ext: 'pdf', isDirectory:false, origin: FilePlatform.aliyun),
    // ];
    
    return[];
  }


  Future<List<FileItem>> listFile(FileItem file) async {
    
    return [];
  }

  Future<void> deleteFile(FileItem file) async {
    // final api = _getApi(file.origin);
    // await api.deleteFile(file.id);
  }

  Future<void> renameFile(FileItem file, String newName) async {
    // final api = _getApi(file.origin);
    // await api.renameFile(id: file.id, newName: newName);
  }

  Future<void> moveFile(FileItem file, String targetPath) async {
    // final api = _getApi(file.origin);
    // await api.moveFile(sourceId: file.id, targetDirId: targetPath);
  }

  Future<void> copyFile(FileItem file, String targetPath) async {
    // final api = _getApi(file.origin);
    // await api.copyFile(sourceId: file.id, targetDirId: targetPath);
  }
}
