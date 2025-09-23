import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/features/drives/models/token.dart';
import 'package:base_flutter/example/features/drives/respository/file_repository.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:base_flutter/example/features/drives/serives/token_service.dart';
import 'package:get_it/get_it.dart';

import '../../../file/models/file/file_item.dart';
import '../../../file/enums/file_platform.dart';
import '../../api/file_api.dart';
import '../../api/ali/ali_file_api.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class AliFileRepository extends FileRepository {
  AliFileApi api = GetIt.instance<AliFileApi>();
  TokenService tokenService = GetIt.instance<TokenService>();
  DriveService driveService = GetIt.instance<DriveService>();
  static final FilePlatform platform = FilePlatform.aliyun;

  Future<String?> getToken(FileItem file) async {
    return tokenService.getToken(file.mountName);
  }

  Future<List<FileItem>> fetchFiles() async {
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }

  Future<List<FileItem>> listFile(FileItem file) async {
   return getToken(file).then((token) {
      if (token == null) {
        return [];
      }
      return api
          .listFiles({
            "parent_file_id": file.id.isEmpty ? "root" : file.id,
            "drive_id": "788219542",
          }, token)
          .then(
            (res) => FileItem.toFileItemList(res.items, file.mountName ?? ""),
          );
    });
  }

  Future<void> deleteFile(FileItem file) async {}

  Future<void> renameFile(FileItem file, String newName) async {}

  Future<void> moveFile(FileItem file, String targetPath) async {}

  Future<void> copyFile(FileItem file, String targetPath) async {}

  @override
  Future<List<FileItem>> rootFiles(String name) async {
    // DriveConfig? drive = await driveService.getDrive(name);
    return listFile(
      FileItem(id: "1", filename: "test", isDirectory: true, mountName: name),
    );
  }
}
