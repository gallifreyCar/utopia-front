import 'dart:convert';

import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:universal_html/html.dart' as html;
import 'package:utopia_front/api/model/kodoFile.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/video/singleVideoPage.dart';
import 'package:uuid/uuid.dart';

import '../../api/model/video.dart';
import '../../util/flash.dart';

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

  ///投稿表单变量
  //标题控制器
  final titleController = TextEditingController();

  //描述控制器
  final describeController = TextEditingController();

  // 视频分类选择
  int selectedValue = 0;

  // 投稿表单是否显示
  bool showContributeForm = false;
  String uploadVideoUrl = "";
  String uploadVideoCoverUrl = "";
  html.File? uploadVideoFile;
  html.File? uploadVideoCoverFile;
  String callbackVideoCoverUrl = "none";

  //是否只看某人
  bool onlySeeOne = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    switch (widget.mode) {
      case 0:
        _log.i("热门视频");
        _onRefresh(0, 0);
        break;
      case 1:
        _log.i("某个up的视频");
        _getVideoListByUid(widget.userId, 0);
        break;
      case 2:
        _log.i("某个视频");
        _getOneVideo(widget.videoId);
        break;
    }

    // 添加监听器来检测页面的变化
    _pageController.addListener(() {
      int? currentPageIndex = _pageController.page?.toInt();
      _log.i("当前页面索引：$currentPageIndex");
      currentIndex = currentPageIndex ?? 0;
      if (currentPageIndex == videoInfoList.length - 1) {
        if (!noMore) {
          _log.i("加载下一页");
          switch (widget.mode) {
            case 0:
              _onRefresh(0, nextTime);
              break;
            case 1:
              _getVideoListByUid(widget.userId, nextTime);
              break;
            case 2:
              _onRefresh(0, nextTime);
              break;
          }
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
                ],
              ),
            ),
          )
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

          TextButton.icon(
              onPressed: () {
                setState(() {
                  Navigator.pushNamed(context, '/user');
                });
              },
              icon: const Icon(Icons.person, color: Colors.white),
              label: Text('个人', style: textStyle)),
          //投稿
          TextButton.icon(
            onPressed: () {
              setState(() {
                showContributeForm = !showContributeForm;
              });
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
      EasyLoading.showError('服务器抽风了,请稍后再试');
    });
  }

  ///请求一个视频信息
  Future<void> _getOneVideo(int video) async {
    EasyLoading.show(status: '数据加载中...');
    try {
      final api = GlobalObjects.apiProvider;
      final request = VideoByVideoIdRequest(videoId: video);
      _log.i('请求视频信息', request.toJson());
      final resp = await api.video.getVideoByVideoId(request);
      if (resp.code == 2000) {
        EasyLoading.dismiss();
        _log.i('请求成功');
        setState(() {
          videoInfoList.add(resp.videoInfo!);
        });
      }
      if (resp.code == 4000) {
        EasyLoading.showInfo('请求失败');
        _log.i('请求失败', resp.msg);
      }
    } catch (e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    }
  }

  ///通过用户id获取用户的视频列表
  Future<void> _getVideoListByUid(int uid, int myNextTime) async {
    setState(() {
      if (myNextTime == 0) {
        videoInfoList.clear();
      }
    });
    EasyLoading.show(status: '数据加载中...');
    final api = GlobalObjects.apiProvider;
    final request = SomeoneVideoRequest(lastTime: myNextTime, userId: uid);
    _log.i('请求视频列表', request.toJson());
    api.video.getVideoListByUserId(request).then((resp) {
      EasyLoading.dismiss();
      if (resp.code == 2000) {
        _log.i('请求成功');
        setState(() {
          //如果是重新，那么myNextTime就是0 清空列表
          if (myNextTime == 0) {
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
      if (resp.code == 4000) {
        showBasicFlash(context, const Text("请求失败"), duration: const Duration(seconds: 2));
        _log.i('请求失败', resp.msg);
      }
    }).catchError((e) {
      _log.e(e);
      EasyLoading.showError('服务器抽风了,请稍后再试');
    });
  }

  /// 搜索框
  Widget _buildSearchBar() {
    return Stack(
      children: [
        Positioned(
          left: 0.1 * MediaQuery.of(context).size.width,
          top: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //搜索框
              Container(
                width: MediaQuery.of(context).size.width * 0.28,
                margin: const EdgeInsets.only(left: 8, right: 8),
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
                    if (_searchController.text.isEmpty) {
                      EasyLoading.showInfo('请输入搜索内容');
                      return;
                    }
                    _log.i('搜索', value);
                    await _searchVideoInfoList(value);
                    setState(() {
                      showSearchVideoInfoList = true;
                    });
                  },
                ),
              ),
              //搜索后 显示的视频列表
              const SizedBox(height: 10),
              _buildSearchVideoInfoList(),
            ],
          ),
        ),
        Positioned(bottom: 20, left: 0.35 * MediaQuery.of(context).size.width, child: _buildContributeForm()),
      ],
    );
  }

  /// 搜索后 显示的视频列表
  Widget _buildSearchVideoInfoList() {
    return SizedBox(
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
                // 作者头像和昵称
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(searchVideoInfoList[index].author.avatar),
                    ),
                    const SizedBox(width: 10),
                    Text(searchVideoInfoList[index].author.nickname),
                  ],
                ),
                //标题
                const SizedBox(height: 10),
                Text(
                  searchVideoInfoList[index].title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                //描述
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

              showSearchVideoInfoList = false;

              Navigator.of(context)
                  .pushNamed("/video", arguments: {"mode": 2, "videoId": searchVideoInfoList[index].id});
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

  /// 投稿表单
  Widget _buildContributeForm() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.85,
      child: Offstage(
        offstage: !showContributeForm,
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
                        '投稿',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //标题
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: '标题',
                          hintText: '请输入标题',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入标题';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    //描述
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextFormField(
                        controller: describeController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: '描述',
                          hintText: '请输入描述',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入描述';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    //封面
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
                            uploadVideoCoverFile = uploadInput.files?.first;
                            _log.i('文件大小：${uploadVideoCoverFile?.size}');
                            uploadVideoCoverUrl = html.Url.createObjectUrl(uploadVideoCoverFile);
                          });
                        });
                      },
                      child: const Text('选择封面（可选）'),
                    ),
                    //封面预览
                    _builtNullText(uploadVideoCoverFile?.name),

                    const SizedBox(height: 10),
                    //视频
                    ElevatedButton(
                      onPressed: () {
                        //选择文件上传
                        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                        uploadInput.multiple = false; // 是否允许选择多文件
                        uploadInput.draggable = true; // 是否允许拖拽上传
                        uploadInput.click(); // 打开文件选择对话框

                        uploadInput.onChange.listen((event) {
                          // 选择完成 判断类型
                          if (uploadInput.files?.first.type != 'video/mp4') {
                            EasyLoading.showError('请选择mp4格式的视频');
                            return;
                          }

                          setState(() {
                            // 选择完成
                            uploadVideoFile = uploadInput.files?.first;
                            _log.i('文件大小：${uploadVideoFile?.size}');
                            uploadVideoUrl = html.Url.createObjectUrl(uploadVideoFile);
                          });
                        });
                      },
                      child: const Text('选择视频（必选）'),
                    ),
                    //视频预览
                    _builtNullText(uploadVideoFile?.name),
                    const SizedBox(height: 20),
                    //视频类型选择列表 体育 动漫 游戏 音乐  RadioListTile单选
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '视频类型(必选)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          RadioListTile(
                            title: const Text('体育'),
                            value: 0,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value as int;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text('动漫'),
                            value: 1,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value as int;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text('游戏'),
                            value: 2,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value as int;
                              });
                            },
                          ),
                          RadioListTile(
                            title: const Text('音乐'),
                            value: 3,
                            groupValue: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value as int;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    //提交
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _log.i('提交投稿');
                            uploadFile();
                            // _contributeVideo(titleController.text, describeController.text);
                          },
                          child: const Text('提交'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showContributeForm = false;
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
    );
  }

  ///构建上传文件的名称
  Widget _builtNullText(String? text) {
    return text == null
        ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
  }

  ///获取token 上传视频
  Future<void> uploadFile() async {
    //0.校验
    if (titleController.text.isEmpty || describeController.text.isEmpty) {
      EasyLoading.showError('标题或描述不能为空');
      return;
    }
    if (uploadVideoFile == null) {
      EasyLoading.showError('请选择视频文件');
      return;
    }
    if (uploadVideoFile!.size > 1024 * 1024 * 1024) {
      EasyLoading.showError('视频文件大小不能超过1G');
      return;
    }
    if (uploadVideoCoverFile != null && uploadVideoCoverFile!.size > 1024 * 1024 * 1024) {
      EasyLoading.showError('封面文件大小不能超过1G');
      return;
    }

    EasyLoading.show(status: '视频上传中...', maskType: EasyLoadingMaskType.black);
    //1.获取token
    final api = GlobalObjects.apiProvider;
    final qiniuToken = await api.upload.getKodoToken();
    if (qiniuToken.code == 20000) {
      _log.d('getKodoToken: ${qiniuToken.data!.token}');
    }
    if (qiniuToken.code == 4000) {
      EasyLoading.showError('存储服务异常，请稍后再试');
      _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
      EasyLoading.dismiss();
      return;
    }

    //2.上传文件
    //2.2如果封面存在，先上传封面，获得封面url
    if (uploadVideoCoverFile != null) {
      int coverUploadResult = await uploadVideoCover(qiniuToken); //上传封面
      if (coverUploadResult == 2000) {
        _log.i('封面上传成功');
      } else if (coverUploadResult == 4000) {
        EasyLoading.showError('封面上传失败');
        return;
      } else if (coverUploadResult == 6000) {
        _log.i('封面上传异常');
        EasyLoading.showError('存储服务异常，请稍后再试');
        return;
      }
    }

    //2.2如果封面不存在，就先拿头像封面占位图（后端异步处理帧截取封面，处理完后再替换） 直接填上传参数，上传视频
    // 表单
    html.FormData formData = html.FormData();
    formData.appendBlob('file', uploadVideoFile!.slice(), uploadVideoFile!.name);
    formData.append('token', qiniuToken.data!.token);
    // 生成uuid,截取11位 拼接文件后缀作为key
    final uuid = Uuid().v4().substring(0, 11);
    formData.append('key', '$uuid.mp4');
    // 判断封面是url否存在
    if (callbackVideoCoverUrl != "none") {
      formData.append('x:file_type', "VIDEO");
      formData.append('x:cover_url', callbackVideoCoverUrl!);
    } else {
      formData.append('x:file_type', "VIDEO-WITHCOVER");
      formData.append('x:cover_url', GlobalObjects.storageProvider.user.avatar ?? "");
    }
    formData.append('x:video_type_id', selectedValue.toString());
    formData.append('x:title', titleController.text);
    formData.append('x:describe', describeController.text);
    formData.append('x:uid', GlobalObjects.storageProvider.user.uid.toString());
    _log.i('上传视频参数：${formData.toString()}');
    // 上传
    try {
      var request = html.HttpRequest();
      request.open('POST', 'http://up-cn-east-2.qiniup.com');
      request.send(formData);
      request.onLoad.listen((event) {
        UploadFileCallbackResponse response = UploadFileCallbackResponse.fromJson(json.decode(request.responseText!));
        if (response.code == 2000) {
          _log.i(request.responseText);
          _log.i('视频上传成功');
          EasyLoading.showSuccess('上传成功');
          Navigator.pushNamed(context, "/video_detail", arguments: response.data!);
          setState(() {
            showContributeForm = false;
          });
        } else {
          EasyLoading.showError('上传失败');
          _log.e('视频上传失败: ${request.responseText}');
          return;
        }
      });
    } catch (e) {
      _log.e('上传视频异常：$e');
      EasyLoading.showError('存储服务异常，请稍后再试');
      return;
    }
  }

  ///上传封面
  Future<int> uploadVideoCover(GetKodoTokenResponse qiniuToken) async {
    int code = 0;
    // 获取文件扩展名
    String fileExtension = 'jpg'; // 默认扩展名
    if (uploadVideoCoverFile!.name.toLowerCase().endsWith('.png')) {
      fileExtension = 'png';
    }

    // 表单
    html.FormData formData = html.FormData();
    formData.appendBlob('file', uploadVideoCoverFile!, uploadVideoCoverFile!.name);
    formData.append('token', qiniuToken.data!.token);
    // 生成uuid,截取11位 拼接文件后缀作为key
    final uuid = const Uuid().v4().substring(0, 11);
    formData.append('key', '$uuid.$fileExtension');
    formData.append('x:file_type', "COVER");

    // 上传
    try {
      var request = html.HttpRequest();
      request.open('POST', 'http://up-cn-east-2.qiniup.com');
      request.send(formData);
      request.onLoad.listen((event) {
        UploadFileCallbackResponse response = UploadFileCallbackResponse.fromJson(json.decode(request.responseText!));
        if (response.code == 2000) {
          callbackVideoCoverUrl = response.data!.imageUrl;
          _log.i(request.responseText);
          code = 2000;
          _log.i('封面上传成功');
          return;
        } else {
          code = 4000;
          _log.e('封面上传失败: ${request.responseText}');
          return;
        }
      });
    } catch (e) {
      _log.e('封面上传异常：$e');
      code = 6000;
    }
    return code;
  }
}
