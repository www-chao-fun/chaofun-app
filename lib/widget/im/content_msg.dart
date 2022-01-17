import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/utils/const.dart';


class ContentMsg extends StatefulWidget {
  final String msg;

  ContentMsg(this.msg);

  @override
  _ContentMsgState createState() => _ContentMsgState();
}

class _ContentMsgState extends State<ContentMsg> {
  String str;

  TextStyle _style = TextStyle(color: mainTextColor, fontSize: 14.0);

  @override
  Widget build(BuildContext context) {
    return new Text(
      widget.msg,
    );
  }
}
