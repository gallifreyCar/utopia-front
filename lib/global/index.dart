import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/index.dart';
import '../storage/index.dart';
import '../util/kv_storage.dart';
import 'config.dart';
import 'dio.dart';

class GlobalObjects {
  //dio 用于网络请求
  static final Dio dio = getDioClient();
  //apiProvider API接口的调用 用于调用后端接口 也可以用于mock
  static final ApiProvider apiProvider = GlobalConfig.isMock ? ApiProviderMock() : ApiProviderImpl(dio);
  //storageProvider KvStorage 用于存储数据
  static final StorageProvider storageProvider = StorageProviderImpl(kvStorage);
  static late KvStorage kvStorage;
  //Logger 日志
  static Logger logger = Logger();

  //初始化
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    kvStorage = KvStorageLogWrapper(
      source: KvStoragePreferenceImpl(prefs),
      logger: logger,
    );
  }
}
