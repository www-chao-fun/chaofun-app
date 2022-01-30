import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/chat_home_page.dart';
import 'package:flutter_chaofan/utils/const.dart';
import 'package:flutter_chaofan/utils/contacts.dart';
import 'package:flutter_chaofan/utils/win_media.dart';
import 'package:flutter_chaofan/utils/notice.dart';
import 'package:flutter_chaofan/widget/im/chat_details_body.dart';
import 'package:flutter_chaofan/widget/im/chat_details_row.dart';
import 'package:flutter_chaofan/widget/im/chat_more_icon.dart';
import 'package:flutter_chaofan/widget/im/indicator_page_view.dart';
import 'package:flutter_chaofan/widget/im/main_input.dart';
import 'package:flutter_chaofan/widget/im/text_span_builder.dart';
import 'package:flutter_chaofan/widget/im/emoji_text.dart';

import 'bar/commom_bar.dart';
import 'chat_more_page.dart';

enum ButtonType { voice, more }

class ChatPage extends StatefulWidget {
  final String title;
  final int type;
  final int id;

  ChatPage({this.id, this.title, this.type = 1});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isVoice = false;
  bool _isMore = false;
  double keyboardHeight = 270.0;
  bool _emojiState = false;
  String newGroupName;

  TextEditingController _textController = TextEditingController();
  FocusNode _focusNode = new FocusNode();
  ScrollController _sC = ScrollController();
  PageController pageC = new PageController();

  @override
  void initState() {
    super.initState();
    Notice.addListener("chat_channel_" + widget.id.toString(), (v) => handleWebsocketMsg(v));
    allChannel.sink.add("{\"scope\": \"chat\", \"data\": {\"type\": \"load\", \"channelId\":"+ widget.id.toString() + "}}");
  }

  List<Map<String, dynamic>> chatData = [];

  handleWebsocketMsg(Map<String, dynamic> data) {
    print('chat_page handleWebsocketMsg');
    print(data['type']);
    if (data['type'] == 'message') {
      addChatMessage(data['data']);
    } else if (data['type'] == 'load_result') {
      print(data['data']['chatMessages'].runtimeType);
      addChatHistory(data['data']['chatMessages']);
    }
  }

  addChatMessage(Map<String, dynamic> data) {
    setState(() {
      chatData.insert(0, data);
    });
  }

  addChatHistory(List<dynamic> data) {
    print('addChatHistory');
    print(data[0].runtimeType);
    List<Map<String, dynamic>> data_1 = [];
    for (var value  in data) {
      data_1.add(value);
    }
    print('123');
    print(data_1.length);

    setState(() {
      chatData.insertAll(0, data_1);
    });
  }


  _handleSubmittedData(String text) async {
    _textController.clear();
    if (text == null || text == '') {
      return;
    }
    allChannel.sink.add("{\"scope\": \"chat\", \"data\": {\"type\": \"text\", \"channelId\": " + widget.id.toString() + ", \"content\": \"" + text +"\"}}");
  }

