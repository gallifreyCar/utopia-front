import 'dart:convert';

import 'package:card_actions/card_action_button.dart';
import 'package:card_actions/card_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:universal_html/html.dart' as html;
import 'package:utopia_front/api/model/user.dart';
import 'package:uuid/uuid.dart';

import '../../api/model/kodoFile.dart';
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
  //提示
  String tips = '';
  //是否显示更新信息表单
  bool showUpdateInfoForm = false;
  //昵称输入框控制器
  late TextEditingController nicknameController;
  //头像文件
  html.File? uploadAvatarFile;

  final _log = GlobalObjects.logger;
  List<UserInfoData> userInfoList = [];
  @override
  void initState() {
    super.initState();

    nicknameController = TextEditingController(text: nickname);
    getUserInfo();
    _requestFollowOrFansList(true);
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
        SizedBox(
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
        ],
        child: _buildUserInfoCard(index));
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
    if (userInfo.code == 4000) {
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
                          Text(
                            uploadAvatarFile == null ? '未选择头像' : '已选择头像：${uploadAvatarFile!.name}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            // uploadAvatarFile == null ? '' : '文件大小：${uploadAvatarFile!.size}字节',
                            //换算一下 MB 保留两位小数
                            uploadAvatarFile == null
                                ? ''
                                : '文件大小：${(uploadAvatarFile!.size / 1024 / 1024).toStringAsFixed(2)}MB',
                            style: const TextStyle(fontSize: 12),
                          ),
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
      ],
    );
  }

  ///清空更新表单信息
  void _clearUpdateInfoForm() {
    setState(() {
      nicknameController.clear();
      uploadAvatarFile = null;
    });
  }

  ///更新用户信息
  Future<void> updateUserInfo() async {
    EasyLoading.show(status: '信息更新中...', maskType: EasyLoadingMaskType.black);

    //-1. 如果昵称更改了，先修改昵称
    if (nicknameController.text != GlobalObjects.storageProvider.user.nickname) {
      try {
        final api = GlobalObjects.apiProvider;
        final updateNickname = await api.user.updateNickname(nicknameController.text);
        if (updateNickname.code == 2000) {
          _log.d('更新昵称成功');
        }
        if (updateNickname.code == 4000) {
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
    if (qiniuToken.code == 4000) {
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
          });
          _log.i(request.responseText);
          _log.i('封面上传成功');
          return;
        } else {
          EasyLoading.showError('更新信息失败');
          _log.e('封面上传失败: ${request.responseText}');
          return;
        }
      });
    } catch (e) {
      EasyLoading.showError('服务器异常，请稍后再试');
      _log.e('封面上传异常：$e');
    }
  }
}
