import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

// @LazySingleton()
// class DioClient {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 5),
//     ),
//   );

//   static Dio get dio => _dio;
// }

@LazySingleton()
class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
}


// @LazySingleton()
// Dio dio() => Dio(
//   BaseOptions(
//     connectTimeout: const Duration(seconds: 5),
//     receiveTimeout: const Duration(seconds: 5),
//   ),
// );
