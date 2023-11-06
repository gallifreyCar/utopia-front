// 单独的视频播放器页面

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:utopia_front/global/index.dart';

import '../../api/model/base.dart';
import '../../api/model/interact.dart';
import '../../api/model/video.dart';
import '../../custom_widgets/chat_widow.dart';
import '../base.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key, required this.text, required this.videoInfo}) : super(key: key);
  final VideoInfo videoInfo;
  final String text;

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  final _log = GlobalObjects.logger;

  int videoId = 0; //视频id
  // 评论列表
  List<CommentInfo> commentList = [];

  // 点赞，收藏，关注
  bool isLike = false; //是否点赞
  bool isFavorite = false; //是否收藏
  bool isFollow = false; //是否关注
  // 点赞数，收藏数，粉丝数 ，作品数 评论数
  int likeCount = 120;
  int favoriteCount = 240;
  int fansCount = 0;
  int videoCount = 0;
  int commentCount = 0;

  // 按钮是否可用
  bool isLikeButtonEnable = true;
  bool isFavoriteButtonEnable = true;
  bool isFollowButtonEnable = true;
  bool isSendComment = false;

  // 作者个人信息
  String avatar = "";
  String nickname = "";
  String username = "";
  int uerId = 0;

  // 视频描述
  String describe = "";
  // 发表时间
  String publishTime = "";

  //评论
  int? lastTime = 0; //最后一条评论的时间
  bool isLoading = true; //是否正在加载
  bool noMore = true; //是否没有更多评论

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
    likeCount = widget.videoInfo.likeCount;
    favoriteCount = widget.videoInfo.favoriteCount;
    commentCount = widget.videoInfo.commentCount;

    // 个人信息
    avatar = widget.videoInfo.author.avatar; //头像
    nickname = widget.videoInfo.author.nickname; //昵称
    uerId = widget.videoInfo.author.id; //用户id

    // 视频描述
    describe = widget.videoInfo.describe;
    publishTime = widget.videoInfo.createdAt.substring(0, 10);
    // 获取视频评论
    _getCommentList();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// 构建视频播放器部件
  Widget _buildVideoPlayer() {
    double likeWidth = MediaQuery.of(context).size.width * 0.3;

    return Stack(children: [
      Column(
        //靠左对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //视频播放器
          SizedBox(
            width: WH.playerWith(context),
            height: WH.playerHeight(context),
            child: Video(controller: controller),
          ),
          //点赞，收藏，评论，分享
          SizedBox(
            width: likeWidth,
            height: WH.h(context) - WH.playerHeight(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                //点赞，收藏，评论，分享
                _buildButton(context, _buildTextAndNum("点赞", likeCount),
                    isLike ? const Icon(Icons.thumb_up) : const Icon(Icons.thumb_up_off_alt), like),
                _buildButton(context, _buildTextAndNum("收藏", favoriteCount),
                    isFavorite ? const Icon(Icons.star) : const Icon(Icons.star_border), collect),
                _buildButton(context, _buildTextAndNum("评论", commentCount), const Icon(Icons.comment), () {}),
                //发布时间
                _buildButton(context, Text("$publishTime"), const Icon(Icons.date_range), () {}),
              ],
            ),
          ),
        ],
      ),
      //  评论窗口
      Positioned(
        right: 0,
        bottom: 0,
        child: SizedBox(
          width: WH.playerWith(context) - likeWidth,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
              // mainAxisSize: MainAxisSize.min, //垂直方向最小化处理
              crossAxisAlignment: CrossAxisAlignment.center, //水平方向居中对齐
              mainAxisAlignment: MainAxisAlignment.end, // 从下往上排列
              children: [
                ChatWindow(
                  sendMessage: sendMsg,
                ),
              ]),
        ),
      ),
    ]);
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
                  Text(nickname,
                      style:
                          TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: follow,
                    icon: isFollow ? const Icon(Icons.check) : const Icon(Icons.add),
                    label: isFollow ? const Text("已关注") : const Text("关注"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed("/video", arguments: {"userId": uerId, "videoId": videoId, "mode": 1});
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      label: const Text("只看ta")),
                ],
              ),
            ],
          ),
        ),

        //关注，粉丝
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextAndNum("作品数", videoCount,
                textStyle: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
            _buildTextAndNum("粉丝数", fansCount,
                textStyle: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
          ],
        ),

        // 视频标题和描述
        Container(
          margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          width: WH.w(context) - WH.playerWith(context) - 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            //设置四周圆角 角度
            border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoInfo.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  describe,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  //文字从左到右
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        //评论  滚动
        isLoading
            ? _buildCommentLoading()
            : Expanded(
                child: commentList.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("评论区空空如也，快来发表评论吧~",
                                style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
                          ),
                        ],
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Divider(color: Theme.of(context).primaryColorDark),
                        ),
                        itemCount: commentList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(commentList[index].avatar),
                            ),
                            title: Text(
                              commentList[index].nickname,
                              style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.titleSmall?.fontSize, color: Colors.black),
                            ),
                            subtitle: Text(
                              commentList[index].content,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                  color: Theme.of(context).primaryColor),
                            ),
                          );
                        },
                      ),
              ),
        Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
                onPressed: () {
                  if (noMore) {
                    EasyLoading.showToast("没有更多评论了");
                    return;
                  }
                  _getCommentList();
                },
                child: const Text("刷新评论"))),
      ],
    );
  }

  ///  api
  final api = GlobalObjects.apiProvider;

  ///follow 关注/取消关注
  follow() async {
    //自己不能关注自己
    if (uerId == GlobalObjects.storageProvider.user.uid) {
      EasyLoading.showToast("不能关注自己");
      return;
    }

    //判断是否登录 没有登录则弹出登录框 并返回
    if (!isLogin()) {
      showLoginDialog();
      return;
    }
    if (!isFollowButtonEnable) {
      EasyLoading.showToast("操作过于频繁");
      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.dismiss();
      });
      return;
    }
    try {
      await followUp();
    } catch (e) {
      _log.e("请求失败", e);
    }
    isFollowButtonEnable = true;
  }

  ///点赞/取消点赞
  like() async {
    //判断是否登录 没有登录则弹出登录框 并返回
    if (!isLogin()) {
      showLoginDialog();
      return;
    }
    //防止重复点击
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
    //判断是否登录 没有登录则弹出登录框 并返回
    if (!isLogin()) {
      showLoginDialog();
      return;
    }
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
    int actionType = isLike ? 2 : 1;
    final request = VideoLikeAndFavoriteRequest(videoId: videoId, actionType: actionType);
    _log.i("点赞/取消点赞请求：", request.toJson());

    final response = await api.interact.like(request);
    if (response.code == successCode) {
      setState(() {
        //操作成功
        isLike = !isLike;
        //点赞数+1
        likeCount = isLike ? likeCount + 1 : likeCount - 1;
      });
    }
    if (response.code == errorCode) {
      EasyLoading.showError(response.msg);
      _log.i("点赞/取消点赞失败：${response.msg}");
    }
  }

  ///收藏
  Future collectVideo() async {
    isFavoriteButtonEnable = false;
    int actionType = isFavorite ? 2 : 1;
    final request = VideoLikeAndFavoriteRequest(videoId: videoId, actionType: actionType);
    _log.i("收藏/取消收藏请求：", request.toJson());
    final response = await api.interact.favorite(request);
    if (response.code == successCode) {
      setState(() {
        //操作成功
        isFavorite = !isFavorite;
        //收藏数+1
        favoriteCount = isFavorite ? favoriteCount + 1 : favoriteCount - 1;
      });
    }
    if (response.code == errorCode) {
      EasyLoading.showError(response.msg);
      _log.i("收藏/取消收藏失败：${response.msg}");
    }
  }

  ///关注
  Future followUp() async {
    isFollowButtonEnable = false;
    int actionType = isFollow ? 2 : 1;
    final request = FollowRequest(actionType: actionType, toUserId: uerId);
    _log.i("关注/取消关注请求：", request.toJson());
    final response = await api.interact.follow(request);
    if (response.code == successCode) {
      setState(() {
        //操作成功
        isFollow = !isFollow;
        //自己的关注数+1 -1
        GlobalObjects.storageProvider.user.followCount = isFollow
            ? GlobalObjects.storageProvider.user.followCount! + 1
            : GlobalObjects.storageProvider.user.followCount! - 1;
        //对方的粉丝数+1 -1
        fansCount = isFollow ? fansCount + 1 : fansCount - 1;
      });
    }
    if (response.code == errorCode) {
      EasyLoading.showError(response.msg);
      _log.i("关注/取消关注失败：${response.msg}");
    }
  }

  /// 登录判断
  bool isLogin() {
    return GlobalObjects.storageProvider.user.jwtToken != null;
  }

  /// 未登录时的弹窗
  void showLoginDialog() {
    TextStyle style = TextStyle(fontSize: 16, color: Theme.of(context).primaryColor);
    TextStyle style2 = TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold);
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
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text("我要登录"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _log.i("build ${widget.text}");
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: _buildMainRow(),
    );
  }

  /// buildMainRow
  Widget _buildMainRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //第一部分是构建视频播放器部件列 包括：视频 点赞 收藏 评论
        Container(
            color: Colors.white, width: WH.playerWith(context), height: WH.h(context), child: _buildVideoPlayer()),
        //第二部分是构建作者信息部件列 包括：头像 昵称 粉丝 关注 作品
        Container(
            color: Colors.white,
            width: WH.w(context) - WH.playerWith(context),
            height: WH.h(context),
            child: _buildAuthInfoColum())
      ],
    );
  }

  /// 发送评论
  sendMsg(String content) async {
    //判断是否登录
    if (!isLogin()) {
      showLoginDialog();
      return;
    }
    // 判断是否发送中
    if (isSendComment) {
      EasyLoading.showError('评论正在发送中，请稍等');
      return;
    }
    //判断评论内容是否超过200字
    if (content.length > 200) {
      EasyLoading.showError('评论内容不能超过200字');
      return;
    }
    //发送评论
    setState(() {
      isSendComment = true;
    });
    _log.i('发送评论', content);
    try {
      final request = PostCommentRequest(content: content, videoId: videoId);
      api.interact.postComment(request).then((resp) {
        if (resp.code == 2000) {
          // EasyLoading.showSuccess('评论成功');
          _log.i('评论成功');
          //评论增加一条
          setState(() {
            commentCount = commentCount + 1;
            commentList.add(CommentInfo(
              nickname: GlobalObjects.storageProvider.user.nickname ?? '',
              avatar: GlobalObjects.storageProvider.user.avatar ?? '',
              content: content,
            ));
          });
        }
        if (resp.code == errorCode) {
          EasyLoading.showError(resp.msg);
          _log.i('评论失败', resp.msg);
        }
      });
    } catch (e) {
      _log.e('评论异常', e);
    }

    setState(() {
      isSendComment = false;
    });
  }

  /// 评论加载动画组件
  Widget _buildCommentLoading() {
    return Column(
      children: [
        const SizedBox(height: 30),
        SizedBox(
          width: WH.w(context),
          height: 150,
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '评论加载中...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 获取评论列表
  Future<void> _getCommentList() async {
    try {
      setState(() {
        isLoading = true;
      });
      _log.i('获取评论列表');
      // EasyLoading.show(status: '评论加载中...'); 单独在评论列表页面显示
      final request = CommentRequest(videoId: videoId, lastTime: lastTime);
      _log.i('获取评论列表参数', request.toJson());
      api.interact.getComment(request).then((resp) {
        if (resp.code == 2000) {
          // EasyLoading.showSuccess('获取评论列表成功');
          _log.i('获取评论列表成功${resp.data!.commentInfo.length}');
          setState(() {
            commentList.addAll(resp.data!.commentInfo);
            lastTime = resp.data?.nextTime;
            if (lastTime == -1) {
              noMore = true;
            } else {
              noMore = false;
            }
          });

          setState(() {
            isLoading = false;
          });
        }
        if (resp.code == errorCode) {
          // EasyLoading.showError(resp.msg);
          _log.i('获取评论列表失败', resp.msg);
          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (e) {
      _log.e('获取评论列表异常', e);
      setState(() {
        isLoading = false;
      });
    }
  }
}

/// 构建同样按钮
Widget _buildButton(BuildContext context, Text text, Icon icon, Function() onPressed) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: TextButton.icon(onPressed: onPressed, icon: icon, label: text),
  );
}

/// 构建不同样按钮
Text _buildTextAndNum(String text, int howMany, {TextStyle? textStyle}) {
  if (textStyle != null) {
    return Text("$text: $howMany", style: textStyle);
  }
  return Text("$text: $howMany");
}
