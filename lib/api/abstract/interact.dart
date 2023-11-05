import '../model/base.dart';
import '../model/interact.dart';

abstract class InteractApi {
  //关注/取消关注
  Future<DefaultResponse> follow(FollowRequest request);

  //点赞/取消点赞
  Future<DefaultResponse> like(VideoLikeAndFavoriteRequest request);

  //收藏/取消收藏
  Future<DefaultResponse> favorite(VideoLikeAndFavoriteRequest request);

  //获取评论
  Future<CommentResponse> getComment(CommentRequest request);
}
