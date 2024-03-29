import 'package:dio/dio.dart';

import '../abstract/video.dart';
import '../model/video.dart';

class VideoApiImpl extends VideoApi {
  final Dio dio;

  VideoApiImpl(this.dio);

  @override
  Future<VideoResponse> getVideoList(VideoRequest request) async {
    final resp = await dio.get('/api/v1/video/category', queryParameters: {
      "last_time": request.lastTime,
      "video_type_id": request.videoType,
    });
    return VideoResponse.fromJson(resp.data);
  }

  @override
  Future<VideoResponseNoNextTime> searchVideoList(SearchVideoRequest request) async {
    final resp = await dio.get('/api/v1/video/search', queryParameters: {
      "search": request.search,
    });
    return VideoResponseNoNextTime.fromJson(resp.data);
  }

  @override
  Future<VideoResponse> getVideoListByUserId(SomeoneVideoRequest request) async {
    final resp = await dio.get('/api/v1/video/upload', queryParameters: {
      "user_id": request.userId,
      "last_time": request.lastTime,
    });
    return VideoResponse.fromJson(resp.data);
  }

  @override
  Future<SingleVideoResponse> getVideoByVideoId(VideoByVideoIdRequest request) async {
    final resp = await dio.get('/api/v1/video/single', queryParameters: {
      "video_id": request.videoId,
    });
    return SingleVideoResponse.fromJson(resp.data);
  }

  @override
  Future<HotVideoResponse> getHotVideoList(HotVideoRequest request) async {
    final resp = await dio.get('/api/v1/video/popular', queryParameters: {
      "version": request.version,
      "score": request.score,
    });
    return HotVideoResponse.fromJson(resp.data);
  }

  @override
  Future<VideoResponse> getFavoriteVideoList(SomeoneVideoRequest request) async {
    final resp = await dio.get('/api/v1/video/favorite', queryParameters: {
      "user_id": request.userId,
      "last_time": request.lastTime,
    });
    return VideoResponse.fromJson(resp.data);
  }

  @override
  Future<VideoResponse> getRecommendVideoList(int lastTime) async {
    final resp = await dio.get('/api/v1/video/feed', queryParameters: {
      "last_time": lastTime,
    });
    return VideoResponse.fromJson(resp.data);
  }
}
