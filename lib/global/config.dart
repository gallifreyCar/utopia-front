class GlobalConfig {
  static const String baseUrl = 'http://api.tbghg.top:8080';
  static const String? proxy = null;
  static const bool isDebug = true;
  static const bool isMock = true;
  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration receiveTimeout = Duration(seconds: 6);
  static const Duration sendTimeout = Duration(seconds: 6);
}
