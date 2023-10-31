import 'package:flutter/material.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/index.dart';
import 'package:utopia_front/pages/login/index.dart';

void main() {
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
          if (GlobalObjects.token != "none") {
            return const IndexPage();
          } else {
            return const LoginModeSelectorPage();
          }
        }());

    return app;
  }
}
