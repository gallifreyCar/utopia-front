import '../../util/kv_storage.dart';
import '../abstract/user.dart';

//用户存储实现
class UserStorageImpl implements UserStorageBase {
  static const _jwtTokenKey = 'jwtToken';
  static const _uidKey = 'uid';
  static const _usernameKey = 'username';
  static const _nicknameKey = 'nickname';
  static const _avatarKey = 'avatar';
  static const _fansCountKey = 'fansCount';
  static const _followCountKey = 'followCount';
  static const _videoCountKey = 'videoCount';

  KvStorage kv;

  UserStorageImpl(this.kv);

  @override
  String? get jwtToken => kv.get<String>(_jwtTokenKey);
  @override
  set jwtToken(String? value) => kv.set(_jwtTokenKey, value);

  @override
  int? get uid => kv.get<int>(_uidKey);
  @override
  set uid(int? value) => kv.set(_uidKey, value);

  @override
  String? get username => kv.get<String>(_usernameKey);
  @override
  set username(String? value) => kv.set(_usernameKey, value);

  @override
  String? get nickname => kv.get<String>(_nicknameKey);
  @override
  set nickname(String? value) => kv.set(_nicknameKey, value);

  @override
  String? get avatar => kv.get<String>(_avatarKey);
  @override
  set avatar(String? value) => kv.set(_avatarKey, value);

  @override
  int? get fansCount => kv.get<int>(_fansCountKey);
  @override
  set fansCount(int? value) => kv.set(_fansCountKey, value);

  @override
  int? get followCount => kv.get<int>(_followCountKey);
  @override
  set followCount(int? value) => kv.set(_followCountKey, value);

  @override
  int? get videoCount => kv.get<int>(_videoCountKey);
  @override
  set videoCount(int? value) => kv.set(_videoCountKey, value);
}
