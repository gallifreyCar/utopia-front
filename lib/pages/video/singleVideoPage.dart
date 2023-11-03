// 单独的视频播放器页面
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../api/model/video.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key, required this.text, required this.videoInfo}) : super(key: key);
  final VideoInfo videoInfo;
  final String text;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool isLike = false; //是否点赞
  bool isFavorite = false; //是否收藏
  bool isFollow = false; //是否关注
  // 点赞数，收藏数，粉丝数
  int fansCount = 0;
  int followCount = 0;
  int videoCount = 0;

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
    // Play a [Media] or [Playlist].
    player.open(Media(widget.videoInfo.playUrl));
    // 是否点赞，收藏，关注
    isLike = widget.videoInfo.isLike;
    isFavorite = widget.videoInfo.isFavorite;
    isFollow = widget.videoInfo.isFollow;
    // 点赞数，收藏数，粉丝数，关注数
    fansCount = widget.videoInfo.author.fansCount;
    followCount = widget.videoInfo.author.followCount;
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
    print("build ${widget.text}");
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
          Column(
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
                      buildButton(context, buildTextAndNum("点赞", 120),
                          isLike ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_up_off_alt), like),
                      buildButton(context, const Text("收藏 124"),
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
          ),
          Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 6,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height / 3 +
                  MediaQuery.of(context).size.height / 10,
              //作者信息
              child: Column(
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
                            Text(nickname,
                                style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
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
                      buildTextAndNum("粉丝数", followCount, textStyle: const TextStyle(fontSize: 16, color: Colors.blue)),
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
              )),
        ],
      ),
    );
  }

  //点赞/取消点赞
  like() {
    setState(() {
      isLike = !isLike;
    });
  }

  //收藏/取消收藏
  collect() {
    setState(() {
      isFavorite = !isFavorite;
    });
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
