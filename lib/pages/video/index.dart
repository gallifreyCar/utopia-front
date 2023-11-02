import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utopia_front/api/abstract/video.dart';
import 'package:utopia_front/global/index.dart';
import 'package:utopia_front/pages/login/index.dart';
import 'package:utopia_front/pages/video/singleVideoPage.dart';

import '../../util/flash.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

///全局日志打印
final _log = GlobalObjects.logger;

class _IndexPageState extends State<IndexPage> {
  VideoResponse? videoResponse;
  // List<String> urls = [];
  //视频信息
  List<VideoInfo> videoInfoList = [];
  int nextTime = 0;

  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: '视频加载中...');
    // 请求视频列表
    _onRefresh(1, 0);
  }

  ///构建个人中心 如果没有登录则不显示
  List<Widget> buildPersonAppBar() {
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
              child: Text(nickname),
            )
          ],
        ),
        const SizedBox(width: 5),
        TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text('个人', style: TextStyle(color: Colors.white, fontSize: 20))),
        //投稿
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text('投稿', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        TextButton.icon(
            onPressed: () {
              GlobalObjects.storageProvider.user.jwtToken = null;
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginModeSelectorPage()));
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('退出', style: TextStyle(color: Colors.white, fontSize: 20))),
        SizedBox(width: 40),
      ];
    }
    return [Container()];
  }

  ///请求视频方法 这里是切换视频分类的时候调用，下拉刷新也会调用
  ///如果是下拉刷新，那么myNextTime就是上一次请求的nextTime
  ///如果是切换分类，那么myNextTime就是0
  Future<void> _onRefresh(int videoType, int myNextTime) async {
    setState(() {
      if (myNextTime == 0) {
        videoInfoList.clear();
      }
    });
    EasyLoading.show(status: '视频加载中...');
    final api = GlobalObjects.apiProvider;
    final request = VideoRequest(lastTime: myNextTime, videoType: videoType);
    api.video.getVideoList(request).then((videoResponse) {
      EasyLoading.dismiss();
      if (videoResponse?.code == 2000) {
        _log.i('请求成功');
        //如果是下拉刷新，那么就清空urls
        setState(() {
          if (myNextTime == 0) {
            videoInfoList.clear();
          }
          videoInfoList.addAll(videoResponse!.data!.videoInfo);
          nextTime = videoResponse!.data!.nextTime!;
        });
      }
      if (videoResponse?.code == 4000) {
        showBasicFlash(context, Text("请求失败"), duration: const Duration(seconds: 2));
        _log.i('请求失败');
      }
    }).catchError((e) {
      _log.e(e);
      EasyLoading.dismiss();
      EasyLoading.showError('服务器抽风了,请稍后再试');
      //停留5秒
      Future.delayed(const Duration(seconds: 5), () {
        EasyLoading.dismiss();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginModeSelectorPage()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 20);
    return Scaffold(
        appBar: AppBar(title: const Text('Utopia'), actions: [
          Row(
            children: buildPersonAppBar(),
          ),
          const SizedBox(width: 20),
          //视频分类 0.热门 1.体育 2.动漫 3.游戏 4.音乐
          TextButton(
              onPressed: () {
                _onRefresh(0, 0);
              },
              child: const Text('热门', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(0, 0);
              },
              child: const Text('推荐', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(1, 0);
              },
              child: const Text('体育', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(2, 0);
              },
              child: const Text('动漫', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(3, 0);
              },
              child: const Text('游戏', style: textStyle)),
          TextButton(
              onPressed: () {
                _onRefresh(4, 0);
              },
              child: const Text('音乐', style: textStyle)),
          const SizedBox(width: 40),
        ]),
        body: KeepAliveWrapper(
          keepAlive: true,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoInfoList.length,
            itemBuilder: (context, index) {
              // return VideoPlayerPage(
              //   text: "视频$index",
              //   playUrl: urls[index],
              // );
              return videoInfoList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : VideoPlayerPage(
                      text: "视频$index",
                      videoInfo: videoInfoList[index],
                    );
            },
          ),
        ));
  }

  //构建KeepAliveWrapper整个页面
  // Widget buildKeepAliveWrapper() {
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
