import '../model/base.dart';
import '../model/video.dart';

///视频API接口
abstract class VideoApi {
  //获取视频列表
  Future<VideoResponse> getVideoList(VideoRequest request);

  //关注/取消关注
  Future<DefaultResponse> follow(FollowRequest request);

  //点赞/取消点赞
  Future<DefaultResponse> like(VideoLikeAndFavoriteRequest request);

  //收藏/取消收藏
  Future<DefaultResponse> favorite(VideoLikeAndFavoriteRequest request);
}
