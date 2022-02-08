import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/font.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class TopSearch extends StatefulWidget {
  var type;
  var ishas;
  final onChanged;
  TopSearch({Key key, this.type, this.ishas, @required this.onChanged})
      : super(key: key);
  _TopSearchState createState() => _TopSearchState();
}

class _TopSearchState extends State<TopSearch> {
  var type;
  var ishas;
  var hasNewMessage = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    type = widget.type;
    ishas = widget.ishas;
    getMessageCount();
  }


  Future<void> getMessageCount() async {
    while(true) {
      await Future.delayed(Duration(seconds: 30));
      if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
        var response = await HttpUtil().get(Api.checkMessage);
        if(response['success'] && response['data'] != null) {
          setState(() {
            hasNewMessage = response['data']['hasNewMessage'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(2),
      color: Colors.white,
      child: Container(
        // color: KColor.defaultSearchColor,
        width: ScreenUtil().setWidth(730),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // SizedBox(
            //   // 元素相互之间保持间距 row/column
            //   width: ScreenUtil().setWidth(10),
            // ),
            // InkWell(
            //   onTap: () {
            //     Fluttertoast.showToast(
            //       msg: '功能开发中，敬请期待',
            //       gravity: ToastGravity.CENTER,
            //       // textColor: Colors.grey,
            //     );
            //   },
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(50),
            //     child: Provide<UserStateProvide>(
            //       builder: (BuildContext context, Widget child,
            //           UserStateProvide user) {
            //         if (user.ISLOGIN) {
            //           return Image.network(
            //             KSet.imgOrigin + user.userInfo['icon'],
            //             width: 24,
            //             height: 24,
            //             fit: BoxFit.fill,
            //           );
            //         } else {
            //           return Image.asset(
            //             'assets/images/icon/default.jpg',
            //             width: 25,
            //             height: 25,
            //             fit: BoxFit.fill,
            //           );
            //         }
            //       },
            //     ),
            //   ),
            // ),
            SizedBox(
              // 元素相互之间保持间距 row/column
              width: ScreenUtil().setWidth(10),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Provider.of<UserStateProvide>(context, listen: false)
                      .setSearchHistory();
                  Navigator.pushNamed(context, '/search', arguments: {});
                  // Fluttertoast.showToast(
                  //   msg: '功能开发中，敬请期待',
                  //   gravity: ToastGravity.CENTER,
                  // );
                },
                child: Container(
                  // width: ScreenUtil().setWidth(580),
                  // padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                  height: ScreenUtil().setWidth(50),
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '炒饭超Fun',
                        style: TextStyle(
                            color: KColor.defaultPlaceColor,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              // 元素相互之间保持间距 row/column
              width: ScreenUtil().setWidth(20),
            ),
            Container(
              width: 25,
              height: 25,
              margin: EdgeInsets.only(right: 5),
              child: InkWell(
                onTap: () {
                  if (!Provider.of<UserStateProvide>(context, listen: false)
                      .ISLOGIN) {
                    Fluttertoast.showToast(
                      msg: '打开消息需要先登录',
                      gravity: ToastGravity.CENTER,
                    );
                    return;
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/message',
                    );
                  }
                },
                // child: Icon(Icons.mail_outline),
                child: hasNewMessage ? Image.asset(
                  'assets/images/_icon/message_unread.png',
                  fit: BoxFit.fill,
                ): Image.asset(
                  'assets/images/_icon/message_read.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
