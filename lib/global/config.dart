class GlobalConfig {
  static const String baseUrl = 'http://106.15.107.229:8080';
  static const String? proxy = null;
  static const bool isDebug = true;
  static const bool isMock = false;
  static const Duration connectTimeout = Duration(seconds: 3);
  static const Duration receiveTimeout = Duration(seconds: 3);
  static const Duration sendTimeout = Duration(seconds: 3);
}
