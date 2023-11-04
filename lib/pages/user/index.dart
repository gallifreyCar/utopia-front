import 'package:card_actions/card_action_button.dart';
import 'package:card_actions/card_actions.dart';
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
  String nickname = GlobalObjects.storageProvider.user.nickname ?? '';

  /// 构建AppBar
  AppBar buildAppBar() {
    Color secColor = Theme.of(context).secondaryHeaderColor;
    TextStyle textStyle = TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleLarge?.fontSize);
    return AppBar(actions: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: buildAppBar(),
      body: Center(
        child: Container(
          color: Colors.white,
          width: WH.personWith(context),
          height: WH.personHeight(context),
          child: _buildMainRow(),
        ),
      ),
    );
  }

  /// 构建用户信息Row  第一部分显示个人信息和按钮 第二部分显示内容
  Widget _buildMainRow() {
    return Row(
      children: [
        _buildUserInfoAndButton(),
        Container(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          child: _buildContentColumn(),
        )
      ],
    );
  }

  /// 构建第二部分 内容
  Widget _buildContentColumn() {
    return Column(
      children: [
        Container(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          height: 100,
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.remove_red_eye_sharp, color: Colors.white, size: 32),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('我的关注', style: TextStyle(color: Colors.white, fontSize: 32)),
              ),
            ],
          ),
        ),
        Container(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          height: WH.personHeight(context) - 100,
          child: ListView.builder(
              itemExtent: WH.personWith(context) / 5,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                    color: Colors.white,
                    width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
                    height: WH.personHeight(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCardActions(),
                        _buildCardActions(),
                        _buildCardActions(),
                        _buildCardActions(),
                      ],
                    ));
              }),
        ),
      ],
    );
  }

  /// 构建个人信息弹出框
  Widget _buildCardActions() {
    return CardActions(
        child: _buildUserInfoCard(),
        width: WH.personWith(context) / 6,
        height: WH.personWith(context) / 6,
        backgroundColor: Theme.of(context).primaryColor,
        borderRadius: 20,
        actions: [
          //取消关注
          CardActionButton(
              icon: Icon(
                Icons.no_accounts_sharp,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              label: "取消关注",
              onPress: () {}),
          // 查看作品
          CardActionButton(
              icon: Icon(
                Icons.video_collection,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              label: "查看作品",
              onPress: () {}),
        ]);
  }

  /// 构建个人信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(20),
      ),
      width: WH.personWith(context) / 6,
      height: WH.personWith(context) / 6,
      child: Column(
        children: [
          SizedBox(height: 20),
          //头像
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.white,
          ),
          //用户名和昵称
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "nickname",
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Theme.of(context).primaryColor),
            ),
          ),
          _buildIconTextRow('粉丝数: ${GlobalObjects.storageProvider.user.fansCount}', Icons.person),
          //投稿数
          _buildIconTextRow('投稿数: ${GlobalObjects.storageProvider.user.videoCount}', Icons.upload_file),
        ],
      ),
    );
  }

  /// UserInfoAndButton 第一部分显示个人信息和按钮
  Widget _buildUserInfoAndButton() {
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      width: 0.15 * MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(
            width: 0.15 * MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Container(
                    width: 0.12 * MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        //修改头像
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('修改头像'),
                          ),
                        ),
                        //用户名和昵称
                        _buildUsernameAndNicknameColumn(),
                        _buildIconTextRow('粉丝数: ${GlobalObjects.storageProvider.user.fansCount}', Icons.person),
                        //关注数
                        _buildIconTextRow('关注数: ${GlobalObjects.storageProvider.user.followCount}', Icons.person_add),
                        //投稿数
                        _buildIconTextRow('投稿数: ${GlobalObjects.storageProvider.user.videoCount}', Icons.upload_file),
                      ],
                    )),
                const SizedBox(height: 20),
                //我的关注
                _buildButton('我的关注', Icons.remove_red_eye_outlined, () {}),
                //我的粉丝
                _buildButton('我的粉丝', Icons.face_rounded, () {}),
                //我的收藏
                _buildButton('我的收藏', Icons.star, () {}),
                //我的投稿
                _buildButton('我的投稿', Icons.upload_file, () {}),
                //我的消息
                _buildButton('我的消息', Icons.message, () {}),
              ],
            ),
          ),
          //头像
          Positioned(
            left: 0.075 * MediaQuery.of(context).size.width - 40,
            top: 20,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(avatarUrl),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户名和昵称Column
  Widget _buildUsernameAndNicknameColumn() {
    Color secColor = Theme.of(context).primaryColor;
    TextStyle textStyle =
        TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleMedium?.fontSize);
    return Column(
      children: [
        //用户名
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "用户名：${GlobalObjects.storageProvider.user.username}",
            style: textStyle,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "昵称：$nickname",
                style: textStyle,
              ),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: Theme.of(context).primaryColor)),
          ],
        ),
      ],
    );
  }

  /// 构建IconTextRow
  Widget _buildIconTextRow(String text, IconData icon) {
    Color secColor = Theme.of(context).primaryColor;
    TextStyle textStyle =
        TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleMedium?.fontSize);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: secColor),
        ),
        Text(text, style: textStyle),
      ],
    );
  }

  /// 构建按钮
  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: onPressed,
        label: Text(text),
      ),
    );
  }
}
