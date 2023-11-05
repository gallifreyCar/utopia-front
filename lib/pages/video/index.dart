import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/video/singleVideoPage.dart';

import '../../api/model/video.dart';
import '../../util/flash.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

///全局日志打印
final _log = GlobalObjects.logger;

///切换页面
enum PageType {
  ///视频列表
  videoList,

  ///用户信息
  userInfo,
}

class _IndexPageState extends State<IndexPage> {
  //当前页面
  PageType pt = PageType.videoList;

  //视频信息
  List<VideoInfo> videoInfoList = [];

  //搜索的视频信息
  List<VideoInfo> searchVideoInfoList = [];

  //搜索
  bool showSearchVideoInfoList = false;

  //下一次请求的时间
  int nextTime = 0;

  // 没有更多
  bool noMore = false;

  // 创建一个 PageController
  final PageController _pageController = PageController();

  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 请求视频列表
    _onRefresh(1, 0);

    // 添加监听器来检测页面的变化
    _pageController.addListener(() {
      int? currentPageIndex = _pageController.page?.toInt();
      _log.i("当前页面索引：$currentPageIndex");
      if (currentPageIndex == videoInfoList.length - 1) {
        if (!noMore) {
          _log.i("加载下一页");
          _onRefresh(2, nextTime);
          return;
        }
        EasyLoading.showInfo("没有更多了");
        _log.i("没有更多了");
      }
    });
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: _buildSearchBar(),
      appBar: buildAppBar(),
      body: _buildVideoListPageView(),
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
          //个人信息 登录才显示
          Row(
            children: _buildPersonAppBarRow(),
          ),
          const SizedBox(width: 20),
          //视频分类 热门单独
          // 0.体育 1.动漫 2.游戏 3.音乐
          TextButton(
              onPressed: () {
                pt = PageType.videoList;
                _onRefresh(0, 0);
              },
              child: Text('热门', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(0, 0);
              },
              child: Text('推荐', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(1, 0);
              },
              child: Text('体育', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(2, 0);
              },
              child: Text('动漫', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(3, 0);
              },
              child: Text('游戏', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(4, 0);
              },
              child: Text('音乐', style: textStyle)),
          const SizedBox(width: 40),
        ]);
  }

  /// 构建视频PageView
  Widget _buildVideoListPageView() {
    var children = <Widget>[];

    for (var i = 0; i < videoInfoList.length; i++) {
      children.add(KeepAliveWrapper(
        child: VideoPlayerPage(
          text: "视频$i",
          videoInfo: videoInfoList[i],
        ),
      ));
    }
    return PageView(
      scrollDirection: Axis.vertical,
      children: children,
      controller: _pageController,
    );
  }

  ///构建个人中心AppBar里面的Row 如果没有登录则不显示
  List<Widget> _buildPersonAppBarRow() {
    String? avatarUrl = GlobalObjects.storageProvider.user.avatar ?? 'http://s351j97d8.hd-bkt.clouddn.com/d56e2a96.png';
    String nickname = GlobalObjects.storageProvider.user.nickname ?? '三九';

    if (GlobalObjects.storageProvider.user.jwtToken != null) {
      return [
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
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20),
              ),
            )
          ],
        ),
        const SizedBox(width: 5),
        TextButton.icon(
            onPressed: () {
              setState(() {
                Navigator.pushNamed(context, '/user');
                pt = PageType.userInfo;
              });
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: Text('个人', style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20))),
        //投稿
        TextButton.icon(
          onPressed: () {
            pt = PageType.userInfo;
          },
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: Text('投稿', style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20)),
        ),
        TextButton.icon(
            onPressed: () {
              GlobalObjects.storageProvider.user.jwtToken = null;
              // 退出登录 清空路由栈
              Navigator.pushNamedAndRemoveUntil(context, '/select', (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: Text('退出', style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 20))),
        SizedBox(width: 40),
      ];
    }
    return [Container()];
  }

  /// 请求视频方法
  Future<void> _onRefresh(int videoType, int myNextTime) async {
    setState(() {
      if (myNextTime == 0) {
        videoInfoList.clear();
      }
    });
    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = VideoRequest(lastTime: myNextTime, videoType: videoType);
    _log.i('请求视频列表', request.toJson());
    api.video.getVideoList(request).then((videoResponse) {
      EasyLoading.dismiss();
      if (videoResponse.code == 2000) {
        _log.i('请求成功');
        setState(() {
          //如果是切换分类，那么myNextTime就是0 清空列表
          if (myNextTime == 0) {
            videoInfoList.clear();
          }
          //没有更多视频了
          if (videoResponse.data!.videoInfo.isEmpty) {
            EasyLoading.showInfo('没有更多视频了');
            noMore = true;
            return;
          }
          // 如果是下拉刷新，那么myNextTime就是上一次请求的nextTime
          videoInfoList.addAll(videoResponse.data!.videoInfo);
          nextTime = videoResponse.data!.nextTime;
        });
      }
      if (videoResponse.code == 4000) {
        showBasicFlash(context, const Text("请求失败"), duration: const Duration(seconds: 2));
        _log.i('请求失败', videoResponse.msg);
      }
    }).catchError((e) {
      _log.e(e);
      EasyLoading.dismiss();
      EasyLoading.showError('服务器抽风了,请稍后再试');
      //停留5秒
      Future.delayed(const Duration(seconds: 5), () {
        EasyLoading.dismiss();
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginModeSelectorPage()));
      });
    });
  }

  /// 搜索框
  Widget _buildSearchBar() {
    return Stack(
      children: [
        Positioned(
          //appBar的高度
          top: 13,
          left: MediaQuery.of(context).size.width * 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //搜索框
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                margin: const EdgeInsets.only(left: 7, right: 7, top: 7, bottom: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (_searchController.text.isEmpty) {
                          EasyLoading.showInfo('请输入搜索内容');
                          return;
                        }

                        setState(() {
                          showSearchVideoInfoList = false;
                          _searchController.clear();
                          searchVideoInfoList.clear();
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) async {
                    _log.i('搜索', value);
                    await _searchVideoInfoList(value);
                    setState(() {
                      showSearchVideoInfoList = true;
                    });
                  },
                ),
              ),
              //搜索后 显示的视频列表
              SizedBox(height: 10),
              _buildSearchVideoInfoList(),
            ],
          ),
        ),
      ],
    );
  }

  /// 搜索后 显示的视频列表
  Widget _buildSearchVideoInfoList() {
    return Container(
      height: searchVideoInfoList.isEmpty ? 40 : MediaQuery.of(context).size.height * 0.6,
      width: searchVideoInfoList.isEmpty ? 400 : MediaQuery.of(context).size.width * 0.3,
      child: Offstage(
        offstage: !showSearchVideoInfoList,
        child: searchVideoInfoList.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Center(
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.info,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('没有搜到视频哦，换个关键词试试吧~', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ))
            : ListView.builder(
                itemCount: searchVideoInfoList.length,
                itemBuilder: (context, index) {
                  return _buildVideoItem(index);
                },
              ),
      ),
    );
  }

  /// 搜索后 显示的视频列表 视频列表项 封面+描述
  Widget _buildVideoItem(int index) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          //封面
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(searchVideoInfoList[index].coverUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  searchVideoInfoList[index].title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  searchVideoInfoList[index].describe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          //点赞数
          const SizedBox(width: 10),

          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined),
              const SizedBox(width: 10),
              Text(searchVideoInfoList[index].likeCount.toString()),
            ],
          ),
          // 收藏数
          const SizedBox(width: 10),
          Row(
            children: [
              const Icon(Icons.star_border),
              const SizedBox(width: 10),
              Text(searchVideoInfoList[index].favoriteCount.toString()),
            ],
          ),

          //播放按钮
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.play_circle_outline, color: Theme.of(context).primaryColor),
            onPressed: () {
              _log.i('播放视频', searchVideoInfoList[index].playUrl);
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayPage(videoInfoList[index])));
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  /// 搜索请求
  Future<void> _searchVideoInfoList(String searchContent) async {
    try {
      EasyLoading.show(status: '搜索中...');
      final api = GlobalObjects.apiProvider;
      final request = SearchVideoRequest(search: searchContent);
      final videoResponse = await api.video.searchVideoList(request);

      if (videoResponse.code == 2000) {
        _log.i('搜索视频成功', videoResponse.data);
        setState(() {
          EasyLoading.showSuccess('搜索视频成功');
          searchVideoInfoList = videoResponse.data?.videoInfo ?? [];
        });
      }
      if (videoResponse.code == 4000) {
        EasyLoading.showError(videoResponse.msg);
        _log.i('搜索视频失败', videoResponse.msg);
      }
    } catch (e) {
      _log.e('搜索视频异常', e);
    }
    EasyLoading.dismiss();
  }
}

