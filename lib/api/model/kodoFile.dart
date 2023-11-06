///上传七牛云的请求参数
class UploadFileRequest {
  final String? resourceKey; //资源名，必须是 UTF-8 编码。注意： 如果上传凭证中 scope 指定为 <bucket>:<key>， 则该字段也必须指定。
  final String uploadToken; //必须是一个符合相应规格的上传凭证，否则会返回 401 表示权限认证失败。
  final String file; //上传的文件
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

///获取七牛云存储kodo的token的响应体
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

/// 上传视频回调的响应体
// {"code":2000,"data":{"image_url":"https://kodo.tbghg.top/70738d7f-02.png"},"msg":"ok"}
class UploadFileCallbackResponse {
  final int code;
  final String msg;
  final UploadFileCallbackData? data;

  UploadFileCallbackResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory UploadFileCallbackResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return UploadFileCallbackResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return UploadFileCallbackResponse(
      code: json['code'],
      msg: json['msg'],
      data: UploadFileCallbackData.fromJson(json['data']),
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

class UploadFileCallbackData {
  final String imageUrl;

  UploadFileCallbackData({
    required this.imageUrl,
  });

  factory UploadFileCallbackData.fromJson(Map<String, dynamic> json) {
    return UploadFileCallbackData(
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
    };
  }
}
