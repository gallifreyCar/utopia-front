///默认响应体
class DefaultResponse {
  final int code;
  final String msg;

  DefaultResponse({
    required this.code,
    required this.msg,
  });

  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
    };
  }
}

/// 静态变量： 状态码
const int successCode = 2000;
const int errorCode = 4000;
