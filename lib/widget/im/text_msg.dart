import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/im/text_item_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'msg_avatar.dart';

class TextMsg extends StatelessWidget {
  final String text;
  final Map<String, dynamic> model;

  TextMsg(this.text, this.model);

  @override
  Widget build(BuildContext context) {
    // print(model['sender']['userId']);
    // print(Provider.of<UserStateProvide>(context, listen: false).userInfo);

    bool isMyself = (model['sender']['userId'] == Provider.of<UserStateProvide>(context, listen: false).userInfo['userId']);

    var body = [
      new MsgAvatar(model: model),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isMyself ? new Container():
          new Container(
            child:  Text(model['sender']['userName'] + "  " + Utils.chatTime(model['time'])),
            alignment: Alignment.topLeft,
          ),
          new TextItemContainer(
            text: text ?? '文字为空',
            action: '',
            isMyself: isMyself,
          ),
        ],
      ),
      new Spacer(),
    ];
    if (isMyself) {
      body = body.reversed.toList();
    } else {
      body = body;
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: body),
    );
  }
}
