// 单独的视频播放器页面
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:utopia_front/global/index.dart';

import '../../api/model/video.dart';
import '../login/index.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key, required this.text, required this.videoInfo}) : super(key: key);
  final VideoInfo videoInfo;
  final String text;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final _log = GlobalObjects.logger;

  int videoId = 0; //视频id
  // 点赞，收藏，关注
  bool isLike = false; //是否点赞
  bool isFavorite = false; //是否收藏
  bool isFollow = false; //是否关注
  // 点赞数，收藏数，粉丝数 ，作品数
  int likeCount = 120;
  int favoriteCount = 240;
  int fansCount = 0;
  int videoCount = 0;

  // 按钮是否可用
  bool isLikeButtonEnable = true;
  bool isFavoriteButtonEnable = true;
  bool isFollowButtonEnable = true;

  // 作者个人信息
  String avatar = "";
  String nickname = "";
  String username = "";

  // 视频描述
  String describe = "";

  //视频播放器
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // 视频id
    videoId = widget.videoInfo.id;
    // 初始化视频播放器
    player.open(Media(widget.videoInfo.playUrl));
    // 是否点赞，收藏，关注
    isLike = widget.videoInfo.isLike;
    isFavorite = widget.videoInfo.isFavorite;
    isFollow = widget.videoInfo.isFollow;
    // 点赞数，收藏数，粉丝数，关注数
    fansCount = widget.videoInfo.author.fansCount;
    videoCount = widget.videoInfo.author.videoCount;
    // 个人信息
    avatar = widget.videoInfo.author.avatar; //头像
    nickname = widget.videoInfo.author.nickname; //昵称

    // 视频描述
    describe = widget.videoInfo.describe;
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log.i("build ${widget.text}");
    return Container(
      color: Colors.lightBlueAccent,
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).size.height / 3 +
          MediaQuery.of(context).size.height / 10,
      width: MediaQuery.of(context).size.width / 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          //中间的首页
          _buildVideoPlayer(),
          Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 6,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height / 3 +
                  MediaQuery.of(context).size.height / 10,
              //作者信息列
              child: _buildAuthInfoColum()),
        ],
      ),
    );
  }

  /// 构建视频播放器部件
  Widget _buildVideoPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //视频播放器
        SizedBox(
          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 3,
          // Use [Video] widget to display video output.
          child: Video(controller: controller),
        ),
        //点赞，收藏，评论，分享
        SizedBox(
          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.height / 10,
          // Use [Video] widget to display video output.
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                //点赞，收藏，评论，分享
                buildButton(context, buildTextAndNum("点赞", likeCount),
                    isLike ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_up_off_alt), like),
                buildButton(context, buildTextAndNum("收藏", favoriteCount),
                    isFavorite ? const Icon(Icons.star) : const Icon(Icons.star_border), collect),
                buildButton(context, const Text("评论 120"), const Icon(Icons.comment), () {}),
                buildButton(context, const Text("分享 120"), const Icon(Icons.share), () {}),

                //评论输入框 和 发送按钮
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    hintText: "评论",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("发送"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建作者信息列
  Widget _buildAuthInfoColum() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 10),
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(avatar),
                  ),
                  const SizedBox(height: 4),
                  Text(nickname, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("关注"),
              ),
            ],
          ),
        ),

        //关注，粉丝
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildTextAndNum("作品数", videoCount, textStyle: const TextStyle(fontSize: 16, color: Colors.blue)),
            buildTextAndNum("粉丝数", fansCount, textStyle: const TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ),

        //简介
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
          child: Text(
            describe,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            //文字从左到右
            textDirection: TextDirection.ltr,
          ),
        ),
        //评论 100条 滚动
        Expanded(
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return const ListTile(
                leading: CircleAvatar(
                  radius: 15,
                  child: Icon(Icons.person, size: 15),
                ),
                title: Text("用户名"),
                subtitle: Text("评论内容"),
              );
            },
          ),
        ),
      ],
    );
  }

  ///  api
  final api = GlobalObjects.apiProvider;
  int successCode = 2000;
  int failCode = 4000;

  /// todo 点赞收藏逻辑可以抽象出来
  ///点赞/取消点赞
  like() async {
    isLogin();
    if (!isLikeButtonEnable) {
      EasyLoading.showToast("操作过于频繁");
      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.dismiss();
      });
      return;
    }
    try {
      await likeVideo();
    } catch (e) {
      _log.e("请求失败", e);
    }
    isLikeButtonEnable = true;
  }

  ///收藏/取消收藏
  collect() async {
    isLogin();
    if (!isFavoriteButtonEnable) {
      EasyLoading.showToast("操作过于频繁");
      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.dismiss();
      });
      return;
    }
    try {
      await collectVideo();
    } catch (e) {
      _log.e("请求失败", e);
    }

    Future.delayed(const Duration(seconds: 1), () {
      isFavoriteButtonEnable = true;
    });
  }

  ///点赞
  Future likeVideo() async {
    isLikeButtonEnable = false;
    int actionType = isLike ? 1 : 2;
    final request = VideoLikeAndFavoriteRequest(videoId: videoId, actionType: actionType);
    _log.i("点赞/取消点赞请求：", request.toJson());

    final response = await api.video.like(request);
    if (response.code == successCode) {
      setState(() {
        //操作成功
        isLike = !isLike;
        //点赞数+1
        likeCount = isLike ? likeCount + 1 : likeCount - 1;
      });
    }
    if (response.code == failCode) {
      EasyLoading.showError(response.msg);
      _log.i("点赞/取消点赞失败：${response.msg}");
    }
  }

  ///收藏
  Future collectVideo() async {
    isFavoriteButtonEnable = false;
    int actionType = isFavorite ? 1 : 2;
    final request = VideoLikeAndFavoriteRequest(videoId: videoId, actionType: actionType);
    _log.i("收藏/取消收藏请求：", request.toJson());
    final response = await api.video.favorite(request);
    if (response.code == successCode) {
      setState(() {
        //操作成功
        isFavorite = !isFavorite;
        //收藏数+1
        favoriteCount = isFavorite ? favoriteCount + 1 : favoriteCount - 1;
      });
    }
    if (response.code == failCode) {
      EasyLoading.showError(response.msg);
      _log.i("收藏/取消收藏失败：${response.msg}");
    }
  }

  //关注
  Future followUp() async {}

  /// 登录判断

  void isLogin() {
    if (GlobalObjects.storageProvider.user.jwtToken == null) {
      showLoginDialog();
    }
    return;
  }

  /// 未登录时的弹窗
  void showLoginDialog() {
    TextStyle style = const TextStyle(fontSize: 16, color: Colors.blue);
    TextStyle style2 = const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("小提示", style: style2),
          content: Text("游客身份无法进行此操作操作哦😊~", style: style),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("下次一定"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const LoginPage(mode: LoginMode.account)));
                },
                child: const Text("我要登录"),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget buildButton(BuildContext context, Text text, Icon icon, Function() onPressed) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextButton.icon(onPressed: onPressed, icon: icon, label: text),
  );
}

Text buildTextAndNum(String text, int howMany, {TextStyle? textStyle}) {
  if (textStyle != null) {
    return Text("$text: $howMany", style: textStyle);
  }
  return Text("$text: $howMany");
}
