import 'package:dio/dio.dart';

import '../abstract/user.dart';
import '../model/user.dart';

class UserApiImpl extends UserApi {
  final Dio dio;
  UserApiImpl(this.dio);

  @override
  Future<UserInfoResponse> getUserInfo() async {
    final resp = await dio.get('/api/v1/user/info');
    return UserInfoResponse.fromJson(resp.data);
  }

  @override
  Future<UserListResponse> getFansList() async {
    final resp = await dio.get('/api/v1/interact/follower/list');
    return UserListResponse.fromJson(resp.data);
  }

  @override
  Future<UserListResponse> getFollowList() async {
    final resp = await dio.get('/api/v1/interact/follow/list');
    return UserListResponse.fromJson(resp.data);
  }
}
