//上传七牛云的请求参数
import 'dart:html';

class UploadFileRequest {
  /*
    action	string	是	上传地址，可参考存储区域
    resource_key	string	否	资源名，必须是 UTF-8 编码。注意： 如果上传凭证中 scope 指定为 <bucket>:<key>， 则该字段也必须指定。
    custom_name	string	否	自定义变量的名字，不限个数。
    custom_value	string	否	自定义变量的值。
    upload_token	string	是	必须是一个符合相应规格的上传凭证，否则会返回 401 表示权限认证失败。
    crc32	string	否	上传内容的 crc32 校验码。如填入，则七牛服务器会使用此值进行内容检验。
    accept	string	否	当 HTTP 请求指定 accept 头部时，七牛会返回 content-type 头部的值。该值用于兼容低版本 IE 浏览器行为。低版本 IE 浏览器在表单上传时，返回 application/json 表示下载，返回 text/plain 才会显示返回内容。
    file	file	是	文件本身。
    "x:file_type":     "VIDEO",
    "x:describe":      "这是我的一个视频描述",
    "x:cover_url":     "这个是封面链接",
    "x:video_type_id": "1",
    "x:uid":           "1",
 */
  final String? resourceKey; //资源名，必须是 UTF-8 编码。注意： 如果上传凭证中 scope 指定为 <bucket>:<key>， 则该字段也必须指定。
  final String uploadToken; //必须是一个符合相应规格的上传凭证，否则会返回 401 表示权限认证失败。
  final File file; //上传的文件
  final String? fileType; //文件类型
  final String? describe; //文件描述
  final String? coverUrl; //封面链接
  final String? videoTypeId; //视频类型id
  final String? videoTypeName; //视频类型名称

  UploadFileRequest({
    this.resourceKey,
    this.fileType,
    this.describe,
    this.coverUrl,
    this.videoTypeId,
    this.videoTypeName,
    required this.uploadToken,
    required this.file,
  });
}

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

//上传文件的API抽象类
abstract class UploadFileAPI {
  //获取七牛云存储kodo的token
  Future<GetKodoTokenResponse> getKodoToken();

  //上传文件到七牛云
  Future<String> uploadFileToKodo(String token, UploadFileRequest request);
}
