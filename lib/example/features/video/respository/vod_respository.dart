

// @LazySingleton()
import 'package:base_flutter/example/features/base/models/video/video_model.dart';

abstract class VodRespository {


  Future<List<VideoModel>> searchVideo(String ac,String wd,int pg,int limit);
}
