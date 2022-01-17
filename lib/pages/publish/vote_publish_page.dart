import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/publish/desc_widget.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VotePublishPage extends StatefulWidget {
  var arguments;
  VotePublishPage({Key key, this.arguments}) : super(key: key);
  _VotePublishPageState createState() => _VotePublishPageState();
}

class _VotePublishPageState extends State<VotePublishPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _voteController1 = TextEditingController();
  TextEditingController _voteController2 = TextEditingController();
  TextEditingController _voteController3 = TextEditingController();
  TextEditingController _voteController4 = TextEditingController();
  TextEditingController _voteController5 = TextEditingController();
  TextEditingController _voteController6 = TextEditingController();
  String forumId;
  String forumName;
  var isLoading = false;
  bool canSub = true;

  String forumImageName;

  List<Map> voteList = [
    {'optionName': ''},
    {'optionName': ''},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null && widget.arguments['str'] != null) {
      var a = widget.arguments['str'].split('|');
      forumId = a[0];
      forumName = a[1];
      forumImageName = a[2];
    }
  }

  // 既然有监听当然也要有卸载，防止内存泄漏嘛
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: KColor.defaultGrayColor, //修改颜色
          ),
          title: Text(
            '发布投票',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // bottomOpacity: 0,
          elevation: 0, //头部阴影区域高度
          actions: <Widget>[
            _btnPush(context),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                DescWidget(),
                _chooseForum(context),
                _title('标题'),
                _titleInput(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _title('选项'),
                    _pasteContent(),
                  ],
                ),
                _linkInput(),
                // _btnPush(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 标题输入框
  Widget _titleInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _titleController,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        // decoration: InputDecoration.collapsed(hintText: "请输入标题"),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入标题",
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: KColor.defaultGrayColor, width: 1)),
        ),
      ),
    );
  }

  Widget _title(title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
      ),
    );
  }

  // 链接地址
  Widget _linkInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        primary: false, //false，如果内容不足，则用户无法滚动 而如果[primary]为true，它们总是可以尝试滚动。
        shrinkWrap: true, // 内容适配
        itemCount: voteList.length,
        itemBuilder: (c, i) {
          return Container(
            margin: EdgeInsets.only(bottom: 4),
            child: TextField(
              controller: _doController(i + 1),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(34),
              ),
              decoration: InputDecoration(
                hoverColor: Color.fromRGBO(240, 240, 240, 1),
                hintText: "请输入选项" + (i + 1).toString(),
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: KColor.defaultGrayColor, width: 1)),
              ),
            ),
          );
        },
      ),
    );
  }

  _doController(i) {
    switch (i) {
      case 1:
        return _voteController1;
        break;
      case 2:
        return _voteController2;
        break;
      case 3:
        return _voteController3;
        break;
      case 4:
        return _voteController4;
        break;
      case 5:
        return _voteController5;
        break;
      case 6:
        return _voteController6;
        break;
    }
  }

  // 选择版块
  Widget _chooseForum(context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 6),
      child: Ink(
        child: ListTile(
          onTap: () {
            Navigator.push<String>(context,
                new MaterialPageRoute(builder: (BuildContext context) {
              return new ForumListPage();
            })).then((String result) {
              //处理代码
              if (result != null) {
                var a = result.split('|');
                setState(() {
                  forumId = a[0];
                  forumName = a[1];
                  forumImageName = a[2];
                });
              }

              print('页面返回来了');
              print(result);
            });
          },
          title: Text(
            '选择版块',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(34),
            ),
          ),
          contentPadding: EdgeInsets.all(0),
          trailing: forumName == null
              ? Icon(Icons.arrow_forward_ios)
              : Text(
                  forumName + ' >',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(34),
                  ),
                ),
        ),
      ),
    );
  }

  // 粘贴
  Widget _pasteContent() {
    return Container(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: InkWell(
          onTap: () async {
            ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
            // if (data != null) {
            //   _linkController.text = data.text;
            //   print(data.text);
            // }
            if (voteList.length < 6) {
              setState(() {
                voteList.add({'optionName': ''});
              });
            } else {
              // Fluttertoast.showToast(
              //   msg: '最多添加6个选项~',
              //   gravity: ToastGravity.CENTER,
              // );
            }
          },
          child: Text(
            '新增选项',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // 发布按钮
  Widget _btnPush(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14, top: 14, right: 10),
      width: ScreenUtil().setWidth(90),
      height: ScreenUtil().setWidth(30),
      child: MaterialButton(
        color: Colors.pink,
        textColor: Colors.white,
        child: new Text(
          '发布',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        minWidth: ScreenUtil().setWidth(80),
        height: ScreenUtil().setWidth(30),
        padding: EdgeInsets.all(0),
        onPressed: () {
          var title = _titleController.text;
          var length = voteList.length;
          for (var k = 0; k < length; k++) {
            voteList[k]['optionName'] = _doController(k + 1).text;
          }
          bool can = true;
          voteList.forEach((element) {
            if (!(element['optionName'].trim().isNotEmpty)) {
              can = false;
            }
          });
          print('哦哦哦哦哦');
          print(voteList);
          if (forumId != null && title.trim().isNotEmpty && can) {
            if (!isLoading) {
              if (canSub) {
                setState(() {
                  canSub = false;
                });
                toPush(context, forumId, title, voteList);
              } else {
                Fluttertoast.showToast(
                  msg: '请勿重复提交',
                  gravity: ToastGravity.CENTER,
                );
              }
            }
          } else {
            Fluttertoast.showToast(
              msg: '请填写完整哦~',
              gravity: ToastGravity.CENTER,
            );
          }
        },
      ),
    );
  }

  toPush(context, forumId, title, voteList) async {
    setState(() {
      isLoading = true;
    });
    // FormData formdata = FormData.fromMap(
    //     {'forumId': forumId, 'title': title, 'options': json.encode(voteList)});
    var response = await HttpUtil().post(Api.submitVote, queryParameters: {
      'forumId': forumId,
      'title': title,
      'options': json.encode(voteList)
    });
    if (response['success']) {
      setState(() {
        canSub = true;
        isLoading = false;
      });
      Provider.of<UserStateProvide>(context, listen: false)
          .setRemmenberForumList(
              {'id': forumId, 'name': forumName, 'imageName': forumImageName});
      Fluttertoast.showToast(
        msg: '发布成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        canSub = true;
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
