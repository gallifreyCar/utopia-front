import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:utopia_front/util/flash.dart';
import 'package:utopia_front/util/launch.dart';

import '../../api/abstract/session.dart';
import '../../global/index.dart';
import '../video/index.dart';

final _log = GlobalObjects.logger;

class LoginModeSelectorPage extends StatelessWidget {
  const LoginModeSelectorPage({Key? key}) : super(key: key);

  ///构建登录模式按钮
  Widget buildLoginModeButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(icon, size: 30),
          ),
          const SizedBox(height: 10),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Utopia',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildLoginModeButton(Icons.account_box, '登录注册', () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginPage(
                      mode: LoginMode.account,
                    ),
                  ));
                }),
                buildLoginModeButton(Icons.accessibility, '游客入口', () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IndexPage()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///登录模式
enum LoginMode {
  //账号密码登录
  account,
  //游客模式
  guest,
}

///登录页面
class LoginPage extends StatefulWidget {
  final LoginMode mode;
  const LoginPage({
    Key? key,
    required this.mode,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// State
  bool isPasswordClear = false;
  bool isLicenseAccepted = false;
  bool disableLoginButton = false;
  bool disableRegisterButton = false;
  bool isObscure = true;

  /// 用户点击登录按钮后
  Future<void> onLogin() async {
    //未勾选用户协议 提示用户勾选 禁用登录按钮
    if (!isLicenseAccepted) {
      showBasicFlash(context, const Text('请勾选用户协议'));
      return;
    }
    setState(() {
      disableLoginButton = true;
    });

    try {
      //mounted:当前页面是否被挂载
      if (!mounted) return;
      // 发起请求 获取token
      final api = GlobalObjects.apiProvider;
      final authInfo = AuthInfo(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      AuthResponse resp = await api.session.login(
        info: authInfo,
      );

      if (!mounted) return;
      _log.d('登录情况: $resp');
      // 登录成功
      if (resp.code == 2000) {
        // 保存token和userID
        GlobalObjects.storageProvider.user.jwtToken = resp.data?.token;
        GlobalObjects.storageProvider.user.uid = resp.data?.userId;
        // 保存用户信息
        showBasicFlash(context, const Text('登录成功'));
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => IndexPage(),
        ));
      }
      // 登录失败
      if (resp.code == 4000) {
        showBasicFlash(context, Text('登录失败: ${resp.msg}'));
        setState(() {
          disableLoginButton = false;
        });
      }
      if (!mounted) return;
    } catch (e) {
      showBasicFlash(context, Text('登录异常: ${e.toString().split('\n')[0]}'));
      _log.e('登录异常: $e');
      setState(() {
        disableLoginButton = false;
      });
    }
    setState(() {
      disableLoginButton = false;
    });
  }

  /// 用户点击注册按钮后
  Future<void> onRegister() async {
    //未勾选用户协议 提示用户勾选 禁用注册按钮
    if (!isLicenseAccepted) {
      showBasicFlash(context, const Text('请勾选用户协议'));
      return;
    }
    setState(() {
      disableRegisterButton = true;
    });

    try {
      //mounted:当前页面是否被挂载
      if (!mounted) return;
      // 发起请求 获取token
      final api = GlobalObjects.apiProvider;
      final authInfo = AuthInfo(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      AuthResponse resp = await api.session.register(
        info: authInfo,
      );

      if (!mounted) return;
      _log.d('注册情况: $resp');
      // 注册成功
      if (resp.code == 2000) {
        // 保存token和userID
        GlobalObjects.storageProvider.user.jwtToken = resp.data?.token;
        GlobalObjects.storageProvider.user.uid = resp.data?.userId;
        // 进入首页
        showBasicFlash(context, const Text('注册成功'));
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const IndexPage(),
        ));
      }
      // 注册失败
      if (resp.code == 4000) {
        showBasicFlash(context, Text('注册失败: ${resp.msg}'));
        setState(() {
          disableRegisterButton = false;
        });
      }
      if (!mounted) return;
    } catch (e) {
      showBasicFlash(context, Text('注册异常: ${e.toString().split('\n')[0]}'));
      _log.e('注册异常: $e');
      setState(() {
        disableRegisterButton = false;
      });
    }
    setState(() {
      disableRegisterButton = false;
    });
  }

  static void onOpenUserLicense() {
    // launchInBrowser(Backend.license);
  }

  Widget buildTitleLine() {
    return Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        '欢迎登录',
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "用户名",
            hintText: "输入你的用户名",
            icon: Icon(Icons.person),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '输入你的密码',
                  icon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      }),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildUserLicenseCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: isLicenseAccepted,
          onChanged: (e) {
            setState(() => isLicenseAccepted = e!);
          },
        ),
        Expanded(
          child: Wrap(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '请确认您已阅读并同意'),
                    TextSpan(
                      text: '《用户协议》',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = onOpenUserLicense,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: disableLoginButton ? null : onLogin,
            child: const Text('登录进入'),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: disableRegisterButton ? null : onRegister,
            child: const Text('我要注册'),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const IndexPage(),
            )),
            child: const Text('游客入口'),
          ),
        ),
        TextButton(
          child: const Text(
            '遇到问题?',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () => launchInBrowser('https://github.com/VideoUtopia/utopia-back/issues'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: screenWidth / 3,
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title field.
                  buildTitleLine(),
                  const Padding(padding: EdgeInsets.only(top: 40.0)),
                  // Form field: username and password.
                  buildLoginForm(),
                  const SizedBox(height: 10),
                  // User license check box.
                  buildUserLicenseCheckbox(),
                  const SizedBox(height: 25),
                  // Login button.
                  buildLoginButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
