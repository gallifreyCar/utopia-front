import 'package:dio/dio.dart';

import '../abstract/session.dart';
import '../model/session.dart';

class SessionApiImpl extends SessionApi {
  final Dio dio;
  SessionApiImpl(this.dio);

  @override
  Future<AuthResponse> login({
    required AuthInfo info,
  }) async {
    final resp = await dio.post('/api/v1/user/login', data: {
      'username': info.username,
      'password': info.password,
    });
    return AuthResponse.fromJson(resp.data);
  }

  @override
  Future<AuthResponse> register({required AuthInfo info}) async {
    final resp = await dio.post('/api/v1/user/register', data: {
      'username': info.username,
      'password': info.password,
    });
    return AuthResponse.fromJson(resp.data);
  }
}
