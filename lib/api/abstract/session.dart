import '../model/session.dart';

abstract class SessionApi {
  /// 鉴权成功，返回jwt token
  Future<AuthResponse> login({
    required AuthInfo info,
  });

  /// 鉴权成功，返回jwt token
  Future<AuthResponse> register({
    required AuthInfo info,
  });
}
