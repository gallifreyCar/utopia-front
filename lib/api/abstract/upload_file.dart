//上传文件的API抽象类
import '../model/kodoFile.dart';

abstract class UploadFileApi {
  //获取七牛云存储kodo的token
  Future<GetKodoTokenResponse> getKodoToken();

  //上传文件到七牛云
  Future<String> uploadFileToKodo(String token, UploadFileRequest request);
}
