import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/video/singleVideoPage.dart';

import '../../api/model/base.dart';
import '../../api/model/video.dart';
import '../../custom_widgets/search.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({
    Key? key,
    required this.mode,
    required this.userId,
    required this.videoId,
  }) : super(key: key);

  // mode 带参数的路由跳转 默认0：热门视频 1：某个up的视频（uid获取） 2：某个视频（video_id获取）
  final int mode;
  final int userId;
  final int videoId;

  @override
  State<IndexPage> createState() => _IndexPageState();
}

///全局日志打印
final _log = GlobalObjects.logger;

class _IndexPageState extends State<IndexPage> {
  ///视频信息
  List<VideoInfo> videoInfoList = [];

  ///搜索的GlobalKey
  GlobalKey<SearchWindowState> searchKey = GlobalKey();

  ///模式 0：热门视频 1：某个up的视频（uid获取） 2：某个视频（video_id获取） 3：收藏的视频
  int mode = 0;

  ///下一次请求的时间
  int nextTime = 0;

  /// 没有更多
  bool noMore = false;

  /// 创建一个 PageController
  final PageController _pageController = PageController();

  ///是否只看某人
  bool onlySeeOne = false;
  int currentIndex = 0;

  ///热门视频参数
  double score = 0.0;
  int version = 0;

  ///分类视频参数
  int categoryId = 0;

  ///键盘控制器
  final FocusNode _focusNode = FocusNode();

  /// 播放器在进入页面时播放 退出页面暂停
  late List<GlobalKey<VideoPlayerPageState>> globalKeyList;

  @override
  void initState() {
    super.initState();
    // 初始化
    mode = widget.mode;

    switch (mode) {
      case 0:
        _log.i("热门视频");
        _onRefreshHot(0, 0);
        break;
      case 1:
        _log.i("某个人的所有视频");
        _getVideoListByUid(widget.userId, 0);
        break;
      case 2:
        _log.i("某个视频");
        _getOneVideo(widget.videoId);
        break;
      case 3:
        _log.i("分类视频");
        _onRefreshHot(0, 0);
        break;
      case 4:
        _log.i("推荐视频");
        _onRefreshBestMatch(0);
        if (videoInfoList.length == 0) {
          _onRefreshHot(0, 0);
        }
    }

    // 添加监听器来检测页面的变化
    _pageController.addListener(() {
      int? currentPageIndex = _pageController.page?.toInt();
      _log.i("当前页面索引：$currentPageIndex");
      currentIndex = currentPageIndex ?? 0;
      // 判断是否滑动到了最后一页
      if (currentPageIndex == videoInfoList.length - 1) {
        if (!noMore) {
          _log.i("加载下一页");
          switch (mode) {
            // 热门视频
            case 0:
              _onRefreshHot(version, score);
              break;
            // 某个人的所有视频
            case 1:
              _getVideoListByUid(widget.userId, nextTime); //
              break;
            // 分类视频
            case 3:
              _onRefresh(categoryId, nextTime);
              break;
            // 推荐视频
            case 4:
              _onRefreshBestMatch(nextTime);
              if (videoInfoList.isEmpty) {
                _onRefreshHot(0, 0);
              }
          }
          return;
        }
        EasyLoading.showInfo("没有更多了");
        _log.i("没有更多了");
      }
      // 播放当前视频
      globalKeyList[currentPageIndex ?? 0].currentState?.startPlay();

      // 切换视频时，暂停上一个视频 （如果有的话，下滑）
      // 暂停下一个视频（如果有的话，上滑）
      if (globalKeyList.length > 1) {
        if (currentPageIndex != null && currentPageIndex > 0) {
          globalKeyList[currentPageIndex - 1].currentState?.pausePlay();
        }
        if (currentPageIndex != null && currentPageIndex < globalKeyList.length - 1) {
          globalKeyList[currentPageIndex + 1].currentState?.pausePlay();
        }

        // 同步作者信息
        if (currentPageIndex != null) {
          globalKeyList[currentPageIndex]
              .currentState
              ?.syncAuth(videoInfoList[currentPageIndex].isFollow, videoInfoList[currentPageIndex].author.fansCount);
          _log.i(
              "同步作者信息:${videoInfoList[currentPageIndex].author.fansCount},${videoInfoList[currentPageIndex].isFollow}");
        }
      }
    });
  }

