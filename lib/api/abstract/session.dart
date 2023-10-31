//登录请求参数
class AuthInfo {
  final String? username;
  final String? password;

  const AuthInfo({
    this.username,
    this.password,
  });

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

//登录请求响应参数
class AuthResponse {
  final int code;
  final String msg;
  final Data? data; // 使用可选类型 Data?

  AuthResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return AuthResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return AuthResponse(
      code: json['code'],
      msg: json['msg'],
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    if (data == null) {
      return {
        'code': code,
        'msg': msg,
      };
    }
    return {'code': code, 'msg': msg, 'data': data!.toJson()};
  }
}

class Data {
  final String token;
  final int userId;

  Data({
    required this.token,
    required this.userId,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      token: json['token'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
    };
  }
}

abstract class SessionApi {
  /// 鉴权成功，返回jwt token
  Future<AuthResponse> login({
    required AuthInfo info,
  });
}
