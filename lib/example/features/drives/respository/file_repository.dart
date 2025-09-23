import 'package:base_flutter/example/features/drives/respository/ali/ali_file_repository.dart';
import 'package:get_it/get_it.dart';

import '../../file/models/file/file_item.dart';
import '../../file/enums/file_platform.dart';
import 'package:injectable/injectable.dart';

// @LazySingleton()
abstract class FileRepository {

  Future<List<FileItem>> fetchFiles();


  Future<List<FileItem>> listFile(FileItem file)  ;
  Future<List<FileItem>> rootFiles(String name)  ;

  Future<void> deleteFile(FileItem file) ;

  Future<void> renameFile(FileItem file, String newName) ;

  Future<void> moveFile(FileItem file, String targetPath) ;

  Future<void> copyFile(FileItem file, String targetPath) ;
}
