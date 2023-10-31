import 'package:dio/dio.dart';

import '../api/index.dart';
import 'config.dart';
import 'dio.dart';

class GlobalObjects {
  //dio 用于网络请求
  static final Dio dio = getDioClient();
  //apiProvider API接口的调用 用于调用后端接口 也可以用于mock
  static final ApiProvider apiProvider = GlobalConfig.isMock ? ApiProviderMock() : ApiProviderImpl(dio);

  //token
  static String token = 'none';
}
