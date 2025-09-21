import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:base_flutter/example/features/drives/respository/ali/ali_file_repository.dart';
import 'package:base_flutter/example/features/drives/respository/file_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class FileService {
  FileRepository getFileRepositoryByFileItem(FileItem file) {
    return getFileRepositoryByFilePlatform(file.origin);
  }

  FileRepository getFileRepositoryByFilePlatform(FilePlatform platform) {
    switch (platform) {
      case FilePlatform.aliyun:
        return GetIt.instance<AliFileRepository>();
      case FilePlatform.local:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.baidu:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.ftp:
        // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.other:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// 获取当前文件夹下的所有文件
  /// file必须是文件夹
  List<FileItem> listFile(FileItem file) {
    if (file.isDirectory) {
      //获取当前目录下的文件
      FileRepository repository = getFileRepositoryByFileItem(file);
      repository.listFile(file);
    }

    return [];
  }

  Future<List<FileItem>> rootList() async{
    //获取当前目录下的文件
    for (var filePlatform in FilePlatform.values) {
      try{
        FileRepository repository = getFileRepositoryByFilePlatform(
          filePlatform,
        );
        return repository.rootFiles();
      }catch(e){

      }

    }

    return [];
  }
}
