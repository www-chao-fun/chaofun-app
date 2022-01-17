import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForumApplyPage extends StatefulWidget {
  String forumName;
  ForumApplyPage({Key key, this.forumName}) : super(key: key);
  _ForumApplyPageState createState() => _ForumApplyPageState();
}

class _ForumApplyPageState extends State<ForumApplyPage> {
  String version;
  TextEditingController _nameInputController = TextEditingController();
  TextEditingController _reasonInputController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _nameInputController.text = widget.forumName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: KColor.defaultGrayColor,
              size: 20,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(bottom: 12, top: 12, right: 20),
            // width: ScreenUtil().setWidth(140),
            // height: ScreenUtil().setWidth(20),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () async {
                if (_nameInputController.text.trim().isNotEmpty && _reasonInputController.text.trim().isNotEmpty) {
                  var res = await HttpUtil().get(Api.applyForum,
                      parameters: {'name': _nameInputController.text, 'reason': _reasonInputController.text});
                  if (res['success']) {
                    Fluttertoast.showToast(
                      msg: '申请新建板块成功',
                      gravity: ToastGravity.CENTER,
                    );
                    Future.delayed(Duration(milliseconds: 1500)).then((e) {
                      Navigator.pop(context, null);
                    });
                  } else {

                  }
                } else {
                  Fluttertoast.showToast(msg: '申请板块名称或者理由不能为空', toastLength: Toast.LENGTH_LONG);
                }
              },
              child: Text(
                '申请',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: Color.fromRGBO(53, 140, 255, 1),
                ),
              ),
            ),
          )
        ],
        brightness: Brightness.light,
        title: Text(
          '新建版块申请',
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(34)),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: TextField(
              // focusNode: _commentFocus,
              // autofocus: true,
              controller: _nameInputController,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                fillColor: Color(0x30cccccc),
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00FF0000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: '请输入板块名称',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),

              textInputAction: TextInputAction.send,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                // fontWeight: FontWeight.bold,
              ),
              onChanged: (val) {
                print('旧值');
              },

              onSubmitted: (term) async {
                print(term);
              },
            ),
          ),

          Container(
            margin: EdgeInsets.all(20),
            child: TextField(
              // focusNode: _commentFocus,
              autofocus: true,
              controller: _reasonInputController,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                fillColor: Color(0x30cccccc),
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00FF0000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintText: '请输入申请理由',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),

              textInputAction: TextInputAction.send,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                // fontWeight: FontWeight.bold,
              ),
              onChanged: (val) {
                print('旧值');
              },

              onSubmitted: (term) async {
                print(term);
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 5),
            child:Text('申请后，如有结果，会接受到通知，也可私聊 cijianzy 咨询申请进度，如果账号贡献程度高，会自动设置为版主')),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameInputController.dispose();
    _reasonInputController.dispose();
    super.dispose();
  }
}
