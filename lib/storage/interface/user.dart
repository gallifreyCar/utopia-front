//用户存储接口
abstract class UserStorageBase {
  String? get jwtToken;
  set jwtToken(String? value);

  int? get uid;
  set uid(int? value);
}
