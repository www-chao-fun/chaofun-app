import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/widget/items/save_flow_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:fluttertoast/fluttertoast.dart' hide Toast;

class BottomWidget extends StatefulWidget {
  var item;
  var type;
  Function toDou;
  BottomWidget({Key key, this.item, this.type, this.toDou}) : super(key: key);
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  var item;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  static const MethodChannel _mainChannel =
      const MethodChannel('app.chao.fun/main_channel');

  @override
  Widget build(BuildContext context) {
    item = widget.item;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      width: ScreenUtil().setWidth(750),
      decoration: BoxDecoration(
        // border: Border(
        //   top: BorderSide(
        //     width: 0.5,
        //     color: KColor.defaultBorderColor,
        //   ),
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: _updown(),
            flex: 1,
          ),
          Expanded(
            child: _commentItem(context),
            flex: 1,
          ),
          Expanded(
            child: _shareItem(),
            flex: 1,
          ),
          Expanded(
            child: _loveItem(context),
            flex: 1,
          ),
        ],
      ),
    );
  }

  // 点赞
  Widget _updown() {
    return Container(
      height: ScreenUtil().setHeight(60),
      // color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () async {
                if (item['vote'] == 1) {
                  setState(() {
                    item['ups'] = item['ups'] - 1;
                    item['vote'] = 0;
                  });
                } else if (item['vote'] == 0) {
                  setState(() {
                    item['ups'] = item['ups'] + 1;
                    item['vote'] = 1;
                  });
                } else if (item['vote'] == -1) {
                  setState(() {
                    item['ups'] = item['ups'] + 2;
                    item['vote'] = 1;
                  });
                }
                var response = await HttpUtil().get(Api.upvotePost,
                    parameters: {'postId': item['postId']});
              },
              child: Container(
                height: ScreenUtil().setWidth(60),
                width: ScreenUtil().setWidth(60),
                // color: Colors.red,
                padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(14),
                  bottom: ScreenUtil().setWidth(14),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 0, right: 0),
                  child: Image.asset(
                    item['vote'] == 1
                        ? 'assets/images/_icon/up_active.png'
                        : 'assets/images/_icon/zan.png',
                    width: ScreenUtil().setWidth(28),
                    height: ScreenUtil().setWidth(28),
                    // height: ScreenUtil().setHeight(60),
                  ),
                ),
              ),
            ),
          ),
          Container(
            // padding: EdgeInsets.only(left: 10, right: 10),
            child: Text((item['ups'] - item['downs']).toString(),
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                if (item['vote'] == 1) {
                  setState(() {
                    item['ups'] = item['ups'] - 2;
                    item['vote'] = -1;
                  });
                } else if (item['vote'] == 0) {
                  setState(() {
                    item['ups'] = item['ups'] - 1;
                    item['vote'] = -1;
                  });
                } else if (item['vote'] == -1) {
                  setState(() {
                    item['ups'] = item['ups'] + 1;
                    item['vote'] = 0;
                  });
                }
                var response = await HttpUtil().get(Api.downvotePost,
                    parameters: {'postId': item['postId']});
              },
              child: Container(
                // padding: EdgeInsets.only(left: 10),
                // width: 40,
                height: ScreenUtil().setWidth(60),
                width: ScreenUtil().setWidth(60),
                // color: Colors.red,
                padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(14),
                  bottom: ScreenUtil().setWidth(14),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 0, right: 0),
                  child: Image.asset(
                    item['vote'] == -1
                        ? 'assets/images/_icon/down_active.png'
                        : 'assets/images/_icon/cai.png',
                    width: ScreenUtil().setWidth(28),
                    height: ScreenUtil().setWidth(28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 评论
  Widget _commentItem(context) {
    return InkWell(
      onTap: () {
        if (widget.type == '1') {
          widget.toDou();
        } else {
          Navigator.pushNamed(
            context,
            '/postdetail',
            arguments: {"postId": item['postId'].toString()},
          );
        }
      },
      child: Container(
        width: ScreenUtil().setWidth(120),
        height: ScreenUtil().setHeight(40),
        // color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              KAsset.commentIcon,
              width: 16,
              height: 16,
            ),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                item['comments'].toString() == '0'
                    ? '评论'
                    : item['comments'].toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 转发
  Widget _shareItem() {
    return InkWell(
      onTap: () {
        _mainChannel.invokeMethod("share", item);
      },
      child: Container(
        width: ScreenUtil().setWidth(120),
        height: ScreenUtil().setHeight(40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              KAsset.shareIcon,
              width: 16,
              height: 16,
            ),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '分享',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 收藏
  Widget _loveItem(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Toast.show(context);
        setState(() {
          item['save'] = !item['save'];
        });
        Fluttertoast.showToast(
          msg: item['save'] ? '收藏成功' : '已取消收藏',
          gravity: ToastGravity.CENTER,
          // textColor: Colors.grey,
        );
        var response = await HttpUtil()
            .get(Api.savePost, parameters: {'postId': item['postId']});
      },
      child: Container(
        width: ScreenUtil().setWidth(120),
        height: ScreenUtil().setHeight(40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              item['save']
                  ? 'assets/images/_icon/collect2.png'
                  : KAsset.loveIcon,
              width: ScreenUtil().setWidth(30),
            ),
            Container(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '收藏',
                style: item['save']
                    ? TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        color: Color.fromRGBO(255, 147, 0, 1),
                      )
                    : Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
