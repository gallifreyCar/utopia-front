import 'package:dio/dio.dart';

import '../interface/session.dart';

class SessionApiImpl extends SessionApi {
  final Dio dio;
  SessionApiImpl(this.dio);

  @override
  Future<String> getAuthToken({
    required AuthMode mode,
    required AuthInfo info,
  }) async {
    final resp = await dio.post('/session', data: {
      'mode': mode.name,
      'auth': info.toJson(),
    });
    return resp.data['token'];
  }

  @override
  Future<void> requestAuthCode({
    required AuthMode mode,
    required AuthInfo info,
  }) async {
    final resp = await dio.post(
      '/session/authcode',
      data: {
        'mode': mode.toString(),
        'auth': info.toJson(),
      },
    );
    return resp.data['message'];
  }
}
