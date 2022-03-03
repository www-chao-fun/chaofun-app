import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/chat_home_page.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/utils/const.dart';
import 'package:flutter_chaofan/utils/utils.dart';
//import 'package:flutter_chaofan/widget/common/pageFade.dart';
import 'package:flutter_chaofan/widget/im/ui.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
//import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'msg_avatar.dart';


class ImgMsg extends StatelessWidget {
  final msg;


  final Map<String, dynamic> model;

  ImgMsg(this.msg, this.model);

  @override
  Widget build(BuildContext context) {
    bool isMyself = (model['sender']['userId'] == Provider.of<UserStateProvide>(context, listen: false).userInfo['userId']);

//    if (!listNoEmpty(msg['imageList'])) return Text('发送中');
    var originUrl = KSet.imgOrigin + msg;
    var url = originUrl + '?x-oss-process=image/resize,h_200/format,webp/quality,q_75';

    var isFile = false;
    var body = [
      new MsgAvatar(model: model),
//      new Space(width: mainSpace),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isMyself ? new Container():
          new Container(
            child:  Text(model['sender']['userName'] + "  " + Utils.chatTime(model['time'])),
            alignment: Alignment.topLeft,
          ),
          new GestureDetector(
              child: new Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: new ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: new CachedNetworkImage(
                      imageUrl: url, height: 128, fit: BoxFit.cover),
                ),
              ),
              onTap: () =>  Navigator.of(context).push(
                  FadeRoute(
                    page: JhPhotoAllScreenShow(
                      imgDataArr: [originUrl],
                      index: 0,
                    ),
                  )
              ),
            ),
//          new Spacer(),
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
      child: new Row(children: body,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start),

    );
  }
}
