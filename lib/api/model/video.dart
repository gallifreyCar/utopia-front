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

///搜索视频的请求参数
class SearchVideoRequest {
  //搜索关键字
  final String? search;

  const SearchVideoRequest({
    this.search,
  });

  factory SearchVideoRequest.fromJson(Map<String, dynamic> json) {
    return SearchVideoRequest(
      search: json['search'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search': search,
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

///搜索视频接口的响应体 没有nextTime
class VideoResponseNoNextTime {
  final int code;
  final String msg;
  final VideoDataNoNextTime? data;

  VideoResponseNoNextTime({
    required this.code,
    required this.msg,
    this.data,
  });

  factory VideoResponseNoNextTime.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return VideoResponseNoNextTime(
        code: json['code'],
        msg: json['msg'],
      );
    }
    return VideoResponseNoNextTime(
      code: json['code'],
      msg: json['msg'],
      data: VideoDataNoNextTime.fromJson(json['data']),
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

/// 没有nextTime的视频数据 返回全部数据
class VideoDataNoNextTime {
  final List<VideoInfo> videoInfo;

  VideoDataNoNextTime({
    required this.videoInfo,
  });

  factory VideoDataNoNextTime.fromJson(Map<String, dynamic> json) {
    if (json['video_info'] == null) {
      return VideoDataNoNextTime(
        videoInfo: [],
      );
    }
    return VideoDataNoNextTime(
      videoInfo:
          (json['video_info'] as List<dynamic>).map((e) => VideoInfo.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    if (videoInfo == null) {
      return {
        'video_info': [],
      };
    }
    return {
      'video_info': videoInfo.map((e) => e.toJson()).toList(),
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
  final String title;
  final String describe;
  Author author;
  bool isFollow;
  final bool isLike;
  final bool isFavorite;
  final int likeCount;
  final int favoriteCount;
  final int commentCount;

  VideoInfo({
    required this.id,
    required this.createdAt,
    required this.playUrl,
    required this.coverUrl,
    required this.videoTypeId,
    required this.title,
    required this.describe,
    required this.author,
    required this.isFollow,
    required this.isLike,
    required this.isFavorite,
    required this.likeCount,
    required this.favoriteCount,
    required this.commentCount,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      playUrl: json['play_url'] as String,
      coverUrl: json['cover_url'] as String,
      videoTypeId: json['video_type_id'] as int,
      title: json['title'] as String,
      describe: json['describe'] as String,
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      isFollow: json['is_follow'] as bool,
      isLike: json['is_like'] as bool,
      isFavorite: json['is_favorite'] as bool,
      likeCount: json['like_count'] as int,
      favoriteCount: json['favorite_count'] as int,
      commentCount: json['comment_num'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'play_url': playUrl,
      'cover_url': coverUrl,
      'video_type_id': videoTypeId,
      'title': title,
      'describe': describe,
      'author': author.toJson(),
      'is_follow': isFollow,
      'is_like': isLike,
      'is_favorite': isFavorite,
      'like_count': likeCount,
      'favorite_count': favoriteCount,
      'comment_num': commentCount,
    };
  }
}

///作者信息
class Author {
  final int id;
  final String nickname;
  final String avatar;
  final String username;
  int fansCount;
  final int followCount;
  int videoCount;

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

///获取某个用户的视频列表的请求体
class SomeoneVideoRequest {
  //最后时间 时间戳
  final int? lastTime;

  //视频类型
  final int? userId;

  const SomeoneVideoRequest({
    this.lastTime,
    this.userId,
  });

  factory SomeoneVideoRequest.fromJson(Map<String, dynamic> json) {
    return SomeoneVideoRequest(
      lastTime: json['lastTime'] as int?,
      userId: json['user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastTime': lastTime,
      'user_id': userId,
    };
  }
}

/// 获取某个视频的详细信息的请求体
class VideoByVideoIdRequest {
  final int videoId;

  const VideoByVideoIdRequest({
    required this.videoId,
  });

  factory VideoByVideoIdRequest.fromJson(Map<String, dynamic> json) {
    return VideoByVideoIdRequest(
      videoId: json['video_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
    };
  }
}

/// 获取某个视频的详细信息的响应体
class SingleVideoResponse {
  final int code;
  final String msg;
  final VideoInfo videoInfo;

  const SingleVideoResponse({
    required this.code,
    required this.msg,
    required this.videoInfo,
  });

  factory SingleVideoResponse.fromJson(Map<String, dynamic> json) {
    return SingleVideoResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      videoInfo: VideoInfo.fromJson(json['data']['video_info'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': videoInfo.toJson(),
    };
  }
}

/// 获取热门视频的请求体 score version
class HotVideoRequest {
  final double? score;
  final int? version;

  const HotVideoRequest({
    this.score,
    this.version,
  });

  factory HotVideoRequest.fromJson(Map<String, dynamic> json) {
    return HotVideoRequest(
      score: json['score'] as double?,
      version: json['version'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'version': version,
    };
  }
}

/// 获取热门视频的响应体
class HotVideoResponse {
  int code;
  String msg;
  HotVideoData data;

  HotVideoResponse({required this.code, required this.msg, required this.data});

  factory HotVideoResponse.fromJson(Map<String, dynamic> json) {
    return HotVideoResponse(
      code: json['code'],
      msg: json['msg'],
      data: HotVideoData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data.toJson(),
    };
  }
}

class HotVideoData {
  List<VideoInfo> hotVideo;
  double score;
  int version;

  HotVideoData({required this.hotVideo, required this.score, required this.version});

  factory HotVideoData.fromJson(Map<String, dynamic> json) {
    if (json['video_info'] == null) {
      return HotVideoData(
        hotVideo: [],
        score: -1,
        version: 0,
      );
    }

    return HotVideoData(
      hotVideo: (json['video_info'] as List).map((e) => VideoInfo.fromJson(e)).toList(),
      score: json['score'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    if (score == -1 || hotVideo.isEmpty) {
      hotVideo = [];
    }
    return {
      'video_info': hotVideo.map((e) => e.toJson()).toList(),
      'score': score,
      'version': version,
    };
  }
}
