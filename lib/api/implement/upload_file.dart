import 'package:dio/dio.dart';
import 'package:utopia_front/api/abstract/upload_file.dart';

class UploadFileApiImpl extends UploadFileApi {
  final Dio dio;
  UploadFileApiImpl(this.dio);

  @override
  Future<GetKodoTokenResponse> getKodoToken() async {
    final resp = await dio.get('/api/v1/upload/token');
    return GetKodoTokenResponse.fromJson(resp.data);
  }

  @override
  Future<String> uploadFileToKodo(String token, UploadFileRequest request) async {
    FormData formData = FormData.fromMap({
      "file": request.file,
      "token": token,
      "x:file_type": request.fileType,
      "x:describe": request.describe,
      "x:cover_url": request.coverUrl,
      "x:video_type_id": request.videoTypeId,
      "x:uid": request.videoTypeName,
    });
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    dio.options.baseUrl = '';
    final resp = await dio.post('s30hxzidb.bkt.clouddn.com', data: formData);
    return resp.data.toString();
  }
}
