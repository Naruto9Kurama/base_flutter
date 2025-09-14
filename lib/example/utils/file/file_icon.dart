import 'package:flutter/material.dart';

extension FileIcon on String {
  IconData get iconData {
    switch (toLowerCase()) {
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
        return Icons.code;
      case 'html':
        return Icons.language;
      case 'css':
        return Icons.style;
      case 'json':
      case 'xml':
        return Icons.data_object;
      case 'md':
      case 'txt':
        return Icons.description;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.article;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }
}
