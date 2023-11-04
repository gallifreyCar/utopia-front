import 'package:flutter/material.dart';

import '../../global/index.dart';
import '../base.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  String avatarUrl = GlobalObjects.storageProvider.user.avatar ?? ''; // 头像
  String nickname = GlobalObjects.storageProvider.user.nickname ?? ''; // 昵称

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Container(
          color: Colors.black,
          width: WH.w(context),
          height: WH.h(context),
          // child: _buildUserInfoRow(),
        ),
      ),
    );
  }

  /// 构建AppBar
  AppBar buildAppBar() {
    Color secColor = Theme.of(context).secondaryHeaderColor;
    TextStyle textStyle = TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleLarge?.fontSize);
    return AppBar(actions: [
      Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              nickname,
              style: textStyle,
            ),
          )
        ],
      ),
      const SizedBox(width: 5),
      //投稿
      TextButton.icon(
        onPressed: () {},
        icon: Icon(Icons.upload_file, color: secColor),
        label: Text('投稿', style: textStyle),
      ),
      TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.video_camera_back, color: secColor),
          label: Text('返回', style: textStyle)),
    ]);
  }
}
