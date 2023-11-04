import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

///聊天窗口
class ChatWindow extends StatefulWidget {
  final Function sendMessage;

  const ChatWindow({Key? key, required this.sendMessage}) : super(key: key);

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  //是否显示表情包选择
  bool _showEmoji = false;
  //输入框控制器
  final TextEditingController _controller = TextEditingController();

  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji //添加表情包进入文本
      ..selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length)); //移动光标到文本末尾
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString() //删除最后一个字符
      ..selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length)); //移动光标到文本末尾
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 用Offstage组件来控制表情包的显示与隐藏
        Offstage(
          offstage: !_showEmoji,
          child: SizedBox(
            height: 300,
            width: 400,
            child: EmojiPicker(

                /// 表情包选择回调
                onEmojiSelected: (Category? category, Emoji emoji) {
                  _onEmojiSelected(emoji);
                },

                /// 删除按钮回调
                onBackspacePressed: _onBackspacePressed,
                config: Config(

                    // 列数
                    columns: 10,
                    // 表情包最大尺寸
                    emojiSizeMax: 28 * (1.0),
                    verticalSpacing: 0, //

                    horizontalSpacing: 0,
                    // 初始类别
                    initCategory: Category.RECENT,
                    // 背景颜色
                    bgColor: const Color(0xFFF2F2F2),
                    // 指示器颜色
                    indicatorColor: Theme.of(context).primaryColor,
                    // 图标颜色
                    iconColor: Colors.black87,
                    // 选中图标颜色
                    iconColorSelected: Theme.of(context).primaryColorDark,
                    // 删除按钮颜色
                    backspaceColor: Theme.of(context).primaryColorDark,
                    // 选择肤色弹窗背景颜色
                    skinToneDialogBgColor: Colors.white,
                    // 选择肤色指示器颜色
                    skinToneIndicatorColor: Colors.white12,
                    // 是否启用肤色选择
                    enableSkinTones: true,
                    // 最近使用表情包数量
                    recentsLimit: 28,
                    // 无最近使用表情包时显示
                    noRecents: Text(
                      '最近没有使用表情包哦',
                      style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    // 指示器动画时长
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    // 类别图标
                    categoryIcons: CategoryIcons(),
                    // 按钮模式
                    buttonMode: ButtonMode.MATERIAL)),
          ),
        ),
        //外层组件
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),

          /// 行内组件 有三个： 表情按钮，输入框，发送按钮
          child: Row(
            children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35.0),
                  boxShadow: const [BoxShadow(offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)],
                ),
                child: Row(
                  children: [
                    /// 表情包按钮
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.face,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _showEmoji = !_showEmoji;
                            });
                          }),
                    ),

                    /// 输入框
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: "友好地发表你的意见吧",
                            hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                            border: InputBorder.none),
                      ),
                    ),

                    /// 发送按钮
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Theme.of(context).primaryColor, size: 30),
                        onPressed: () {
                          if (_controller.text != '') {
                            widget.sendMessage(_controller.text);
                            setState(() {
                              _controller.text = '';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
