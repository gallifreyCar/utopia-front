import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/login/index.dart';
import 'package:utopia_front/pages/user/index.dart';
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
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.cubeGrid;
    final app = MaterialApp(
      theme: ThemeData(
        // 微软雅黑
        fontFamily: 'MyCustomFont',
      ),
      title: _title,
      routes: {
        '/select': (context) => const LoginModeSelectorPage(),
        '/login': (context) => const LoginPage(),
        '/video': (context) {
          final Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final int userId = arguments?['userId'] ?? 0;
          final int mode = arguments?['mode'] ?? 0;
          final int videoId = arguments?['videoId'] ?? 0;
          return IndexPage(userId: userId, mode: mode, videoId: videoId);
        },
        '/user': (context) => const UserPage(),
      },
      home: () {
        // 如果用户未登录，则跳转到登录页面
        if (GlobalObjects.storageProvider.user.jwtToken == null) {
          return const LoginModeSelectorPage();
        } else {
          return const IndexPage(userId: 0, mode: 3, videoId: 0);
        }
      }(),
      builder: EasyLoading.init(),
    );

    return app;
  }
}
