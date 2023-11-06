class GlobalConfig {
  static const String workBaseUrl = 'https://api.tbghg.top';
  static const String testBaseUrl = 'localhost:8080';
  static const String qiniuKodoUrl = 'http://up-cn-east-2.qiniup.com';
  static const String? proxy = null;
  static const bool isUseTestBaseUrl = false;
  static const bool isDebug = true;
  static const bool isMock = false;
  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration receiveTimeout = Duration(seconds: 6);
  static const Duration sendTimeout = Duration(seconds: 6);
}
