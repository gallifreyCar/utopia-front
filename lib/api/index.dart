import 'package:dio/dio.dart';

import 'implement/session.dart';
import 'interface/session.dart';

abstract class ApiProvider {
  SessionApi get session;
}

// 网络请求的实现 调用后端接口
class ApiProviderImpl extends ApiProvider {
  final Dio dio;
  ApiProviderImpl(this.dio);

  @override
  SessionApi get session => SessionApiImpl(dio);
}

// Mock的实现 用于测试
class ApiProviderMock extends ApiProvider {
  @override
  SessionApi get session => throw UnimplementedError();
}
