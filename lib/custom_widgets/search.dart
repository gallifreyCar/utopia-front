import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:universal_html/html.dart' as html;
import 'package:utopia_front/global/index.dart';
import 'package:uuid/uuid.dart';

import '../api/model/base.dart';
import '../api/model/kodoFile.dart';
import '../api/model/video.dart';

///搜索
class SearchWindow extends StatefulWidget {
  const SearchWindow({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchWindow> createState() => SearchWindowState();
}

class SearchWindowState extends State<SearchWindow> {
  final _log = GlobalObjects.logger;
  //搜索的视频信息
  List<VideoInfo> searchVideoInfoList = [];
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  //搜索
  bool showSearchVideoInfoList = false;

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
                  onSubmitted: (value) {
                    if (_searchController.text.isEmpty) {
                      EasyLoading.showInfo('请输入搜索内容');
                      return;
                    }
                    _log.i('搜索', value);
                    _searchVideoInfoList(value);
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

  bool showContributeForm = false;

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }

  /// 显示投稿表单
  void showContributeFormFunc() {
    setState(() {
      showContributeForm = true;
    });
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

      if (videoResponse.code == successCode) {
        _log.i('搜索视频成功', videoResponse.data);
        setState(() {
          searchVideoInfoList = videoResponse.data?.videoInfo ?? [];
        });
      }
      if (videoResponse.code == errorCode) {
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                    //封面文件信息
                    const SizedBox(height: 5),
                    buildFileInfoText(uploadVideoCoverFile, "封面"),

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
                    const SizedBox(height: 5),
                    buildFileInfoText(uploadVideoFile, "视频"),

                    const SizedBox(height: 10),
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
                              _clearUploadForm();
                            },
                            child: const Text('清空')),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () {
                              _clearUploadForm();

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

  /// 清空上传表单
  void _clearUploadForm() {
    setState(() {
      titleController.text = '';
      describeController.text = '';
      uploadVideoCoverFile = null;
      uploadVideoFile = null;
      uploadVideoCoverUrl = '';
      uploadVideoUrl = '';
      callbackVideoCoverUrl = 'none';
      selectedValue = 0;
    });
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
    if (uploadVideoCoverFile != null && uploadVideoCoverFile!.size > 1024 * 1024 * 10) {
      EasyLoading.showError('封面文件大小不能超过10M');
      return;
    }

    EasyLoading.show(status: '视频上传中...', maskType: EasyLoadingMaskType.black);
    //1.获取token
    final api = GlobalObjects.apiProvider;
    final qiniuToken = await api.upload.getKodoToken();
    if (qiniuToken.code == successCode) {
      _log.d('getKodoToken: ${qiniuToken.data!.token}');
    }
    if (qiniuToken.code == errorCode) {
      EasyLoading.showError('存储服务异常，请稍后再试');
      _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
      EasyLoading.dismiss();
      return;
    }

    //2.上传文件
    //2.2如果封面存在，先上传封面，获得封面url
    if (uploadVideoCoverFile != null) {
      int coverUploadResult = await uploadVideoCover(qiniuToken); //上传封面
      if (coverUploadResult == successCode) {
        _log.i('封面上传成功');
      } else if (coverUploadResult == errorCode) {
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
      formData.append('x:file_type', "VIDEO-WITHCOVER");
      formData.append('x:cover_url', callbackVideoCoverUrl!);
    } else {
      formData.append('x:file_type', "VIDEO");
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
      request.open('POST', GlobalObjects.qiniuKodoUrl);
      request.send(formData);
      request.onLoad.listen((event) {
        UploadFileCallbackResponse response = UploadFileCallbackResponse.fromJson(json.decode(request.responseText!));
        if (response.code == successCode) {
          _log.i(request.responseText);
          _log.i('视频上传成功');
          EasyLoading.showSuccess('投稿成功');
          setState(() {
            showContributeForm = false;
          });
        } else {
          EasyLoading.showError('视频上传失败');
          _log.e('视频上传失败: ${request.responseText}');
          return;
        }
      });
    } catch (e) {
      _log.e('上传视频异常：$e');
      EasyLoading.showError('存储服务异常，请稍后再试');
      return;
    }
    _clearUploadForm();
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
      request.open('POST', GlobalObjects.qiniuKodoUrl);
      request.send(formData);
      request.onLoad.listen((event) {
        UploadFileCallbackResponse response = UploadFileCallbackResponse.fromJson(json.decode(request.responseText!));
        if (response.code == successCode) {
          callbackVideoCoverUrl = response.data!.imageUrl;
          _log.i(request.responseText);
          code = successCode;
          _log.i('封面上传成功');
          return;
        } else {
          code = errorCode;
          _log.e('封面上传失败: ${request.responseText}');
          return;
        }
      });
    } catch (e) {
      _log.e('封面上传异常：$e');
      code = 6000;
    }
    //超时处理
    await Future.delayed(const Duration(seconds: 10), () {
      if (code == 0) {
        code = 6000;
      }
    });

    return code;
  }

  ///投稿表单变量
  //标题控制器
  final titleController = TextEditingController();

  //描述控制器
  final describeController = TextEditingController();

  // 视频分类选择
  int selectedValue = 0;

  // 投稿表单是否显示
  String uploadVideoUrl = "";
  String uploadVideoCoverUrl = "";
  html.File? uploadVideoFile;
  html.File? uploadVideoCoverFile;
  String callbackVideoCoverUrl = "none";

  //是否只看某人
  bool onlySeeOne = false;
  int currentIndex = 0;

  //热门视频参数
  double score = 0.0;
  int version = 0;

  //分类视频参数
  int categoryId = 0;

  /// 上传文件信息
  Widget buildFileInfoText(html.File? uploadVideoFile, String? title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uploadVideoFile == null ? '$title未选择文件' : '$title文件名：${uploadVideoFile!.name}',
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          //换算一下 MB 保留两位小数
          uploadVideoFile == null ? '' : '$title文件大小：${(uploadVideoFile!.size / 1024 / 1024).toStringAsFixed(2)}MB',
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
