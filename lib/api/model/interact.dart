///点赞和收藏的请求参体
class VideoLikeAndFavoriteRequest {
  final int videoId;
  final int actionType;

  VideoLikeAndFavoriteRequest({
    required this.videoId,
    required this.actionType,
  });

  factory VideoLikeAndFavoriteRequest.fromJson(Map<String, dynamic> json) {
    return VideoLikeAndFavoriteRequest(
      videoId: json['video_id'] as int,
      actionType: json['action_type'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'action_type': actionType,
    };
  }
}

///关注的请求体
class FollowRequest {
  final int actionType;
  final int toUserId;

  FollowRequest({
    required this.actionType,
    required this.toUserId,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      actionType: json['action_type'] as int,
      toUserId: json['to_user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_type': actionType,
      'to_user_id': toUserId,
    };
  }
}

/// 评论请求
class CommentRequest {
  final int videoId;
  final int? lastTime;

  CommentRequest({
    required this.videoId,
    this.lastTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'last_time': lastTime,
    };
  }

  factory CommentRequest.fromJson(Map<String, dynamic> json) {
    return CommentRequest(
      videoId: json['video_id'] as int,
      lastTime: json['last_time'] as int?,
    );
  }
}

/// 评论数据
class CommentResponse {
  final int code;
  final String msg;
  final List<CommentData>? data;

  CommentResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return CommentResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return CommentResponse(
      code: json['code'],
      msg: json['msg'],
      data: (json['data'] as List<dynamic>).map((e) => CommentData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    if (data == null) {
      return {
        'code': code,
        'msg': msg,
      };
    }
    return {'code': code, 'msg': msg, 'data': data!.map((e) => e.toJson()).toList()};
  }
}

/// 评论数据
class CommentData {
  final String content;
  final String nickname;
  final String avatar;

  CommentData({
    required this.content,
    required this.nickname,
    required this.avatar,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      content: json['content'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'nickname': nickname,
      'avatar': avatar,
    };
  }
}

/// 发表评论的请求体
class PostCommentRequest {
  final int videoId;
  final String content;

  PostCommentRequest({
    required this.videoId,
    required this.content,
  });

  factory PostCommentRequest.fromJson(Map<String, dynamic> json) {
    return PostCommentRequest(
      videoId: json['video_id'] as int,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'content': content,
    };
  }
}
