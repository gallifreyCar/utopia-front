import 'package:url_launcher/url_launcher.dart';

// 打开浏览器
Future<void> launchInBrowser(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    throw UnsupportedError('Cannot load $url');
  }
  launchUrl(uri, mode: LaunchMode.externalApplication);
}
