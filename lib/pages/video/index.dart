import 'dart:js';

import 'package:flutter/material.dart';
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
          onPressed: uploadFile,
          icon: Icon(Icons.upload_file),
          label: Text('上传文件'),
        ),
      ),
    );
  }
}

final _log = GlobalObjects.logger;

Future<void> uploadFile() async {
  try {
    //1. 获取七牛云存储token
    final api = GlobalObjects.apiProvider;
    final resp = await api.upload.getKodoToken();
    if (resp.code == 20000) {
      _log.d('getKodoToken: ${resp.data!.token}');
    }
    if (resp.code == 4000) {
      showBasicFlash(context as BuildContext, Text('获取七牛云存储token失败: ${resp.msg}'));
      _log.e('获取七牛云存储token失败: ${resp.msg}');
      return;
    }
    //2. 上传文件
  } catch (e) {
    showBasicFlash(context as BuildContext, Text('上传文件异常: ${e.toString().split('\n')[0]}'));
    _log.e('上传文件异常: $e');
  }
}