//选择文件 获取token 上传视频
// Future<void> pickFile(BuildContext context) async {
//   //1.获取token
//   final api = GlobalObjects.apiProvider;
//   final qiniuToken = await api.upload.getKodoToken();
//   if (qiniuToken.code == 20000) {
//     _log.d('getKodoToken: ${qiniuToken.data!.token}');
//   }
//   if (qiniuToken.code == 4000) {
//     showBasicFlash(context, Text('获取七牛云存储token失败: ${qiniuToken.msg}'));
//     _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
//     return;
//   }
//   //2.选择文件上传
//
//   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//   uploadInput.multiple = false; // 是否允许选择多文件
//   uploadInput.draggable = true; // 是否允许拖拽上传
//   uploadInput.click(); // 打开文件选择对话框
//
//   uploadInput.onChange.listen((event) {
//     // 选择完成
//     html.File? file = uploadInput.files?.first;
//     _log.d('文件大小：${file?.size}');
//
//     if (file != null) {
//       html.FormData formData = html.FormData();
//       formData.appendBlob('file', file.slice(), file.name);
//       formData.append('token', qiniuToken.data!.token);
//       formData.append('key', 'tesljas35.png');
//       //"x:file_type": "COVER",
//       formData.append('x:file_type', "AVATAR");
//       formData.append('x:uid', '9');
//
//       // 上传文件到服务器
//       var request = html.HttpRequest();
//       request.open('POST', 'http://up-cn-east-2.qiniup.com');
//       request.send(formData);
//       request.onLoadEnd.listen((event) {
//         _log.d('上传结果：${request.responseText}');
//       });
//     }
//   });
// }
