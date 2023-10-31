import 'package:dio/dio.dart';
import 'package:utopia_front/api/abstract/upload_file.dart';

class UploadFileImpl extends UploadFileAPI {
  final Dio dio;
  UploadFileImpl(this.dio);

  @override
  Future<GetKodoTokenResponse> getKodoToken() async {
    final resp = await dio.get('/api/v1/upload/token');
    return GetKodoTokenResponse.fromJson(resp.data);
  }

  @override
  Future<String> uploadFileToKodo(String token, String filePath) {
    // TODO: implement uploadFileToKodo
    throw UnimplementedError();
  }
}
