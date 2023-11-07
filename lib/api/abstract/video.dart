import '../model/video.dart';

///视频API接口
abstract class VideoApi {
  //获取视频列表
  Future<VideoResponse> getVideoList(VideoRequest request);

  //搜索视频
  Future<VideoResponseNoNextTime> searchVideoList(SearchVideoRequest request);

  //获取某人的视频列表
  Future<VideoResponse> getVideoListByUserId(SomeoneVideoRequest request);

  //获取单个视频
  Future<SingleVideoResponse> getVideoByVideoId(VideoByVideoIdRequest request);

  //获取热门视频
  Future<HotVideoResponse> getHotVideoList(HotVideoRequest request);

  //获取个人收藏的视频
  Future<VideoResponse> getFavoriteVideoList(SomeoneVideoRequest request);

  //获取推荐视频
  Future<VideoResponse> getRecommendVideoList(int lastTime);
}
