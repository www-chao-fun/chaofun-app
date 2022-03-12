import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/utils/win_media.dart';
import 'package:flutter_chaofan/widget/im/text_span_builder.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_chaofan/config/set.dart';


import 'magic_pop.dart';

class TextItemContainer extends StatefulWidget {
  final String text;
  final String action;
  final bool isMyself;
  final bool isLink;

  TextItemContainer({this.text, this.action, this.isLink = false, this.isMyself = true});

  @override
  _TextItemContainerState createState() => _TextItemContainerState();
}

class _TextItemContainerState extends State<TextItemContainer> {
  TextSpanBuilder _spanBuilder = TextSpanBuilder();

  @override
  Widget build(BuildContext context) {

    if (!widget.isLink) {
      return new MagicPop(
        onValueChanged: (int value) {
          switch (value) {
            case 0:
              Clipboard.setData(new ClipboardData(text: widget.text));
              break;
            case 1:
              //todo 这里要优化
              Fluttertoast.showToast(
                msg: '举报成功',
                gravity: ToastGravity.BOTTOM,
                // textColor: Colors.grey,
              );
              break;
            case 3:
              break;
          }
        },
        pressType: PressType.longPress,
        actions: ['复制', '举报'],
        child: new Container(
          width: widget.text.length > 20
              ? ScreenUtil().screenWidth - 166
              : null,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: widget.isMyself ? Color(0xff98E165) : Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          margin: EdgeInsets.only(right: 7.0),
          child: ExtendedText(
            widget.text ?? '文字为空',
            textWidthBasis: TextWidthBasis.longestLine,
            maxLines: 99,
            overflow: TextOverflow.ellipsis,
            specialTextSpanBuilder: _spanBuilder,
            style: TextStyle(fontSize: 15),
          ),
        ),
      );
    } else {
      return new MagicPop(
        onValueChanged: (int value) {
          switch (value) {
            case 0:
              Clipboard.setData(new ClipboardData(text: widget.text));
              break;
            case 3:
              break;
          }
        },
        pressType: PressType.longPress,
        actions: ['复制'],
        child: new Container(
          width: widget.text.length > 20
              ? ScreenUtil().screenWidth - 166
              : null,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: widget.isMyself ? Color(0xff98E165) : Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          margin: EdgeInsets.only(right: 7.0),
            child: GestureDetector(
              onTap: () {
                print("1234");
                KSet.toNavigate(context, widget.text, '分享的链接');
              },
              child: ExtendedText(
                widget.text ?? '文字为空',
                textWidthBasis: TextWidthBasis.longestLine,
                maxLines: 99,
                overflow: TextOverflow.ellipsis,
                specialTextSpanBuilder: _spanBuilder,
                style: TextStyle(fontSize: 15, color: Color.fromRGBO(36, 64,179, 100)),
              ),
            )),
      );
    }
  }


}
