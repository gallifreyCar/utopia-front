class AuthInfo {
  final String? email;
  final String? sms;
  final String? code;

  const AuthInfo({
    this.email,
    this.sms,
    this.code,
  });

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      email: json['email'],
      sms: json['sms'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (sms != null) 'sms': sms,
      if (code != null) 'code': code,
    };
  }
}

enum AuthMode {
  email,
  sms,
}

abstract class SessionApi {
  /// 必须填写code之后，鉴权成功，返回jwt token
  Future<String> getAuthToken({
    required AuthMode mode,
    required AuthInfo info,
  });

  /// 请求发送验证码
  Future<void> requestAuthCode({
    required AuthMode mode,
    required AuthInfo info,
  });
}
