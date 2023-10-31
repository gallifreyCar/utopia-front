import 'dart:io';

import 'package:dio/dio.dart';

import 'config.dart';
import 'index.dart';

//JwtAuthInterceptor 是一个拦截器，用于在每次请求时，将token放入请求头中
class JwtAuthInterceptor extends Interceptor {
  String? Function() tokenGetter;

  JwtAuthInterceptor({required this.tokenGetter});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final jwtToken = tokenGetter();
    if (jwtToken != null) {
      options.headers['Authorization'] = 'Bearer $jwtToken';
    }
    super.onRequest(options, handler);
  }
}

// MyHttpOverrides 是一个代理设置，用于在请求时，将请求代理到指定的服务器
class MyHttpOverrides extends HttpOverrides {
  final String? proxy;
  MyHttpOverrides(this.proxy);
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (url) {
      if (proxy == null) {
        return 'DIRECT';
      }
      return 'PROXY $proxy';
    };
    return client;
  }
}

// getDioClient 是一个工厂方法，用于创建一个Dio实例
Dio getDioClient() {
  // HttpOverrides.global = MyHttpOverrides(GlobalConfig.proxy);
  final dio = Dio(BaseOptions(
    baseUrl: GlobalConfig.baseUrl,
    connectTimeout: GlobalConfig.connectTimeout,
    receiveTimeout: GlobalConfig.receiveTimeout,
    sendTimeout: GlobalConfig.sendTimeout,
  ));
  dio.interceptors.add(JwtAuthInterceptor(tokenGetter: () => GlobalObjects.storageProvider.user.jwtToken));
  return dio;
}
