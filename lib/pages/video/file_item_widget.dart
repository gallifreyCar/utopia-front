// import 'dart:html' as html;
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'file_item.dart';
//
// typedef void DeleteFile(UploadFileItem fileItem);
//
// class FileItemWidget extends StatefulWidget {
//   final UploadFileItem? fileItem;
//
//   final DeleteFile? onDeleteFile;
//
//   const FileItemWidget({required Key key, this.fileItem, this.onDeleteFile}) : super(key: key);
//
//   @override
//   _FileItemWidgetState createState() => _FileItemWidgetState();
// }
//
// class _FileItemWidgetState extends State<FileItemWidget> {
//   @override
//   void initState() {
//     super.initState();
// //    _readFile();
//     _sendFormData(widget.fileItem.file);
//   }
//
//   _sendFormData(final html.File file) async {
//     setState(() {
//       widget.fileItem.fileStatus = FileStatus.uploading;
//     });
//
//     final html.FormData formData = html.FormData()..appendBlob('file', file);
//
//     handleRequest(html.HttpRequest httpRequest) {
//       print('upload resp: ${httpRequest.responseText}');
//       switch (httpRequest.status) {
//         case 200:
//           setState(() {
//             widget.fileItem?.fileStatus = FileStatus.success;
//           });
//           return;
//         default:
//           setState(() {
//             widget.fileItem?.fileStatus = FileStatus.fail;
//           });
//           break;
//       }
//     }
//
//     onProgress(e) {
//       print('upload sending: ${e.loaded} ${e.total}');
//       double progress = e.lengthComputable ? (e.loaded * 100 ~/ e.total) / 100.0 : e.loaded / 100.0;
//
//       print('upload sending: $progress');
//       if (widget.fileItem?.progress == progress) return;
//       setState(() {
//         widget.fileItem?.progress = progress;
//       });
//     }
//
//     //    var url = 'https://www.mocky.io/v2/5cc8019d300000980a055e76';
//     var url = 'http://localhost:8088/api/file/upload';
//
//     html.HttpRequest.request(
//       url,
//       method: 'POST',
//       sendData: formData,
//       onProgress: onProgress,
//     ).then((httpRequest) {
//       handleRequest(httpRequest);
//     }).catchError((e) {
//       setState(() {
//         widget.fileItem.fileStatus = FileStatus.fail;
//       });
//     });
//
// //    final html.HttpRequest httpRequest = html.HttpRequest();
// //    httpRequest
// //      ..onProgress.listen(onProgress)
// //      ..onLoadEnd.listen((e) {
// //        handleRequest(httpRequest);
// //      })
// //      ..open('POST', url)
// //      ..send(formData);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     UploadFileItem fileItem = widget.fileItem;
//
//     var prefixIcon;
//     if (fileItem.fileStatus == FileStatus.uploading || fileItem.fileStatus == FileStatus.normal) {
//       prefixIcon = CupertinoActivityIndicator(
//         animating: true,
//         radius: 8.0,
//       );
//     } else {
//       prefixIcon = Icon(
//         Icons.attach_file,
//         color: Colors.lightBlue,
//         size: 20.0,
//       );
//     }
//
//     return InkWell(
//       hoverColor: Colors.blue[100],
//       onTap: () {},
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Row(
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 prefixIcon,
//                 SizedBox(width: 8.0),
//                 Expanded(
//                   child: Text(
//                     '${fileItem.file.name}',
//                     style: TextStyle(
//                         color: fileItem.fileStatus == FileStatus.fail ? Colors.red : Colors.black87, fontSize: 18.0),
//                   ),
//                 ),
//                 IconButton(
//                   padding: EdgeInsets.all(2.0),
//                   iconSize: 18.0,
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     widget.onDeleteFile(fileItem);
//                   },
//                   color: Colors.red[500],
//                 ),
//               ],
//             ),
//             if (fileItem.fileStatus == FileStatus.uploading)
//               LinearProgressIndicator(
//                 value: fileItem.progress,
//                 backgroundColor: Colors.transparent,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
