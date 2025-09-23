import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:base_flutter/example/features/drives/respository/ali/ali_file_repository.dart';
import 'package:base_flutter/example/features/drives/respository/file_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class FileService {
  Future<FileRepository> getFileRepositoryByFileItem(FileItem file) async {
    return await getFileRepositoryByName(file.mountName);
  }

  Future<FileRepository> getFileRepositoryByName(String mountName) async {
    DriveService service = GetIt.instance<DriveService>();
    final config = await service.getDrive(mountName);
    if (config == null) {
      throw Exception('未找到名为 $mountName 的驱动配置');
    }
    return getFileRepositoryByFilePlatform(config.driveType);
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
  Future<List<FileItem>> listFile(FileItem file) async {
    if (file.isDirectory) {
      //获取当前目录下的文件
      FileRepository repository = await getFileRepositoryByFileItem(file);
      return await repository.listFile(file); // 返回实际结果
    }
    return [];
  }

  Future<List<FileItem>> rootList(String name) async {
    //获取当前目录下的文件
    try {
      FileRepository repository = await getFileRepositoryByName(name);
      return repository.rootFiles(name);
    } catch (e) {
      
    }
    return [];
  }

  Future<List<FileItem>> driveList() {
    final service = GetIt.instance<DriveService>();

    return service.getAllDrive().then((drives) {
      return drives.map((drive) {
        return FileItem(
          id: "",
          filename: drive.name,
          isDirectory: true,
          mountName: drive.name
        );
      }).toList();
    });
  }

  Future<void> deleteFile(FileItem file) async {
    FileRepository repository = await getFileRepositoryByFileItem(file);
    await repository.deleteFile(file);
  }

  Future<void> renameFile(FileItem file, String newName) async {
    FileRepository repository = await getFileRepositoryByFileItem(file);
    await repository.renameFile(file, newName);
  }
}
