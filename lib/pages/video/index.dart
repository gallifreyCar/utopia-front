import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:utopia_front/global/index.dart';

import '../../util/flash.dart';
import 'file_item.dart';

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
          onPressed: uploadFile,
          icon: Icon(Icons.upload_file),
          label: Text('上传文件'),
        ),
      ),
    );
  }

  Future<void> uploadFile() async {
    List<UploadFileItem> _files = [];

    try {
      List<html.File>? files = [];
      //1. 上传文件
      html.FileUploadInputElement fileInput = html.FileUploadInputElement();
      fileInput.multiple = false;
      fileInput.click();
      fileInput.onChange.listen((e) async {
        files = fileInput.files;
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

        // //3. 上传文件到七牛云存储
        fileInput.onChange.listen((e) {
          var fileItem = UploadFileItem(files![0]);
          setState(() {
            _files.add(fileItem);
          });
        });
        var file = files![0];
        final html.FormData formData = html.FormData()..appendBlob('file', file);
        formData.append('token', qiniuToken.data!.token);
        formData.append('key', file.name);
        formData.append('x:filename', file.name);
        formData.append('x:size', file.size.toString());
        formData.append('x:mime_type', file.type);
        formData.append('x:ext', file.name.split('.').last);

        final response = await html.HttpRequest.request(
          'http://up-cn-east-2.qiniup.com',
          method: 'POST',
          sendData: formData,
        );

        _log.d('上传文件到七牛云存储: ${response.response.toString()}');
      });
    } catch (e) {
      showBasicFlash(context as BuildContext, Text('上传文件异常: ${e.toString().split('\n')[0]}'));
      _log.e('上传文件异常: $e');
    }
  }
}

final _log = GlobalObjects.logger;
