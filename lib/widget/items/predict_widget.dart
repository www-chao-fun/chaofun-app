import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PredictWidget extends StatefulWidget {
  var item;
  var type;
  Function toDou;
  PredictWidget({Key key, this.item, this.type, this.toDou}) : super(key: key);
  _PredictWidgetState createState() => _PredictWidgetState();
}

class _PredictWidgetState extends State<PredictWidget> {
  var item;
  var chooseItem;
  var chooseIndex;
  var userData;
  TextEditingController _inputController = TextEditingController();
  @override
  void initState() {
    item = widget.item;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 30, 14, 20),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setWidth(410 + item['options'].length * 90),
      constraints: BoxConstraints(
        // minWidth: 180,
        maxHeight: ScreenUtil().setWidth(1200),
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromRGBO(8, 6, 30, 0.7),
        Color.fromRGBO(19, 31, 62, 1),
      ])
          // border: Border(
          //   top: BorderSide(
          //     width: 0.5,
          //     color: KColor.defaultBorderColor,
          //   ),
          // ),
          ),
      child: Column(
        children: [
          // SizedBox(
          //   width: ScreenUtil().setWidth(40),
          // ),
          Container(
            width: ScreenUtil().setWidth(560),
            height: ScreenUtil().setWidth(160),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                doState(),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      width: ScreenUtil().setWidth(240),
                      child: Text(
                        '总下注：' + item['predictionTotalTokens'].toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Color.fromRGBO(53, 53, 53, 1),
                        ),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(240),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '参与：' + item['optionVoteCount'].toString(),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Color.fromRGBO(53, 53, 53, 1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      width: ScreenUtil().setWidth(240),
                      child: Text(
                        '状态：' + (item['chooseOption'] == null ? '未竞猜' : '已竞猜'),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: item['chooseOption'] == null
                              ? Colors.black
                              : Color.fromRGBO(7, 193, 96, 1),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: ScreenUtil().setWidth(240),
                      child: Text(
                        '收益：' +
                            (item['predictedWins'] == null
                                ? '--'
                                : item['predictedWins'].toString()),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Color.fromRGBO(53, 53, 53, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(40),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _doList(),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(40),
          ),
        ],
      ),
    );
  }

  List _doList() {
    List<Widget> arr = [];
    for (var key = 0; key < item['options'].length; key++) {
      var Element = item['options'][key];
      arr.add(
        Container(
          height: ScreenUtil().setWidth(110),
          child: Stack(
            children: [
              SizedBox(
                height: 14,
              ),
              checkoutVote()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: ScreenUtil().setWidth(80),
                        width: ScreenUtil().setWidth(750),
                        child: LinearProgressIndicator(
                          value: Element['width'] == 0 &&
                                  item['predictionRightOption'] == key + 1
                              ? 1
                              : double.parse(
                                  (Element['width'] / 100).toStringAsFixed(2)),
                          color: item['predictionRightOption'] == key + 1
                              ? Color.fromRGBO(7, 193, 96, 1)
                              : Color.fromRGBO(152, 152, 152, 0.5),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    )
                  : Container(
                      height: 0,
                    ),
              //gradient:
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 14,
                child: Container(
                  width: ScreenUtil().setWidth(750),
                  alignment: Alignment.center,
                  height: ScreenUtil().setWidth(70),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.white,
                    ),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(40)),
                  ),
                  child: Row(
                    children: [
                      checkoutVote()
                          ? Container(
                              alignment: Alignment.center,
                              // color: Colors.white,
                              width: ScreenUtil().setWidth(100),
                              child: Text(
                                Element['optionVote']
                                    .toString(), //Element['width'].toStringAsFixed(0) + '%',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(26),
                                  color: Colors.white,
                                ),
                              ))
                          : Container(
                          alignment: Alignment.center,
                          // color: Colors.white,
                          width: ScreenUtil().setWidth(100),
                          child: Text(
                            ' ', //Element['width'].toStringAsFixed(0) + '%',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              color: Colors.white,
                            ),
                          )),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              Element['optionName'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () async {
                            doTap(key, Element);
                          },
                        ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(100),
                        child: item['chooseOption'] == key + 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      item['predictedTokens'] == null? '0' : item['predictedTokens'].toString(),
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(24),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/_icon/succ.png',
                                    width: ScreenUtil().setWidth(34),
                                    height: ScreenUtil().setWidth(34),
                                  )
                                ],
                              )
                            : Text(''),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return arr;
  }

  doState() {
    switch (item['predictionStatus']) {
      case 'live':
        return Container(
          child: Text(
            '竞猜进行中',
            style: TextStyle(),
          ),
        );
        break;
      case 'pause':
        return Container(
          child: Text(
            '比赛中（停止竞猜）',
            style: TextStyle(
              color: KColor.primaryColor,
            ),
          ),
        );
        break;
      case 'end':
        return Container(
          child: Text(
            '竞猜结束',
            style: TextStyle(
              color: Color.fromRGBO(177, 177, 177, 1),
            ),
          ),
        );

        break;
    }
  }

  doTap(key, Element) async {
    if (item['chooseOption'] == null && item['predictionStatus'] == 'live') {
      var res = await HttpUtil().get(Api.checkJoin, parameters: {
        'predictionsTournamentId': item['predictionsTournament']['id']
      });
      if (res['data'] == null) {
        var res1 = await HttpUtil().get(Api.predictJoin, parameters: {
          'predictionsTournamentId': item['predictionsTournament']['id'],
        });
        if (res1['success']) {
          Fluttertoast.showToast(
            msg: '欢迎加入竞猜活动，竞猜活动会初始分配给你初始积分，Enjoy!!!',
            gravity: ToastGravity.CENTER,
            // textColor: Colors.grey,
          );
          doTap(key, Element);
        } else {
          Fluttertoast.showToast(
            msg: '加入活动失败',
            gravity: ToastGravity.CENTER,
            // textColor: Colors.grey,
          );
        }

      } else {
        setState(() {
          userData = res['data'];
        });
        showModels(key, Element, this.context);
      }
    }
  }

  showModels(key, Element, context) {
    setState(() {
      chooseItem = Element;
      chooseIndex = key;
    });
    _inputController.value = _inputController.value.copyWith(
      text: '10',
      composing: TextRange.empty,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,

          // padding: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          // ), // 我们可以根据这个获取需要的padding
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 280,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    item['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '你选择的是：',
                    style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1),
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    chooseItem['optionName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(34),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          doNums('-');
                        },
                        child: Image.asset(
                          'assets/images/_icon/reduce.png',
                          width: ScreenUtil().setWidth(70),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: ScreenUtil().setWidth(210),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          autofocus: false,
                          controller: _inputController,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
// FilteringTextInputFormatter.digitsOnly,//数字，只能是整数
                            FilteringTextInputFormatter.allow(
                                RegExp("[0-9]")), //数字包括小数
                            // FilteringTextInputFormatter
                            //     .allow(RegExp(
                            //         "[a-zA-Z]")), //只允许输入字母
                          ],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                left: 14, top: 10, right: 14, bottom: 10),
                            fillColor: Color(0x30cccccc),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x00FF0000)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            hintText: '0',
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x00000000)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                          textInputAction: TextInputAction.send,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(34),
                          ),
                          onChanged: (val) {
                            print('旧值');
                          },
                          onSubmitted: (term) async {},
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          doNums('+');
                        },
                        child: Image.asset(
                          'assets/images/_icon/add.png',
                          width: ScreenUtil().setWidth(74),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '剩余积分：' + userData['restTokens'].toString(),
                      style: TextStyle(
                        color: Color.fromRGBO(153, 153, 153, 1),
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 0, top: 0),
                  child: MaterialButton(
                    color: KColor.primaryColor,
                    textColor: Colors.white,
                    child: new Text(
                      '确定',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                    minWidth: ScreenUtil().setWidth(680),
                    height: ScreenUtil().setWidth(90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.pink),
                    ),
                    onPressed: () async {
                      var params = {
                        'postId': item['postId'],
                        'option': key + 1,
                        'tokens': _inputController.text
                      };
                      var res =
                          await HttpUtil().get(Api.toVote, parameters: params);
                      if (res['success']) {
                        Fluttertoast.showToast(
                          msg: '竞猜成功',
                          gravity: ToastGravity.CENTER,
                          // textColor: Colors.grey,
                        );
                        var res1 = await HttpUtil().get(Api.getPostInfo,
                            parameters: {'postId': item['postId']});
                        setState(() {
                          item = res1['data'];
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  doNums(v) {
    if (v == '-') {
      var str = int.parse(_inputController.text);
      if (str - 10 < 0) {
        _inputController.value = _inputController.value.copyWith(
          text: '10',
          composing: TextRange.empty,
        );
      } else {
        _inputController.value = _inputController.value.copyWith(
          text: (str - 10).toStringAsFixed(0),
          composing: TextRange.empty,
        );
      }
    } else {
      var str = int.parse(_inputController.text);
      if (str + 10 > userData['restTokens']) {
        _inputController.value = _inputController.value.copyWith(
          text: userData['restTokens'].toString(),
          composing: TextRange.empty,
        );
      } else {
        _inputController.value = _inputController.value.copyWith(
          text: (str + 10).toStringAsFixed(0),
          composing: TextRange.empty,
        );
      }
    }
  }

  checkoutVote() {
    var a = false;
    item['options'].forEach((it) {
      if (it['optionVote'] != null) {
        a = true;
      }
    });
    return a;
  }

  formatNum(double num, int postion) {
    print(num);
    var str;
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <
        postion) {
      //小数点后有几位小数
      print(num.toStringAsFixed(postion)
          .substring(0, num.toString().lastIndexOf(".") + postion + 1)
          .toString());
      str = num.toStringAsFixed(postion)
          .substring(0, num.toString().lastIndexOf(".") + postion + 1)
          .toString();
    } else {
      print(num.toString()
          .substring(0, num.toString().lastIndexOf(".") + postion + 1)
          .toString());
      str = num.toString()
          .substring(0, num.toString().lastIndexOf(".") + postion + 1)
          .toString();
    }
    return str;
  }
}
