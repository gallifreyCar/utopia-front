import '../util/kv_storage.dart';
import 'abstract/user.dart';
import 'implement/user.dart';

abstract class StorageProvider {
  UserStorageBase get user;
}

class StorageProviderImpl implements StorageProvider {
  final KvStorage kv;
  StorageProviderImpl(this.kv);

  @override
  UserStorageBase get user => UserStorageImpl(
        KvStorageWithNamespace(
          source: kv,
          namespace: 'user',
        ),
      );
}
