import '../model/user.dart';

///用户API接口
abstract class UserApi {
  //获取用户信息
  Future<UserInfoResponse> getUserInfo();
  //获取粉丝列表
  Future<UserListResponse> getFansList();
  //获取关注列表
  Future<UserListResponse> getFollowList();
}
