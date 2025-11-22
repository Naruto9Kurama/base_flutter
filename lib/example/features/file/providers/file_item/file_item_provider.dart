import 'package:base_flutter/example/features/drives/serives/file_service.dart';
import 'package:base_flutter/example/features/file/models/file/file_item.dart';
import 'package:base_flutter/example/features/file/models/file/video_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dart:convert';
@LazySingleton()
class FileItemProvider extends ChangeNotifier {
  late FileItem fileItem ;
  
  final fileService=GetIt.I<FileService>();
  Future<void> setFileItem( FileItem fileItem) async {
    this.fileItem=fileItem;
    if(fileItem.isVideo){
      this.fileItem=await fileService.playUrl(fileItem);
      
      print(jsonEncode(this.fileItem as VideoFile));
    }
    notifyListeners();
  }
}