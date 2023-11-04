/// 用户信息响应体
class UserInfoResponse {
  final int code;
  final String msg;
  final UserInfoData? data;

  UserInfoResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return UserInfoResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return UserInfoResponse(
      code: json['code'],
      msg: json['msg'],
      data: UserInfoData.fromJson(json['data']),
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

/// 用户信息数据
class UserInfoData {
  final int id;
  final String nickname;
  final String avatar;
  final String username;
  final int fansCount;
  final int followCount;
  final int videoCount;

  UserInfoData({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.username,
    required this.fansCount,
    required this.followCount,
    required this.videoCount,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) {
    return UserInfoData(
      id: json['id'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      username: json['username'],
      fansCount: json['fans_count'],
      followCount: json['follow_count'],
      videoCount: json['video_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'username': username,
      'fans_count': fansCount,
      'follow_count': followCount,
      'video_count': videoCount,
    };
  }
}

/// 用户列表响应体
class UserListResponse {
  final int code;
  final String msg;
  final List<UserInfoData>? userList;

  UserListResponse({
    required this.code,
    required this.msg,
    this.userList,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    if (json['user_list'] == null) {
      return UserListResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return UserListResponse(
      code: json['code'],
      msg: json['msg'],
      userList: List<UserInfoData>.from(json['user_list'].map((x) => UserInfoData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    if (userList == null) {
      return {
        'code': code,
        'msg': msg,
      };
    }
    return {
      'code': code,
      'msg': msg,
      'user_list': List<dynamic>.from(userList!.map((x) => x.toJson())),
    };
  }
}
