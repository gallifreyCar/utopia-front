import 'package:dio/dio.dart';
import 'package:utopia_front/api/abstract/upload_file.dart';
import 'package:utopia_front/api/abstract/video.dart';
import 'package:utopia_front/api/implement/upload_file.dart';
import 'package:utopia_front/api/implement/user.dart';
import 'package:utopia_front/api/mock/video.dart';

import 'abstract/session.dart';
import 'abstract/user.dart';
import 'implement/session.dart';
import 'implement/video.dart';

abstract class ApiProvider {
  SessionApi get session;
  UploadFileApi get upload;
  VideoApi get video;
  UserApi get user;
}

// 网络请求的实现 调用后端接口
class ApiProviderImpl extends ApiProvider {
  final Dio dio;
  ApiProviderImpl(this.dio);

  @override
  SessionApi get session => SessionApiImpl(dio);

  @override
  UploadFileApi get upload => UploadFileApiImpl(dio);

  @override
  VideoApi get video => VideoApiImpl(dio);

  @override
  get user => UserApiImpl(dio);
}

// Mock的实现 用于测试
class ApiProviderMock extends ApiProvider {
  @override
  SessionApi get session => throw UnimplementedError();

  @override
  // TODO: implement upload
  UploadFileApi get upload => throw UnimplementedError();

  @override
  VideoApi get video => VideoApiMock();

  @override
  // TODO: implement user
  get user => throw UnimplementedError();
}
