import 'package:base_flutter/example/features/drives/models/token.dart';
import 'package:base_flutter/example/features/drives/respository/file_repository.dart';
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

  Future<List<FileItem>> fetchFiles() async {
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }

  Future<List<FileItem>> listFile(FileItem file) async {
    String? token = await tokenService.getToken(file.ssMountName);
    // 判断 token 是否为 null 或者 token.getBearerToken 是否为 null
    if (token == null) {
      // 如果 token 或 token.getBearerToken 为 null，返回一个空列表
      return [];
    }
    return api
        .listFiles({"parent_file_id": "root", "drive_id": "788219542"}, token)
        .then((res) => FileItem.toFileItemList(res.items,res.ssMountName??""));
  }

  Future<void> deleteFile(FileItem file) async {}

  Future<void> renameFile(FileItem file, String newName) async {}

  Future<void> moveFile(FileItem file, String targetPath) async {}

  Future<void> copyFile(FileItem file, String targetPath) async {}

  @override
  Future<List<FileItem>> rootFiles() async {
    return listFile(FileItem(id: "1", filename: "test", isDirectory: true, ssMountName: "/test"));
  }
}
