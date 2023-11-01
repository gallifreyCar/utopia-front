import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:utopia_front/global/index.dart';

import '../../util/flash.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utopia')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: pickFile,
          icon: Icon(Icons.upload_file),
          label: Text('上传文件'),
        ),
      ),
    );
  }

  Future<void> uploadFile() async {
    //1. 上传文件
    //2. 获取七牛云存储token
    final api = GlobalObjects.apiProvider;
    final qiniuToken = await api.upload.getKodoToken();
    if (qiniuToken.code == 20000) {
      _log.d('getKodoToken: ${qiniuToken.data!.token}');
    }
    if (qiniuToken.code == 4000) {
      showBasicFlash(context as BuildContext, Text('获取七牛云存储token失败: ${qiniuToken.msg}'));
      _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
      return;
    }
  }

  Future<void> pickFile() async {
    //1.获取token
    final api = GlobalObjects.apiProvider;
    final qiniuToken = await api.upload.getKodoToken();
    if (qiniuToken.code == 20000) {
      _log.d('getKodoToken: ${qiniuToken.data!.token}');
    }
    if (qiniuToken.code == 4000) {
      showBasicFlash(context as BuildContext, Text('获取七牛云存储token失败: ${qiniuToken.msg}'));
      _log.e('获取七牛云存储token失败: ${qiniuToken.msg}');
      return;
    }
    //2.选择文件上传

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false; // 是否允许选择多文件
    uploadInput.draggable = true; // 是否允许拖拽上传
    uploadInput.click(); // 打开文件选择对话框

    uploadInput.onChange.listen((event) {
      // 选择完成
      html.File? file = uploadInput.files?.first;
      _log.e('文件大小：${file?.size}');

      if (file != null) {
        html.FormData formData = html.FormData();
        formData.appendBlob('file', file.slice(), file.name);
        formData.append('token', qiniuToken.data!.token);
        formData.append('key', "YES");
        //"x:file_type": "COVER",
        formData.append('x:file_type', "AVATAR");

        // 上传文件到服务器
        var request = html.HttpRequest();
        request.open('POST', 'http://up-cn-east-2.qiniup.com');
        request.send(formData);
        request.onLoadEnd.listen((event) {
          _log.e('上传结果：${request.responseText}');
        });
      }
    });
  }
}

final _log = GlobalObjects.logger;
