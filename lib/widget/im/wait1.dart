import 'dart:io';

import 'package:flutter_chaofan/widget/im/Img_msg.dart';
import 'package:flutter_chaofan/widget/im/text_msg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'link_msg.dart';


class SendMessageView extends StatefulWidget {
  final Map<String, dynamic> model;

  SendMessageView(this.model);

  @override
  _SendMessageViewState createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<SendMessageView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> msg = widget.model;
    String msgType = msg['type'];
    String msgStr = msg.toString();

    bool isI = Platform.isIOS;
    bool iosText = isI && msgStr.contains('text:');
    bool iosImg = isI && msgStr.contains('imageList:');
    var iosS = msgStr.contains('downloadFlag:') && msgStr.contains('second:');
    bool iosSound = isI && iosS;
    if (msgType == "text" || iosText) {
      if (checkIsLink(msg['content'])) {
        return new LinkMsg(msg['content'], widget.model);
      }
      return new TextMsg(msg['content'], widget.model);
    } else if (msgType == "image") {
      return new ImgMsg(msg['content'], widget.model);

    } else {
      return new TextMsg('[未知消息类型，升级最新版App查看]', widget.model);
    }
  }

  bool checkIsLink(String content) {
    if (content == null) {
      return null;
    }

    if (content.trim().startsWith("https://chao.fan") && !content.contains(" ")) {
      return true;
    }


    return false;
  }
}
