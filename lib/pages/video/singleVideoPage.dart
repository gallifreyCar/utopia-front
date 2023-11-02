// 单独的视频播放器页面
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key, required this.text, required this.playUrl}) : super(key: key);
  final String playUrl;
  final String text;

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool isLike = false; //是否点赞
  bool isCollect = false; //是否收藏

  late final player = Player();

  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(widget.playUrl));
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
                      buildButton(context, Text("点赞 12000"),
                          isLike ? Icon(Icons.thumb_up) : Icon(Icons.thumb_up_off_alt), like),
                      buildButton(
                          context, Text("收藏 124"), isCollect ? Icon(Icons.star) : Icon(Icons.star_border), collect),
                      buildButton(context, Text("评论 120"), Icon(Icons.comment), () {}),
                      buildButton(context, Text("分享 120"), Icon(Icons.share), () {}),

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
              //头像
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 30),
                        ),
                        Column(
                          children: [
                            const Text("用户名"),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text("关注"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  //关注，粉丝
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text("关注 120"),
                      Text("粉丝 120"),
                    ],
                  ),

                  //简介
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "这是一段个人描述：的就是两个煎熬了就管理监督机构第三个了解了代购",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
      isCollect = !isCollect;
    });
  }
}

Widget buildButton(BuildContext context, Text text, Icon icon, Function() onPressed) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextButton.icon(onPressed: onPressed, icon: icon, label: text),
  );
}
