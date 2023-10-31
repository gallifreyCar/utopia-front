//上传七牛云的请求参数
// <form method="post" action="http://upload.qiniup.com/"
// enctype="multipart/form-data">
// <input name="key" type="hidden" value="<resource_key>">
// <input name="x:<custom_name>" type="hidden" value="<custom_value>">
// <input name="token" type="hidden" value="<upload_token>">
// <input name="crc32" type="hidden" />
// <input name="accept" type="hidden" />
// <input name="file" type="file" />
// <input type="submit" value="上传文件" />
// </form>

//获取七牛云存储kodo的token的响应体
class GetKodoTokenResponse {
  final int code;
  final String msg;
  final KodoTokenData? data; // 使用可选类型 Data?

  GetKodoTokenResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory GetKodoTokenResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return GetKodoTokenResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return GetKodoTokenResponse(
      code: json['code'],
      msg: json['msg'],
      data: KodoTokenData.fromJson(json['data']),
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

//上传文件的API抽象类
abstract class UploadFileAPI {
  //获取七牛云存储kodo的token
  Future<GetKodoTokenResponse> getKodoToken();

  //上传文件到七牛云
  Future<String> uploadFileToKodo(String token, String filePath);
}

class KodoTokenData {
  final String token;

  KodoTokenData({
    required this.token,
  });

  factory KodoTokenData.fromJson(Map<String, dynamic> json) {
    return KodoTokenData(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
