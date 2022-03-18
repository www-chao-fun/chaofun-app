import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/common/customNavgator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://www.baidu.com';

class VoteWidget extends StatefulWidget {
  var item;
  VoteWidget({Key key, this.item}) : super(key: key);

  @override
  _VoteWidgetState createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  var item;
  var _radioGroupValue = null;
  @override
  void initState() {
    item = widget.item;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(item['postId'].toString()),
      // color: Color.fromRGBO(255, 244, 230, 1),
      // color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        top: 0,
        bottom: ScreenUtil().setHeight(0),
      ),
      margin: EdgeInsets.only(top: 0, bottom: 0),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(68),
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.only(left: 0),
            // color: Color.fromRGBO(255, 233, 204, 1),
            color:Theme.of(context).backgroundColor,
            margin: EdgeInsets.only(bottom: 0, top: 0),
            child: Row(
              children: [
                Text(
                  '投票：' + item['optionVoteCount'].toString() + '人',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: Theme.of(context).textTheme.titleLarge.color
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(80),
                ),
                Text(
                  '围观：' + item['circuseeCount'].toString() + '人',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: Theme.of(context).textTheme.titleLarge.color,
                  ),
                ),
              ],
            ),
          ),
          _doWhich(),
          _canChoose()
              ? Container(
                  height: 10,
                )
              : _btnGroup()
        ],
      ),
    );
  }

  bool _canChoose() {
    bool can = false;
    item['options'].forEach((it) {
      if (it['optionVote'] != null) {
        can = true;
      }
    });
    return can;
  }

  Widget _btnGroup() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MaterialButton(
            elevation: 0,
            color: Color.fromRGBO(255, 147, 0, 1),
            textColor: Theme.of(context).textTheme.titleLarge.color,
            child: new Text(
              '投票',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
              ),
            ),
            minWidth: ScreenUtil().setWidth(250),
            height: ScreenUtil().setWidth(70),
            padding: EdgeInsets.all(0),
            onPressed: () async {
              if (Provider.of<UserStateProvide>(context, listen: false)
                  .ISLOGIN) {
                // FocusScope.of(context).requestFocus(_commentFocus);
                if (_radioGroupValue != null) {
                  var params = {
                    "postId": item['postId'],
                    "option": _radioGroupValue,
                  };
                  var data =
                      await HttpUtil().get(Api.toVote, parameters: params);
                  if (data['success']) {
                    var response = await HttpUtil().get(Api.getPostInfo,
                        parameters: {'postId': item['postId']});
                    setState(() {
                      item = response['data'];
                    });
                  }
                }
              } else {
                Navigator.pushNamed(
                  context,
                  '/accoutlogin',
                  arguments: {"from": 'from'},
                );
              }
            },
          ),
          MaterialButton(
            elevation: 0,
            color: Colors.white,
            textColor: Colors.black,
            child: new Text(
              '围观',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
              ),
            ),
            minWidth: ScreenUtil().setWidth(250),
            height: ScreenUtil().setWidth(70),
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              // borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(
                color: Color.fromRGBO(255, 147, 0, 1),
              ),
            ),
            onPressed: () async {
              if (Provider.of<UserStateProvide>(context, listen: false)
                  .ISLOGIN) {
                var params = {
                  "postId": item['postId'],
                };
                var data =
                    await HttpUtil().get(Api.toCircusee, parameters: params);
                if (data['success']) {
                  var response = await HttpUtil().get(Api.getPostInfo,
                      parameters: {'postId': item['postId']});
                  setState(() {
                    item = response['data'];
                  });
                }
              } else {
                Navigator.pushNamed(
                  context,
                  '/accoutlogin',
                  arguments: {"from": 'from'},
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _doList() {
    List<Widget> arr = [];
    for (var key = 0; key < item['options'].length; key++) {
      if (_canChoose()) {
        arr.add(_chooseLine(key + 1));
      } else {
        arr.add(_radioLine(key + 1));
        // return _radioLine(key + 1);
      }
    }
    return arr;
  }

  Widget _doWhich() {
    // if (_canChoose()) {
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(0),
        right: ScreenUtil().setWidth(0),
        top: 10,
      ),
      // color: Colors.blue,
      // height: 10,
      child: Column(
        children: _doList(),
      ),
      // child: ListView.builder(
      //   physics: NeverScrollableScrollPhysics(),
      //   primary: false, //false，如果内容不足，则用户无法滚动 而如果[primary]为true，它们总是可以尝试滚动。
      //   shrinkWrap: true, // 内容适配
      //   itemBuilder: (c, i) {
      //     if (i == 0) {
      //       return Container(
      //         height: ScreenUtil().setWidth(88),
      //         padding: EdgeInsets.only(left: 10),
      //         color: Color.fromRGBO(255, 233, 204, 1),
      //         margin: EdgeInsets.only(bottom: 14, top: 0),
      //         child: Row(
      //           children: [
      //             Text(
      //               '投票：' + item['optionVoteCount'].toString() + '人',
      //               style: TextStyle(
      //                 fontSize: ScreenUtil().setSp(28),
      //                 color: Color.fromRGBO(33, 29, 47, 1),
      //               ),
      //             ),
      //             SizedBox(
      //               width: ScreenUtil().setWidth(80),
      //             ),
      //             Text(
      //               '围观：' + item['circuseeCount'].toString() + '人',
      //               style: TextStyle(
      //                 fontSize: ScreenUtil().setSp(28),
      //                 color: Color.fromRGBO(33, 29, 47, 1),
      //               ),
      //             ),
      //           ],
      //         ),
      //       );
      //     } else {
      //       // return Text(item['options'][i - 1]['optionName']);
      //       if (_canChoose()) {
      //         return _chooseLine(i);
      //       } else {
      //         return _radioLine(i);
      //       }

      //       // return Text('999');
      //     }
      //   },
      //   // itemExtent: 100.0,
      //   itemCount: item['options'].length + 1,
      // ),
    );
    // } else {
    //   return Container(
    //     child: Text('123'),
    //   );
    // }
  }

  _chooseLine(i) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 10,
          child: Container(
            color: Color.fromRGBO(255, 188, 93, 1),
            width: ScreenUtil().setWidth(
              670 *
                  (item['options'][i - 1]['optionVote'] /
                      item['optionVoteCount']),
            ),
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(750),
          // height: ScreenUtil().setWidth(80),
          margin: EdgeInsets.only(
            bottom: 10,
            left: 0,
            right: 10,
          ),
          padding: EdgeInsets.only(left: 12, right: 8, top: 14, bottom: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              width: 0.5,
              color: Color.fromRGBO(255, 188, 93, 1),
            ),
          ),
          child: RichText(
            text: TextSpan(
              text: item['options'][i - 1]['optionVote'].toString(),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge.color,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '  ',
                ),
                TextSpan(
                  text: item['options'][i - 1]['optionName'],
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: ScreenUtil().setSp(26),
                  ),
                ),
              ],
            ),
          ),
        ),
        item['chooseOption'] == i
            ? Positioned(
                right: 14,
                top: 0,
                bottom: 10,
                child: Image.asset(
                  'assets/images/_icon/success.png',
                  width: ScreenUtil().setWidth(36),
                  height: ScreenUtil().setWidth(36),
                ),
              )
            : Container(height: 0),
      ],
    );
  }

  _radioLine(i) {
    return Container(
      width: ScreenUtil().setWidth(750),
      // height: ScreenUtil().setWidth(80),
      margin: EdgeInsets.only(
        bottom: 10,
        left: 0,
        right: 0,
      ),
      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: _radioGroupValue == i
            ? Color.fromRGBO(255, 188, 93, 0.7)
            : Colors.transparent,
        border: Border.all(
          width: 0.5,
          color: Color.fromRGBO(255, 188, 93, 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _radioGroupValue = i;
          });
        },
        child: Row(
          children: [
            Radio(
              activeColor: Color.fromRGBO(255, 147, 0, 1),
              value: i,
              groupValue: _radioGroupValue,
              onChanged: (value) {
                setState(() {
                  _radioGroupValue = value;
                });
              },
            ),
            Expanded(
              child: Text(
                item['options'][i - 1]['optionName'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    item = null;
  }
}