  onTapHandle(ButtonType type) {
    setState(() {
      if (type == ButtonType.voice) {
        _focusNode.unfocus();
        _isMore = false;
        _isVoice = !_isVoice;
      } else {
        _isVoice = false;
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          _isMore = true;
        } else {
          _isMore = !_isMore;
        }
      }
      _emojiState = false;
    });
  }

  Widget edit(context, size) {
    // 计算当前的文本需要占用的行数
    TextSpan _text =
    TextSpan(text: _textController.text, style: AppStyles.ChatBoxTextStyle);

    TextPainter _tp = TextPainter(
        text: _text,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left);
    _tp.layout(maxWidth: size.maxWidth);

    return ExtendedTextField(
      specialTextSpanBuilder: TextSpanBuilder(showAtBackground: true),
      onTap: () => setState(() {
        // if (_focusNode.hasFocus) {
            _emojiState = false;
            _isMore = true;
        // }
      }),
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
          border: InputBorder.none, contentPadding: const EdgeInsets.all(5.0)),
      controller: _textController,
      focusNode: _focusNode,
      maxLines: 99,
      cursorColor: const Color(AppColors.ChatBoxCursorColor),
      style: AppStyles.ChatBoxTextStyle,
    );
  }


  @override
  Widget build(BuildContext context) {
    // 这里有点不准，键盘弹起来的时候会重复Build，所以会有些问题
    if (keyboardHeight == 270.0 &&
        MediaQuery.of(context).viewInsets.bottom > keyboardHeight) {
      keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      // print(MediaQuery.of(context).viewInsets);
    }

    List<Widget> body = [
      chatData != null
          ? new ChatDetailsBody(sC: _sC, chatData: chatData)
          : new Spacer(),
      new ChatDetailsRow(
        voiceOnTap: () => onTapHandle(ButtonType.voice),
        onEmojio: () {
          if (_isMore) {
            _emojiState = true;
          } else {
            _emojiState = !_emojiState;
          }
          if (_emojiState) {
            FocusScope.of(context).requestFocus(new FocusNode());
            _isMore = false;
          }
          setState(() {});
        },
        isVoice: _isVoice,
        edit: edit,
        more: new ChatMoreIcon(
          value: _textController.text,
          onTap: () => _handleSubmittedData(_textController.text),
          moreTap: () => onTapHandle(ButtonType.more),
        ),
        id: widget.id,
        type: widget.type,
      ),
      new Visibility(
        visible: _emojiState,
        child: emojiWidget(),
      ),
      new Container(
        height: _isMore && !_focusNode.hasFocus ? keyboardHeight : 0.0,
        width: winWidth(context),
        color: Color(AppColors.ChatBoxBg),
        child: new IndicatorPageView(
          pageC: pageC,
          pages: List.generate(1, (index) {
            return new ChatMorePage(
              index: index,
              id: widget.id,
              type: widget.type,
              keyboardHeight: keyboardHeight,
            );
          }),
        ),
      ),
      new Container(height: 10,child: new InkWell(),)
    ];

    List<Widget> rWidget =  [
    ];

    return
      Scaffold(
        appBar: new ComMomBar(
            title: newGroupName ?? widget.title, rightDMActions: rWidget),
        body: new MainInputBody(
          onTap: () => setState(
                () {
              _isMore = false;
              _emojiState = false;
            },
          ),
          decoration: BoxDecoration(color: chatBg),
          child: new Column(children: body),
        ),
      );
  }


  Widget emojiWidget() {
    List<String> images = ["😀","😀","😃","😄","😁","😆","😅","😂","🤣","😊","😇","🙂","🙃","😉","😌","😍","🥰","😘","😗","😙","😚","😋","😛","😝","😜","🤪","🤨","🧐","🤓","😎","🤩","🥳","😏","😒","😞","😔","😟","😕","🙁","😣","😖","😫","😩","🥺","😢","😭","😤","😠","😡","🤬","🤯","😳","🥵","🥶","😱","😨","😰","😥","😓","🤗","🤔","🤭","🤫","🤥","😶","😐","😑","😬","🙄","😯","😦","😧","😮","😲","😴","🤤","😪","😵","🤐","🥴","🤢","🤮","🤧","😷","🤒","🤕","🤑","🤠","😈","👿","👹","👺","🤡","💩","👻","💀","☠️","👽","👾","🤖","🎃","😺","😸","😹","😻","😼","😽","🙀","😿","😾"];
    return new GestureDetector(
      child: new SizedBox(
        height: _emojiState ? keyboardHeight : 0,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Text(images[index], style: TextStyle(fontSize: 24)),
              behavior: HitTestBehavior.translucent,
              onTap: () {
                insertText(images[index]);
              },
            );
          },
          itemCount: images.length,
          padding: EdgeInsets.all(5.0),
        ),
      ),
      onTap: () {},
    );
  }

  void insertText(String text) {
    var value = _textController.value;
    var start = value.selection.baseOffset;
    var end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      setState(() {
        _textController.value = value.copyWith(
            text: newText,
            selection: value.selection.copyWith(
                baseOffset: end + text.length,
                extentOffset: end + text.length));
      });
    } else {
      setState(() {
        _textController.value = TextEditingValue(
            text: value.text + text,
            selection:
            TextSelection.fromPosition(TextPosition(offset: (value.text + text).length)));
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    Notice.removeListenerByEvent("chat_channel_" + widget.id.toString());
  }
}
