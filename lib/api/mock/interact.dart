import 'package:utopia_front/api/abstract/interact.dart';
import 'package:utopia_front/api/model/interact.dart';

import '../model/base.dart';

class InteractApiMock extends InteractApi {
  @override
  Future<DefaultResponse> favorite(VideoLikeAndFavoriteRequest request) {
    return Future.delayed(const Duration(seconds: 1), () {
      return DefaultResponse(code: 2000, msg: 'ok');
    });
  }

  @override
  Future<DefaultResponse> follow(FollowRequest request) {
    return Future.delayed(const Duration(seconds: 1), () {
      return DefaultResponse(code: 2000, msg: 'ok');
    });
  }

  @override
  Future<DefaultResponse> like(VideoLikeAndFavoriteRequest request) {
    return Future.delayed(const Duration(seconds: 1), () {
      return DefaultResponse(code: 2000, msg: 'ok');
    });
  }

  @override
  Future<CommentResponse> getComment(CommentRequest request) {
    // TODO: implement getComment
    throw UnimplementedError();
  }
}
