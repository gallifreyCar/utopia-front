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

/// 评论数据响应体
class CommentResponse {
  final int code;
  final String msg;
  final CommentData? data;

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
      data: CommentData.fromJson(json['data']),
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

/// 评论数据 {List<CommentInfo>评论信息，nextTime下次请求的时间}
class CommentData {
  final List<CommentInfo> commentInfo;
  final int nextTime;

  CommentData({
    required this.commentInfo,
    required this.nextTime,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    // 如果 nextTime 为 -1，说明没有更多数据了 不用解析 videoInfo
    if (json['next_time'] == -1 || json['comment_info'] == null) {
      return CommentData(
        commentInfo: [],
        nextTime: -1,
      );
    }
    return CommentData(
      commentInfo:
          (json['comment_info'] as List<dynamic>).map((e) => CommentInfo.fromJson(e as Map<String, dynamic>)).toList(),
      nextTime: json['next_time'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_info': commentInfo.map((e) => e.toJson()).toList(),
      'next_time': nextTime,
    };
  }
}

/// 评论信息
class CommentInfo {
  final String content;
  final String nickname;
  final String avatar;

  CommentInfo({
    required this.content,
    required this.nickname,
    required this.avatar,
  });

  factory CommentInfo.fromJson(Map<String, dynamic> json) {
    return CommentInfo(
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
