import 'package:card_actions/card_action_button.dart';
import 'package:card_actions/card_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/api/model/user.dart';

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
  //标题
  String bigTitle = '我的关注';
  IconData bigIcon = Icons.favorite;

  final _log = GlobalObjects.logger;
  List<UserInfoData> userInfoList = [];
  @override
  void initState() {
    super.initState();
    getUserInfo();
    _requestFollowOrFansList(true);
  }

  /// 构建AppBar
  AppBar buildAppBar() {
    Color secColor = Theme.of(context).secondaryHeaderColor;
    TextStyle textStyle = TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleLarge?.fontSize);
    return AppBar(backgroundColor: Theme.of(context).primaryColor, actions: [
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

  /// 大标题
  Widget buildTitle(IconData icon, String title) {
    return Container(
      width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
      height: 100,
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(color: Colors.white, fontSize: 32)),
          ),
        ],
      ),
    );
  }

  /// 构建第二部分 内容
  Widget _buildContentColumn() {
    return Column(
      children: [
        buildTitle(bigIcon, bigTitle),
        Container(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          height: WH.personHeight(context) - 100,
          child: userInfoList.isEmpty
              ? const Center(
                  child: Text(
                  '暂无更多相关人员哦，关注其他人吧，或者发作品，赚取更多粉丝吧！',
                  style: TextStyle(fontSize: 20),
                ))
              : ListView.builder(
                  itemExtent: WH.personWith(context) / 5,
                  itemCount: userInfoList.length ~/ 4 + 1,
                  itemBuilder: (context, index) {
                    return Container(
                        color: Colors.white,
                        width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
                        height: WH.personHeight(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCardActions(index * 4),
                            _buildCardActions(index * 4 + 1),
                            _buildCardActions(index * 4 + 2),
                            _buildCardActions(index * 4 + 3),
                          ],
                        ));
                  }),
        ),
      ],
    );
  }

  /// 构建个人信息弹出框
  Widget _buildCardActions(int index) {
    if (index >= userInfoList.length) {
      return Container();
    }
    return CardActions(
        child: _buildUserInfoCard(index),
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
  Widget _buildUserInfoCard(int index) {
    if (index >= userInfoList.length) {
      return Container();
    }

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
            backgroundImage: NetworkImage(userInfoList[index].avatar),
            backgroundColor: Colors.white,
          ),
          //用户名和昵称
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              userInfoList[index].nickname,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Theme.of(context).primaryColor),
            ),
          ),
          _buildIconTextRow('粉丝数: ${userInfoList[index].fansCount}', Icons.person),
          //投稿数
          _buildIconTextRow('投稿数: ${userInfoList[index].videoCount}', Icons.upload_file),
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
                _buildButton('我的关注', Icons.favorite, () {
                  setState(() {
                    bigTitle = '我的关注';
                    bigIcon = Icons.favorite;
                  });
                  _requestFollowOrFansList(true);
                }),
                //我的粉丝
                _buildButton('我的粉丝', Icons.face_rounded, () {
                  setState(() {
                    bigTitle = '我的粉丝';
                    bigIcon = Icons.face_rounded;
                  });
                  _requestFollowOrFansList(false);
                }),
                //我的收藏
                _buildButton('我的收藏', Icons.star, () {}),
                //我的投稿
                _buildButton('我的投稿', Icons.upload_file, () {}),
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

  /// 请求获取粉丝或关注列表
  Future<void> _requestFollowOrFansList(bool isFollow) async {
    try {
      EasyLoading.show(status: '资源加载中...');
      UserListResponse _userListResponse;
      final api = GlobalObjects.apiProvider.user;
      if (isFollow) {
        _userListResponse = await api.getFollowList();
      } else {
        _userListResponse = await api.getFansList();
      }

      if (_userListResponse.code == 2000) {
        _log.i('获取粉丝或关注列表成功');
        setState(() {
          userInfoList = _userListResponse.userList!;
        });
      }
      if (_userListResponse.code == 4000) {
        _log.i('获取粉丝或关注列表失败');
        EasyLoading.showError('获取粉丝或关注列表失败:${_userListResponse.msg}');
      }
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('服务器抽风了，请稍后再试');
      _log.e('获取粉丝或关注列表失败:$e');
    }
  }

  /// 获取用户信息
  Future<void> getUserInfo() async {
    final api = GlobalObjects.apiProvider;
    final userInfo = await api.user.getUserInfo();
    if (userInfo.code == 2000) {
      GlobalObjects.storageProvider.user.avatar = userInfo.data!.avatar;
      GlobalObjects.storageProvider.user.nickname = userInfo.data!.nickname;
      GlobalObjects.storageProvider.user.username = userInfo.data!.username;
      GlobalObjects.storageProvider.user.uid = userInfo.data!.id;
      GlobalObjects.storageProvider.user.fansCount = userInfo.data!.fansCount;
      GlobalObjects.storageProvider.user.followCount = userInfo.data!.followCount;
      GlobalObjects.storageProvider.user.videoCount = userInfo.data!.videoCount;
      _log.i('getUserInfo: ${userInfo.data}');
    }
    if (userInfo.code == 4000) {
      EasyLoading.showError('获取用户信息失败: ${userInfo.msg}');
      _log.e('获取用户信息失败: ${userInfo.msg}');
      return;
    }
  }
}
