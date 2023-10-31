// import 'dart:html' as html;
//
// import 'package:flutter/material.dart';
//
// import 'file_item.dart';
//
// class UploadWidget extends StatefulWidget {
//   @override
//   _UploadWidgetState createState() => _UploadWidgetState();
// }
//
// class _UploadWidgetState extends State<UploadWidget> {
//   List<UploadFileItem> _files = [];
//
//   _selectFile() {
//     html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//     uploadInput.multiple = false;
//     uploadInput.click();
//     uploadInput.onChange.listen((e) {
//       final files = uploadInput.files;
//       var fileItem = UploadFileItem(files[0]);
//       setState(() {
//         _files.add(fileItem);
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var picker = InkWell(
//       hoverColor: Colors.blue[50],
//       splashColor: Colors.blue[10],
//       onTap: _selectFile,
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.blue),
//           borderRadius: BorderRadius.all(Radius.circular(5.0)),
//         ),
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//         child: Text(
//           'Click to select file',
//           style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
//         ),
//       ),
//     );
//
//     var filesList = _files.map(_fileItem);
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: <Widget>[picker, SizedBox(height: 10.0), ...filesList],
//     );
//   }
//
//   _delete(UploadFileItem fileItem) {
//     print('delete ${fileItem.file.name}');
//     setState(() {
//       _files.remove(fileItem);
//     });
//   }
//
//   Widget _fileItem(UploadFileItem fileItem) {
//     return FileItemWidget(
//       fileItem: fileItem,
//       onDeleteFile: _delete,
//     );
//   }
// }
