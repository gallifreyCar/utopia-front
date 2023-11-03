import 'package:flutter/cupertino.dart';

class TestWidget extends StatefulWidget {
  final String text;
  final Function sendMessage;
  const TestWidget({Key? key, required this.text, required this.sendMessage}) : super(key: key);
  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.text),
    );
  }
}
