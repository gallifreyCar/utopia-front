import 'package:dio/dio.dart';

import '../abstract/video.dart';

class VideoApiImpl extends VideoApi {
  final Dio dio;
  VideoApiImpl(this.dio);
  @override
  Future<VideoResponse> getVideoList(VideoRequest videoRequest) async {
    final resp = await dio.get('/api/v1/video/category', queryParameters: {
      "last_time": videoRequest.lastTime,
      "video_type_id": videoRequest.videoType,
    });
    return VideoResponse.fromJson(resp.data);
  }
}
