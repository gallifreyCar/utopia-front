import 'package:dio/dio.dart';

import '../api/index.dart';
import 'dio.dart';

class GlobalObjects {
  static final Dio dio = getDioClient();

  //token
  static String token = 'none';
  static final ApiProvider apiProvider = ApiProviderImpl(dio);
}
