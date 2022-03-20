import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetInfoPage extends StatefulWidget {
  _SetInfoPageState createState() => _SetInfoPageState();
}

class _SetInfoPageState extends State<SetInfoPage> {
  String version;
  TextEditingController _descInputController = TextEditingController();
  TextEditingController _nameInputController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var a = Provider.of<UserStateProvide>(context, listen: false).userInfo;
    _descInputController.value = _descInputController.value.copyWith(
      text: a['desc'],
      composing: TextRange.empty,
    );
    _nameInputController.value = _nameInputController.value.copyWith(
      text: a['userName'],
      composing: TextRange.empty,
    );

    print('-=======');
    print(a);
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
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        brightness: Brightness.light,
        title: Text(
          '修改个人资料',
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
              autofocus: true,
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
                hintText: '请输入你的签名',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),

              textInputAction: TextInputAction.done,
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
          InkWell(
              onTap: () async {
                // if (_inputController.text.trim().isNotEmpty) {
                var res = await HttpUtil().get(Api.changeUserName,
                    parameters: {'userName': _nameInputController.text});
                if (res['success']) {
                  Fluttertoast.showToast(
                    msg: '修改成功',
                    gravity: ToastGravity.CENTER,
                  );
                  var info = Provider.of<UserStateProvide>(context, listen: false).userInfo;
                  info['userName'] = _nameInputController.text;
                  Provider.of<UserStateProvide>(context, listen: false)
                      .changeUserInfo(info);

                } else {
                  Fluttertoast.showToast(
                    msg: res['errorMessage'].toString(),
                    gravity: ToastGravity.CENTER,
                  );
                }
                // } else {
                //   Fluttertoast.showToast(
                //     msg: '请输入你的签名',
                //     gravity: ToastGravity.CENTER,
                //   );
                // }
              }, child:
          Text(
            '确定',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: Color.fromRGBO(53, 140, 255, 1),
            ),
          )),
          Container(
            margin: EdgeInsets.all(20),
            child: TextField(
              // focusNode: _commentFocus,
              autofocus: true,
              controller: _descInputController,
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
                hintText: '请输入你的签名',
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000)),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),

              textInputAction: TextInputAction.done,
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
          InkWell(
              onTap: () async {
                // if (_inputController.text.trim().isNotEmpty) {
                var res = await HttpUtil().get(Api.setDesc,
                    parameters: {'desc': _descInputController.text});
                if (res['success']) {
                  Fluttertoast.showToast(
                    msg: '修改成功',
                    gravity: ToastGravity.CENTER,
                  );
                  var info =
                      Provider.of<UserStateProvide>(context, listen: false)
                          .userInfo;
                  info['desc'] = _descInputController.text;
                  Provider.of<UserStateProvide>(context, listen: false)
                      .changeUserInfo(info);

                  Future.delayed(Duration(milliseconds: 1000)).then((e) {
                    Navigator.pop(context);
                  });
                } else {
                  Fluttertoast.showToast(
                    msg: res['errorMessage'].toString(),
                    gravity: ToastGravity.CENTER,
                  );
                }
                // } else {
                //   Fluttertoast.showToast(
                //     msg: '请输入你的签名',
                //     gravity: ToastGravity.CENTER,
                //   );
                // }
              },
              child: Text(
                '确定',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: Color.fromRGBO(53, 140, 255, 1),
                ),
              )
          )
        ],
      ),
    );
  }
}
