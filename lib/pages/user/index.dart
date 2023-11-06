import 'dart:convert';

import 'package:card_actions/card_action_button.dart';
import 'package:card_actions/card_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:universal_html/html.dart' as html;
import 'package:utopia_front/api/model/user.dart';
import 'package:utopia_front/api/model/video.dart';
import 'package:uuid/uuid.dart';

import '../../api/model/base.dart';
import '../../api/model/interact.dart';
import '../../api/model/kodoFile.dart';
import '../../global/index.dart';
import '../base.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  final uid = GlobalObjects.storageProvider.user.uid;

  //标题
  String bigTitle = '我的关注';
  IconData bigIcon = Icons.favorite;

  //提示
  String tips = '';

  //是否显示更新信息表单
  bool showUpdateInfoForm = false;

  //昵称输入框控制器
  late TextEditingController nicknameController;

  //头像文件
  html.File? uploadAvatarFile;

  //全局日志
  final _log = GlobalObjects.logger;
  final api = GlobalObjects.apiProvider;

  //用户信息列表
  List<UserInfoData> userInfoList = [];

  //视频信息列表
  List<VideoInfo> videoInfoList = [];

  //没有更多视频
  bool noMore = false;
  int nextTime = 0;

  // cardMode
  int cardMode = 0;

  // 控制器
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    nicknameController = TextEditingController(text: GlobalObjects.storageProvider.user.nickname);
    getUserInfo();
    _requestFollowOrFansList(true);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!noMore) {
          switch (cardMode) {
            case 2:
              onRefreshFavoriteVideo(uid!, nextTime);
              break;
            case 3:
              onRefreshPersonVideo(uid!, nextTime);
              break;
          }
        }
      }
    });
  }

  ///销毁
  @override
  void dispose() {
    super.dispose();
    nicknameController.dispose();
  }

  /// 构建AppBar
  AppBar buildAppBar() {
    Color secColor = Theme.of(context).secondaryHeaderColor;
    TextStyle textStyle = TextStyle(color: secColor, fontSize: Theme.of(context).primaryTextTheme.titleLarge?.fontSize);
    return AppBar(backgroundColor: Theme.of(context).primaryColor, actions: [
      const SizedBox(width: 5),
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
      floatingActionButton: _buildUpdateInfoForm(),
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
        SizedBox(
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
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 32)),
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
        const SizedBox(height: 20),
        _buildContentColumnChild(),
      ],
    );
  }

  /// 构建四种卡片
  Widget _buildContentColumnChild() {
    switch (cardMode) {
      case 1:
      case 0:
        return SizedBox(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          height: WH.personHeight(context) - 120,
          child: userInfoList.isEmpty
              ? Center(
                  child: Text(
                  tips,
                  style: const TextStyle(fontSize: 20),
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
                            _buildFollowAndFansCardActions(index * 4),
                            _buildFollowAndFansCardActions(index * 4 + 1),
                            _buildFollowAndFansCardActions(index * 4 + 2),
                            _buildFollowAndFansCardActions(index * 4 + 3),
                          ],
                        ));
                  }),
        );
      case 2:
      case 3:
        return SizedBox(
          width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
          height: WH.personHeight(context) - 120,
          child: videoInfoList.isEmpty
              ? Center(
                  child: Text(
                  tips,
                  style: const TextStyle(fontSize: 20),
                ))
              : ListView.builder(
                  controller: scrollController,
                  itemExtent: WH.personWith(context) / 5,
                  itemCount: videoInfoList.length ~/ 4 + 1,
                  itemBuilder: (context, index) {
                    return Container(
                        color: Colors.white,
                        width: WH.personWith(context) - 0.15 * MediaQuery.of(context).size.width,
                        height: WH.personHeight(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFavouriteAndMyWorkCardActions(index * 4),
                            _buildFavouriteAndMyWorkCardActions(index * 4 + 1),
                            _buildFavouriteAndMyWorkCardActions(index * 4 + 2),
                            _buildFavouriteAndMyWorkCardActions(index * 4 + 3),
                          ],
                        ));
                  }),
        );
    }
    return Container();
  }

  /// 构建ListView中卡片内容  mode: 0.我的关注 1.我的粉丝 2.我的收藏 3，我的投稿
  Widget _buildFollowAndFansCardActions(int index) {
    if (index >= userInfoList.length) {
      return Container();
    }

    return CardActions(
        width: WH.personWith(context) / 6,
        height: WH.personWith(context) / 6,
        backgroundColor: Theme.of(context).primaryColor,
        borderRadius: 20,
        actions: [
          //取消关注
          cardMode == 0
              ? CardActionButton(
                  icon: Icon(
                    Icons.no_accounts_sharp,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  label: "取消关注",
                  onPress: () {
                    followUp(userInfoList[index].id);
                  })
              : CardActionButton(
                  icon: Icon(
                    Icons.handshake_outlined,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  label: "互粉",
                  onPress: () {
                    followUp(userInfoList[index].id);
                  }),
          // 查看作品
          CardActionButton(
              icon: Icon(
                Icons.video_collection,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              label: "查看作品",
              onPress: () {
                setState(() {
                  cardMode = 3;
                  bigTitle = "${userInfoList[index].nickname}的作品";
                  onRefreshPersonVideo(userInfoList[index].id, 0);
                });
              }),
        ],
        child: _buildUserInfoCard(index));
  }

  /// 构建ListView中卡片内容  mode: 0.我的关注 1.我的粉丝 2.我的收藏 3，我的投稿
  Widget _buildFavouriteAndMyWorkCardActions(int index) {
    if (index >= videoInfoList.length) {
      return Container();
    }

    return CardActions(
        width: WH.personWith(context) / 6,
        height: WH.personWith(context) / 6,
        backgroundColor: Theme.of(context).primaryColor,
        borderRadius: 20,
        actions: [
          // 查看作品
          CardActionButton(
              icon: Icon(
                Icons.video_collection,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              label: "查看作品",
              onPress: () {
                Navigator.of(context).pushNamed('/video', arguments: {"mode": 2, "videoId": videoInfoList[index].id});
              }),
        ],
        child: _buildVideoInfoCard(index));
  }

  Widget _buildVideoInfoCard(index) {
    if (index >= videoInfoList.length) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]),
      width: WH.personWith(context) / 6,
      height: WH.personWith(context) / 6,
      child: Column(
        children: [
          //封面
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: WH.personWith(context) / 7,
              height: WH.personWith(context) / 8 - 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(videoInfoList[index].coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          //标题
          _buildIconTextRow('作品: ${videoInfoList[index].title}', Icons.video_camera_back),
          //作者
          _buildIconTextRow('作者: ${videoInfoList[index].author.nickname}', Icons.person),
          //发表时间
          //2023-10-27T17:54:03.55+08:00 截取前10位
          _buildIconTextRow('发表时间: ${videoInfoList[index].createdAt.substring(0, 10)}', Icons.date_range,
              diyPadding: 4),
        ],
      ),
    );
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      width: WH.personWith(context) / 6,
      height: WH.personWith(context) / 6,
      child: Column(
        children: [
          const SizedBox(height: 20),
          //头像
          CircleAvatar(
            radius: 30,
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
                        //更新个人信息按钮
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cached_outlined),
                            onPressed: () {
                              setState(() {
                                showUpdateInfoForm = true;
                              });
                            },
                            label: const Text('更新'),
                          ),
                        ),
                        //用户名和昵称
                        _buildUsernameAndNicknameColumn(),
                        _buildIconTextRow('粉丝数: ${GlobalObjects.storageProvider.user.fansCount}', Icons.person,
                            diyFontSize: 12),
                        //关注数
                        _buildIconTextRow('关注数: ${GlobalObjects.storageProvider.user.followCount}', Icons.person_add,
                            diyFontSize: 12),
                        //投稿数
                        _buildIconTextRow('投稿数: ${GlobalObjects.storageProvider.user.videoCount}', Icons.upload_file,
                            diyFontSize: 12),
                      ],
                    )),
                const SizedBox(height: 20),
                //我的关注
                _buildButton('我的关注', Icons.favorite, () {
                  setState(() {
                    bigTitle = '我的关注';
                    bigIcon = Icons.favorite;
                    cardMode = 0;
                  });
                  _requestFollowOrFansList(true);
                }),
                //我的粉丝
                _buildButton('我的粉丝', Icons.face_rounded, () {
                  setState(() {
                    bigTitle = '我的粉丝';
                    bigIcon = Icons.face_rounded;
                    cardMode = 1;
                  });
                  _requestFollowOrFansList(false);
                }),
                //我的收藏
                _buildButton('我的收藏', Icons.star, () {
                  onRefreshFavoriteVideo(GlobalObjects.storageProvider.user.uid!, 0);
                  setState(() {
                    bigTitle = '我的收藏';
                    bigIcon = Icons.star;
                    cardMode = 2;
                    noMore = false;
                  });
                }),
                //我的投稿
                _buildButton('我的投稿', Icons.upload_file, () {
                  setState(() {
                    bigTitle = '我的投稿';
                    bigIcon = Icons.upload_file;
                    cardMode = 3;
                    noMore = false;
                  });
                  onRefreshPersonVideo(GlobalObjects.storageProvider.user.uid!, 0);
                }),
              ],
            ),
          ),
          //头像
          Positioned(
            left: 0.075 * MediaQuery.of(context).size.width - 40,
            top: 20,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(GlobalObjects.storageProvider.user.avatar!),
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
                "昵称：${GlobalObjects.storageProvider.user.nickname}",
                style: textStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建IconTextRow
  Widget _buildIconTextRow(String text, IconData icon,
      {TextStyle? diyTextStyle, double? diyFontSize, double? diyPadding}) {
    Color secColor = Theme.of(context).primaryColor;
    TextStyle textStyle = TextStyle(
      color: secColor,
      fontSize: diyFontSize ?? Theme.of(context).primaryTextTheme.titleMedium?.fontSize,
      overflow: TextOverflow.ellipsis,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: diyPadding != null ? EdgeInsets.all(diyPadding) : const EdgeInsets.all(8.0),
          child: Icon(icon, color: secColor),
        ),
        Text(text, style: diyTextStyle ?? textStyle),
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
          userInfoList.isEmpty ? tips = '暂无更多相关人员哦，关注其他人吧，或者发作品，赚取更多粉丝吧！' : tips = '';
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
    if (userInfo.code == errorCode) {
      EasyLoading.showError('获取用户信息失败: ${userInfo.msg}');
      _log.e('获取用户信息失败: ${userInfo.msg}');
      return;
    }
  }

  ///更新信息表单
  Widget _buildUpdateInfoForm() {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.45,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Offstage(
              offstage: !showUpdateInfoForm,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // 增加圆角
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      // 设置阴影
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '更新信息',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //昵称
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: TextFormField(
                              controller: nicknameController,
                              decoration: const InputDecoration(
                                labelText: '昵称',
                                hintText: '请输入昵称',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入昵称';
                                }
                                if (value.length > 12) {
                                  return '昵称长度不能超过12个字符';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          //头像
                          ElevatedButton(
                            onPressed: () {
                              //选择文件上传
                              html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                              uploadInput.multiple = false; // 是否允许选择多文件
                              uploadInput.draggable = true; // 是否允许拖拽上传
                              uploadInput.click(); // 打开文件选择对话框

                              uploadInput.onChange.listen((event) {
                                // 选择完成 判断类型
                                if (uploadInput.files?.first.type != 'image/jpeg' &&
                                    uploadInput.files?.first.type != 'image/png') {
                                  EasyLoading.showError('请选择图片文件（jpg/png）');
                                  return;
                                }
                                setState(() {
                                  // 选择完成
                                  uploadAvatarFile = uploadInput.files?.first;
                                  _log.i('文件大小：${uploadAvatarFile?.size}');
                                });
                              });
                            },
                            child: const Text('选择头像'),
                          ),

                          const SizedBox(height: 20),
                          //新头像文件信息

                          _buildFileInfoText(uploadAvatarFile, '新头像'),

                          const SizedBox(height: 20),

                          //提交
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _log.i('提交更新信息表单');
                                  updateUserInfo();
                                },
                                child: const Text('提交'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    _clearUpdateInfoForm();
                                  },
                                  child: const Text('清空')),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                  onPressed: () {
                                    _clearUpdateInfoForm();

                                    setState(() {
                                      showUpdateInfoForm = false;
                                    });
                                  },
                                  child: const Text('返回')),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  cardMode = 0;
                  bigTitle = '我的关注';
                  onRefreshFavoriteVideo(GlobalObjects.storageProvider.user.uid!, 0);
                });
              },
              child: const Icon(Icons.refresh)),
        ),
      ],
    );
  }

  ///清空更新表单信息
  void _clearUpdateInfoForm() {
    setState(() {
      uploadAvatarFile = null;
    });
  }

  ///更新用户信息方法
  Future<void> updateUserInfo() async {
    //-3. 如果都没有更改，直接返回
    if (nicknameController.text == GlobalObjects.storageProvider.user.nickname && uploadAvatarFile == null) {
      EasyLoading.showInfo('没有更改任何信息');
      return;
    }
    EasyLoading.show(status: '信息更新中...', maskType: EasyLoadingMaskType.black);
    //-2. 如果昵称更改了，先修改昵称
    if (nicknameController.text != GlobalObjects.storageProvider.user.nickname && nicknameController.text.isNotEmpty) {
      try {
        final api = GlobalObjects.apiProvider;
        final updateNickname = await api.user.updateNickname(nicknameController.text);
        if (updateNickname.code == 2000) {
          _log.d('更新昵称成功');
          setState(() {
            GlobalObjects.storageProvider.user.nickname = nicknameController.text;
          });
        }
        if (updateNickname.code == errorCode) {
          EasyLoading.showError('更新昵称失败，请稍后再试');
          _log.e('更新昵称失败: ${updateNickname.msg}');
          return;
        }
      } catch (e) {
        _log.e('更新昵称异常: $e');
        EasyLoading.dismiss();
        return;
      }
    }

    //-1. 如果没有选则头像文件，直接返回
    if (uploadAvatarFile == null) {
      EasyLoading.showSuccess('信息更新成功');
      _log.d('信息更新成功');
      return;
    }

    //0.校验表单
    if (uploadAvatarFile != null && uploadAvatarFile!.size > 1024 * 1024 * 10) {
      EasyLoading.showError('头像文件大小不能超过10M');
      return;
    }

    //1.获取token
    final api = GlobalObjects.apiProvider;
    final qiniuToken = await api.upload.getKodoToken();
    if (qiniuToken.code == 2000) {
      _log.d('getKodoToken: ${qiniuToken.data!.token}');
    }
    if (qiniuToken.code == errorCode) {
      EasyLoading.showError('存储服务异常，请稍后再试');
      _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
      EasyLoading.dismiss();
      return;
    }
    // 获取文件扩展名
    String fileExtension = 'jpg'; // 默认扩展名
    if (uploadAvatarFile != null) {
      fileExtension = uploadAvatarFile!.name.substring(uploadAvatarFile!.name.lastIndexOf('.') + 1);
    }

    // 2.填充表单
    html.FormData formData = html.FormData();
    formData.appendBlob('file', uploadAvatarFile!, uploadAvatarFile!.name);
    formData.append('token', qiniuToken.data!.token);
    // 生成uuid,截取11位 拼接文件后缀作为key
    final uuid = const Uuid().v4().substring(0, 11);
    formData.append('key', '$uuid.$fileExtension');
    formData.append('x:file_type', "AVATAR");
    formData.append('x:uid', GlobalObjects.storageProvider.user.uid.toString());
    // 上传
    try {
      var request = html.HttpRequest();
      request.open('POST', GlobalObjects.qiniuKodoUrl);
      request.send(formData);
      request.onLoad.listen((event) {
        UploadFileCallbackResponse response = UploadFileCallbackResponse.fromJson(json.decode(request.responseText!));
        if (response.code == 2000) {
          EasyLoading.showSuccess('更新信息成功');
          setState(() {
            //更新用户信息
            GlobalObjects.storageProvider.user.avatar = response.data!.imageUrl;
            // _clearUpdateInfoForm();
            // showUpdateInfoForm = false;
          });
          _log.i(request.responseText);
          _log.i('头像上传成功');
          return;
        } else {
          EasyLoading.showError('更新信息失败');
          _log.e('头像上传失败: ${request.responseText}');
          // _clearUpdateInfoForm();
          // showUpdateInfoForm = false;
          return;
        }
      });
    } catch (e) {
      EasyLoading.showError('服务器异常，请稍后再试');
      // _clearUpdateInfoForm();
      // showUpdateInfoForm = false;
      _log.e('头像上传异常：$e');
    }
  }

  /// 上传文件信息
  Widget _buildFileInfoText(html.File? uploadVideoFile, String? title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uploadVideoFile == null ? '$title未选择文件' : '$title文件名：${uploadVideoFile.name}',
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          //换算一下 MB 保留两位小数
          uploadVideoFile == null ? '' : '$title文件大小：${(uploadVideoFile.size / 1024 / 1024).toStringAsFixed(2)}MB',
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 获取个人视频列表
  Future<void> onRefreshPersonVideo(int uid, int lastTime) async {
    setState(() {
      tips = '';
      if (lastTime == 0) {
        videoInfoList.clear();
      }
    });
    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = SomeoneVideoRequest(lastTime: lastTime, userId: uid);
    _log.i('请求视频列表', request.toJson());
    api.video.getVideoListByUserId(request).then((resp) {
      EasyLoading.dismiss();
      if (resp.code == successCode) {
        _log.i('请求成功');
        setState(() {
          //如果是重新，那么myNextTime就是0 清空列表
          if (lastTime == 0) {
            videoInfoList.clear();
          }
          //没有更多视频了
          if (resp.data!.videoInfo.isEmpty) {
            EasyLoading.showInfo('没有更多视频了');
            noMore = true;
            return;
          }
          // 如果是下拉刷新，那么myNextTime就是上一次请求的nextTime
          videoInfoList.addAll(resp.data!.videoInfo);
          nextTime = resp.data!.nextTime;
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showError('请求失败');
        _log.i('请求失败', resp.msg);
      }
    }).catchError((e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    });
  }

  /// 获取收藏视频列表
  Future<void> onRefreshFavoriteVideo(int uid, int lastTime) async {
    setState(() {
      tips = '';
      if (lastTime == 0) {
        videoInfoList.clear();
      }
    });
    EasyLoading.show(status: '数据加载中...');

    final request = SomeoneVideoRequest(lastTime: lastTime, userId: uid);
    _log.i('请求视频列表', request.toJson());
    api.video.getFavoriteVideoList(request).then((resp) {
      EasyLoading.dismiss();
      if (resp.code == successCode) {
        tips = '你还没有投稿任何视频哦~,试着创造属于你的视频吧！';
        _log.i('请求成功');
        setState(() {
          //如果是重新，那么myNextTime就是0 清空列表
          if (lastTime == 0) {
            videoInfoList.clear();
          }
          //没有更多视频了
          if (resp.data!.videoInfo.isEmpty) {
            EasyLoading.showInfo('没有更多视频了');
            noMore = true;
            return;
          }
          // 如果是下拉刷新，那么myNextTime就是上一次请求的nextTime
          videoInfoList.addAll(resp.data!.videoInfo);
          nextTime = resp.data!.nextTime;
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showError('请求失败');
        _log.i('请求失败', resp.msg);
      }
    }).catchError((e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    });
  }

  ///关注   关注的人只有取消关注  粉丝列表只可以关注
  Future followUp(int uerId) async {
    int actionType = 0;

    switch (cardMode) {
      case 0:
        actionType = 2;
        break;
      case 1:
        actionType = 1;
        break;
      default:
        return;
    }

    final request = FollowRequest(actionType: actionType, toUserId: uerId);
    _log.i("关注/取消关注请求：", request.toJson());
    final response = await api.interact.follow(request);
    if (response.code == successCode) {
      _log.i("关注/取消关注成功：${response.msg}");
      EasyLoading.showSuccess("操作成功");
      setState(() {
        if (cardMode == 0) {
          GlobalObjects.storageProvider.user.followCount = GlobalObjects.storageProvider.user.followCount! - 1;
          setState(() {
            userInfoList.removeWhere((element) => element.id == uerId);
          });
        }

        if (cardMode == 1) {
          GlobalObjects.storageProvider.user.fansCount = GlobalObjects.storageProvider.user.fansCount! + 1;
        }
      });
    }
    if (response.code == errorCode) {
      EasyLoading.showError(response.msg);
      _log.i("关注/取消关注失败：${response.msg}");
    }
  }
}
