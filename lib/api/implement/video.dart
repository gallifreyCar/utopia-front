import 'package:dio/dio.dart';

import '../abstract/video.dart';
import '../model/base.dart';
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
  Future<DefaultResponse> favorite(VideoLikeAndFavoriteRequest request) async {
    final resp = await dio.post('/api/v1/interact/favorite', data: request.toJson());
    return DefaultResponse.fromJson(resp.data);
  }

  @override
  Future<DefaultResponse> follow(FollowRequest request) async {
    final resp = await dio.post('/api/v1/interact/follow', data: request.toJson());
    return DefaultResponse.fromJson(resp.data);
  }

  @override
  Future<DefaultResponse> like(VideoLikeAndFavoriteRequest request) async {
    final resp = await dio.post('/api/v3/interact/like', data: request.toJson());
    return DefaultResponse.fromJson(resp.data);
  }
}