import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/util/flash.dart';
import 'package:utopia_front/util/launch.dart';

import '../../api/model/session.dart';
import '../../global/index.dart';

final _log = GlobalObjects.logger;

///登录方式选择页面
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
                  Navigator.pushNamed(context, '/login');
                }),
                buildLoginModeButton(Icons.accessibility, '游客入口', () {
                  Navigator.pushNamed(context, '/video');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
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
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      EasyLoading.showError('用户名或密码不能为空');
      return;
    }
    if (_usernameController.text.length < 6 || _passwordController.text.length < 6) {
      EasyLoading.showError('用户名或密码长度不能小于6');
      return;
    }

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
        // 请求用户信息
        await getUserInfo(context);
        showBasicFlash(context, const Text('登录成功'));
        // 进入首页
        Navigator.pushNamed(context, '/video');
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
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      EasyLoading.showError('用户名或密码不能为空');
      return;
    }
    if (_usernameController.text.length < 6 || _passwordController.text.length < 6) {
      EasyLoading.showError('用户名或密码长度不能小于6');
      return;
    }

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
        // 请求用户信息
        await getUserInfo(context);
        // 进入首页
        showBasicFlash(context, const Text('注册成功'));
        Navigator.of(context).pushNamed('/video');
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

  /// 用户点击用户协议后 跳转到用户协议页面
  static void onOpenUserLicense() {
    // launchInBrowser(Backend.license);
  }

  /// 构建标题
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

  ///构建登录表单
  Widget buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          autofocus: true,
          maxLength: 12,
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
                maxLength: 16,
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

  ///构建协议勾选框
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

  /// 构建登录按钮
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
            onPressed: () => Navigator.of(context).pushNamed('/video'),
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

///获取用户信息
Future<void> getUserInfo(BuildContext context) async {
  final api = GlobalObjects.apiProvider;
  final userInfo = await api.user.getUserInfo();
  if (userInfo.code == 2000) {
    GlobalObjects.storageProvider.user.avatar = userInfo.data!.avatar;
    GlobalObjects.storageProvider.user.nickname = userInfo.data!.nickname;
    GlobalObjects.storageProvider.user.username = userInfo.data!.username;
    GlobalObjects.storageProvider.user.uid = userInfo.data!.id;
    _log.i('getUserInfo: ${userInfo.data}');
  }
  if (userInfo.code == 4000) {
    showBasicFlash(context, Text('获取用户信息失败: ${userInfo.msg}'));
    _log.e('获取用户信息失败: ${userInfo.msg}');
    return;
  }
}
