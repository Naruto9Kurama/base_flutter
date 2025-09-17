// auth_api_injectable.dart
import 'package:base_flutter/core/api/dio_client.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:base_flutter/example/features/base/models/http/base_response.dart';
import 'auth_api.dart';

import '../../../example/features/base/models/http/auth/login_request.dart';
import '../../../example/features/base/models/http/auth/login_response.dart';

@LazySingleton(as: AuthApi)
class AuthApiInjectable implements AuthApi {
  final AuthApi _api;

  AuthApiInjectable(DioClient client) : _api = AuthApi(client.dio);

  @override
  Future<BaseResponse<LoginResponse>> login(request) => _api.login(request);
}
