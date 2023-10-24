import 'package:dio/dio.dart';

import 'implement/session.dart';
import 'interface/session.dart';

abstract class ApiProvider {
  SessionApi get session;
}

class ApiProviderImpl extends ApiProvider {
  final Dio dio;
  ApiProviderImpl(this.dio);

  @override
  SessionApi get session => SessionApiImpl(dio);
}
