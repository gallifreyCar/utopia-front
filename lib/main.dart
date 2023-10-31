import 'package:flutter/material.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/login/index.dart';
import 'package:utopia_front/pages/video/index.dart';

final _log = GlobalObjects.logger;

Future<void> main() async {
  // 初始化Flutter
  WidgetsFlutterBinding.ensureInitialized();
  _log.d('main: init');
  // 等待全局组件初始化
  await GlobalObjects.init();
  _log.d('main: init done');
  // 运行应用
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Utopia';

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
        title: _title,
        home: () {
          // 如果用户未登录，则跳转到登录页面
          if (GlobalObjects.storageProvider.user.jwtToken == null) {
            return const LoginModeSelectorPage();
          } else {
            return const IndexPage();
          }
        }());

    return app;
  }
}
