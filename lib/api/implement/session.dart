import 'package:dio/dio.dart';

import '../abstract/session.dart';

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
}
