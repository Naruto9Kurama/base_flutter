import 'package:base_flutter/example/models/http/base_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../../example/models/http/auth/login_request.dart';
import '../../../example/models/http/auth/login_response.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "https://lovon.dpdns.org")
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST("/api/auth/token/getToken")
  Future<BaseResponse<LoginResponse>> login(@Body() LoginRequest request);
}