  /// 回调函数，用于相步作者的信息
  void _callback(int userId, bool isFollow, int fansCount) {
    for (var element in videoInfoList) {
      if (element.author.id == userId) {
        element.author.fansCount = fansCount;
        element.isFollow = isFollow;
      }
    }
    _log.i("回调函数执行完毕");
  }

  @override
  void dispose() {
    // 在组件销毁时，记得释放 PageController
    _pageController.dispose();
    // 释放 EasyLoading
    EasyLoading.dismiss();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SearchWindow(key: searchKey),
      appBar: buildAppBar(),
      body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            }
            if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            }
          },
          child: _buildVideoListPageView()),
    );
  }

  /// 构建AppBar
  AppBar buildAppBar() {
    TextStyle textStyle = Theme.of(context).primaryTextTheme.titleLarge!;
    return AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Utopia',
          style: textStyle,
        ),
        actions: [
          Container(width: MediaQuery.of(context).size.width * 0.28),
          const SizedBox(
            width: 20,
          ),
          //个人信息 登录才显示
          _buildPersonAppBarRow(),

          //视频分类 热门单独
          // 0.体育 1.动漫 2.游戏 3.音乐
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Center(
              child: Row(
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          mode = 0;
                          version = 0;
                          score = 0;
                          _onRefreshHot(version, score);
                        });
                      },
                      child: Text('热门', style: textStyle)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          mode = 3;
                          categoryId = 0;
                          nextTime = 0;
                          _onRefresh(categoryId, nextTime);
                        });
                      },
                      child: Text('体育', style: textStyle)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          mode = 3;
                          categoryId = 1;
                          nextTime = 0;
                          _onRefresh(categoryId, nextTime);
                        });
                      },
                      child: Text('动漫', style: textStyle)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          mode = 3;
                          categoryId = 2;
                          nextTime = 0;
                          _onRefresh(categoryId, nextTime);
                        });
                      },
                      child: Text('游戏', style: textStyle)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          mode = 3;
                          categoryId = 3;
                          nextTime = 0;
                          _onRefresh(categoryId, nextTime);
                        });
                      },
                      child: Text('音乐', style: textStyle)),
                ],
              ),
            ),
          )
        ]);
  }

  /// 构建视频PageView
  Widget _buildVideoListPageView() {
    var children = <Widget>[];
    globalKeyList = <GlobalKey<VideoPlayerPageState>>[];

    for (var i = 0; i < videoInfoList.length; i++) {
      globalKeyList.add(GlobalKey<VideoPlayerPageState>());
      children.add(KeepAliveWrapper(
        child: VideoPlayerPage(
          key: globalKeyList[i],
          text: "视频$i",
          videoInfo: videoInfoList[i],
          callback: _callback,
        ),
      ));
    }
    return PageView(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      children: children,
    );
  }

  ///构建个人中心AppBar里面的Row 如果没有登录则不显示
  Widget _buildPersonAppBarRow() {
    String? avatarUrl = GlobalObjects.storageProvider.user.avatar ?? 'http://s351j97d8.hd-bkt.clouddn.com/d56e2a96.png';
    String nickname = GlobalObjects.storageProvider.user.nickname ?? '三九';
    TextStyle textStyle = Theme.of(context).primaryTextTheme.titleLarge!;
    if (GlobalObjects.storageProvider.user.jwtToken != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.052,
                  child: Text(
                    nickname,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).primaryTextTheme.titleMedium!,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 5),

          //个人
          TextButton.icon(
              onPressed: () {
                globalKeyList[_pageController.page!.round()].currentState!.pausePlay();
                Navigator.pushNamed(context, '/user');
              },
              icon: const Icon(Icons.person, color: Colors.white),
              label: Text('个人', style: textStyle)),
          //推荐
          TextButton.icon(
              onPressed: () async {
                mode = 4;
                nextTime = 0;
                int code = await _onRefreshBestMatch(nextTime);
                _log.i('code: $code');
                if (code == 2001) {
                  EasyLoading.showToast('你最近活跃度不够，先去看看视频吧，再来看看推荐吧');
                  Future.delayed(const Duration(seconds: 2), () {
                    EasyLoading.dismiss();
                    mode = 0;
                    _onRefreshHot(0, 0);
                  });
                }
              },
              icon: const Icon(Icons.lightbulb, color: Colors.white),
              label: Text('推荐', style: textStyle)),
          //投稿
          TextButton.icon(
            onPressed: () {
              searchKey.currentState!.showContributeFormFunc();
            },
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: Text('投稿', style: textStyle),
          ),
          //退出
          TextButton.icon(
              onPressed: () {
                GlobalObjects.storageProvider.user.jwtToken = null;
                // 退出登录 清空路由栈
                Navigator.pushNamedAndRemoveUntil(context, '/select', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text('退出', style: textStyle)),
          const SizedBox(width: 40),
        ]),
      );
    }
    return SizedBox(width: MediaQuery.of(context).size.width * 0.3);
  }

  /// 获取分类视频
  Future<void> _onRefresh(int videoType, int lastTime) async {
    setState(() {
      if (lastTime == 0) {
        videoInfoList.clear();
      }
    });

    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = VideoRequest(lastTime: lastTime, videoType: videoType);
    _log.i('请求视频列表', request.toJson());

    try {
      VideoResponse resp = await api.video.getVideoList(request);

      if (resp.code == successCode) {
        _log.i('请求成功');
        setState(() {
          //如果是切换分类，那么myNextTime就是0 清空列表
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
          EasyLoading.dismiss();
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showInfo('请求失败');
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }
  }

  ///请求一个视频信息的方法
  Future<void> _getOneVideo(int video) async {
    EasyLoading.show(status: '数据加载中...');
    try {
      final api = GlobalObjects.apiProvider;
      final request = VideoByVideoIdRequest(videoId: video);
      _log.i('请求视频信息', request.toJson());
      final resp = await api.video.getVideoByVideoId(request);
      if (resp.code == successCode) {
        _log.i('请求成功');
        setState(() {
          videoInfoList.add(resp.videoInfo!);
        });
        EasyLoading.dismiss();
      }
      if (resp.code == errorCode) {
        EasyLoading.showInfo('请求失败');
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }
  }

  ///通过用户id获取用户的视频列表的方法
  Future<void> _getVideoListByUid(int uid, int lastTime) async {
    setState(() {
      if (lastTime == 0) {
        videoInfoList.clear();
      }
    });

    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = SomeoneVideoRequest(lastTime: lastTime, userId: uid);
    _log.i('请求视频列表', request.toJson());

    try {
      VideoResponse resp = await api.video.getVideoListByUserId(request);

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
          EasyLoading.dismiss();
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showError('请求失败：${resp.msg}');
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }
  }

  /// 获取热门视频
  Future<void> _onRefreshHot(int myVersion, double myScore) async {
    setState(() {
      if (myScore == 0 && myVersion == 0) {
        videoInfoList.clear();
      }
    });

    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = HotVideoRequest(version: myVersion, score: myScore);
    _log.i('请求视频列表', request.toJson());

    try {
      HotVideoResponse resp = await api.video.getHotVideoList(request);

      if (resp.code == successCode) {
        _log.i('请求成功');
        setState(() {
          //没有更多视频了
          if (resp.data.hotVideo.isEmpty) {
            EasyLoading.showInfo('没有更多视频了');
            noMore = true;
            return;
          }
          // 如果是下拉刷新，
          // 那么score就是上一次请求的score ,version就是上一次请求的version
          videoInfoList.addAll(resp.data.hotVideo);
          score = resp.data.score;
          version = resp.data.version;
          EasyLoading.dismiss();
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showError('请求失败：${resp.msg}');
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }
  }

  /// 获取推荐视频
  Future<int> _onRefreshBestMatch(int lastTime) async {
    int code = 2000;

    setState(() {
      if (lastTime == 0) {
        videoInfoList.clear();
      }
    });

    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    _log.i('请求视频列表', lastTime);

    try {
      VideoResponse resp = await api.video.getRecommendVideoList(lastTime);

      if (resp.code == successCode) {
        _log.i('请求成功');
        setState(() {
          //如果是切换分类，那么myNextTime就是0 清空列表
          if (lastTime == 0) {
            videoInfoList.clear();
          }
          //没有更多视频了
          if (resp.data!.videoInfo.isEmpty) {
            EasyLoading.showInfo('没有更多视频了');
            code = 2001;
            noMore = true;
            return;
          }
          // 如果是下拉刷新，那么myNextTime就是上一次请求的nextTime
          videoInfoList.addAll(resp.data!.videoInfo);
          nextTime = resp.data!.nextTime;
          EasyLoading.dismiss();
        });
      }
      if (resp.code == errorCode) {
        EasyLoading.showError('请求失败: ${resp.msg}');
        code = errorCode;
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }

    return code;
  }
}
