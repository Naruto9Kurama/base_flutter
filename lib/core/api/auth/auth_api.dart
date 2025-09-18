import 'package:base_flutter/core/api/dio_client.dart';
import 'package:base_flutter/core/config/app_config.dart';
import 'package:base_flutter/example/features/base/models/http/base_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../../example/features/base/models/http/auth/login_request.dart';
import '../../../example/features/base/models/http/auth/login_response.dart';


part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {

  factory AuthApi(DioClient client,AppConfig config) => _AuthApi(client.dio,baseUrl:config['baseUrl']);

  @POST("/api/auth/token/getToken")
  Future<BaseResponse<LoginResponse>> login(@Body() LoginRequest request);
}
