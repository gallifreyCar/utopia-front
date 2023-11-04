///视频接口的请求参数
class VideoRequest {
  //最后时间 时间戳
  final int? lastTime;

  //视频类型
  final int? videoType;

  const VideoRequest({
    this.lastTime,
    this.videoType,
  });

  factory VideoRequest.fromJson(Map<String, dynamic> json) {
    return VideoRequest(
      lastTime: json['lastTime'] as int?,
      videoType: json['videoType'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastTime': lastTime,
      'videoType': videoType,
    };
  }
}

///视频接口的响应体
class VideoResponse {
  final int code;
  final String msg;
  final VideoData? data;

  VideoResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return VideoResponse(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return VideoResponse(
      code: json['code'],
      msg: json['msg'],
      data: VideoData.fromJson(json['data']),
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

///视频数据
class VideoData {
  final List<VideoInfo> videoInfo;
  final int nextTime;

  VideoData({
    required this.videoInfo,
    required this.nextTime,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    // 如果 nextTime 为 -1，说明没有更多数据了 不用解析 videoInfo
    if (json['next_time'] == -1 || json['video_info'] == null) {
      return VideoData(
        videoInfo: [],
        nextTime: -1,
      );
    }
    return VideoData(
      videoInfo:
          (json['video_info'] as List<dynamic>).map((e) => VideoInfo.fromJson(e as Map<String, dynamic>)).toList(),
      nextTime: json['next_time'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    // 如果 nextTime 为 -1，说明没有更多数据了 不用解析 videoInfo
    if (nextTime == -1 || videoInfo == null) {
      return {
        'video_info': [],
        'next_time': -1,
      };
    }
    return {
      'video_info': videoInfo.map((e) => e.toJson()).toList(),
      'next_time': nextTime,
    };
  }
}

///视频信息
class VideoInfo {
  final int id;
  final String createdAt;
  final String playUrl;
  final String coverUrl;
  final int videoTypeId;
  final String describe;
  final Author author;
  final bool isFollow;
  final bool isLike;
  final bool isFavorite;
  final int likeCount;
  final int favoriteCount;

  VideoInfo({
    required this.id,
    required this.createdAt,
    required this.playUrl,
    required this.coverUrl,
    required this.videoTypeId,
    required this.describe,
    required this.author,
    required this.isFollow,
    required this.isLike,
    required this.isFavorite,
    required this.likeCount,
    required this.favoriteCount,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      playUrl: json['play_url'] as String,
      coverUrl: json['cover_url'] as String,
      videoTypeId: json['video_type_id'] as int,
      describe: json['describe'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      isFollow: json['is_follow'] as bool,
      isLike: json['is_like'] as bool,
      isFavorite: json['is_favorite'] as bool,
      likeCount: json['like_count'] as int,
      favoriteCount: json['favorite_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'play_url': playUrl,
      'cover_url': coverUrl,
      'video_type_id': videoTypeId,
      'describe': describe,
      'author': author.toJson(),
      'is_follow': isFollow,
      'is_like': isLike,
      'is_favorite': isFavorite,
      'like_count': likeCount,
      'favorite_count': favoriteCount,
    };
  }
}

///作者信息
class Author {
  final int id;
  final String nickname;
  final String avatar;
  final String username;
  final int fansCount;
  final int followCount;
  final int videoCount;

  Author({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.username,
    required this.fansCount,
    required this.followCount,
    required this.videoCount,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      username: json['username'] as String,
      fansCount: json['fans_count'] as int,
      followCount: json['follow_count'] as int,
      videoCount: json['video_count'] as int,
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
