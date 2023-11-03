import '../model/user.dart';

///用户API接口
abstract class UserApi {
  Future<UserInfoResponse> getUserInfo();
}
