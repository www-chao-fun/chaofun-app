import 'package:flutter/material.dart';
import 'package:flutter_chaofan/utils/const.dart';
import 'package:flutter_chaofan/utils/win_media.dart';
import 'package:flutter_chaofan/widget/im/ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'content_msg.dart';
import 'image_view.dart';

class MyConversationView extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String content;
  final Widget time;
  final bool isBorder;
  final int unReadMessageNumber;

  MyConversationView({
    this.imageUrl,
    this.title,
    this.content,
    this.time,
    this.isBorder = true,
    this.unReadMessageNumber = 0
  });

  @override
  _MyConversationViewState createState() => _MyConversationViewState();
}

class _MyConversationViewState extends State<MyConversationView> {
  @override
  Widget build(BuildContext context) {
    var row = new Row(
      children: <Widget>[
        new Space(width: mainSpace),
        new Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                widget.title ?? '',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.normal),
              ),
              new SizedBox(height: 2.0),
              new ContentMsg(widget?.content),
            ],
          ),
        ),
        new Space(width: mainSpace),
        new Column(
          children: [
            widget.time,
            new Icon(Icons.flag, color: Colors.transparent),
          ],
        )
      ],
    );

    return new Container(
      padding: EdgeInsets.only(left: 18.0),
      color: Theme.of(context).backgroundColor,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
              alignment: AlignmentDirectional.center,
              children: [
                // Container(
                //     width: ScreenUtil().setWidth(85),
                //     height: ScreenUtil().setWidth(85),
                // child:
                Container(
                  alignment: Alignment.center,
                  width: ScreenUtil().setWidth(85),
                  height: ScreenUtil().setWidth(85),
                  // color: Colors.red,
                  child: new ImageView(
                      img: widget.imageUrl,
                      height: ScreenUtil().setWidth(75),
                      width: ScreenUtil().setWidth(75),
                      fit: BoxFit.cover),
                ),
                // ),
                Visibility(visible: widget.unReadMessageNumber > 0, child:
                Positioned(top: 0, right: 0, child: Container(width: ScreenUtil().setWidth(16), height: ScreenUtil().setWidth(16),  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
                )))
              ]),
          new Container(
            padding: EdgeInsets.only(right: 18.0, top: 12.0, bottom: 12.0),
            width: winWidth(context) - 68,
            decoration: BoxDecoration(
              border: widget.isBorder
                  ? Border(
                      top: BorderSide(color: lineColor, width: 0.2),
                    )
                  : null,
            ),
            child: row,
          )
        ],
      ),
    );
  }
}
