import '../../util/kv_storage.dart';
import '../abstract/user.dart';

//用户存储实现
class UserStorageImpl implements UserStorageBase {
  static const _jwtTokenKey = 'jwtToken';
  static const _uidKey = 'uid';
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
}
