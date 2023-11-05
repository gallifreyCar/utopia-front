import 'package:dio/dio.dart';

import '../abstract/interact.dart';
import '../model/base.dart';
import '../model/interact.dart';

class InteractApiImpl extends InteractApi {
  final Dio dio;
  InteractApiImpl(this.dio);

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

  @override
  Future<CommentResponse> getComment(CommentRequest request) async {
    final resp = await dio.get('/api/v1/interact/comment/list', data: request.toJson());
    return CommentResponse.fromJson(resp.data);
  }

  @override
  Future<DefaultResponse> postComment(PostCommentRequest request) async {
    final resp = await dio.post('/api/v1/interact/comment/post', data: request.toJson());
    return DefaultResponse.fromJson(resp.data);
  }
}
