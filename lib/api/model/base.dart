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
