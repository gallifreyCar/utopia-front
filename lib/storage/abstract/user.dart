///用户存储接口
abstract class UserStorageBase {
  String? get jwtToken;
  set jwtToken(String? value);

  int? get uid;
  set uid(int? value);

  String? get username;
  set username(String? value);

  String? get nickname;
  set nickname(String? value);

  String? get avatar;
  set avatar(String? value);

  int? get fansCount;
  set fansCount(int? value);

  int? get followCount;
  set followCount(int? value);

  int? get videoCount;
  set videoCount(int? value);
}
