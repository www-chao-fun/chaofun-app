import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_chaofan/provide/user.dart';
import 'package:provider/provider.dart';

import 'package:r_upgrade/r_upgrade.dart';
import 'package:package_info/package_info.dart';

class BindPhonePage extends StatefulWidget {
  _BindPhonePageState createState() => _BindPhonePageState();
}

class _BindPhonePageState extends State<BindPhonePage> {
  String version;
  var appVersionInfo;

  bool ifdown = false;
  var plat;
  var downpercent = 0.0;

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  FocusNode blankNode = FocusNode();

  String loginType = 'account';
  Timer _timer;
  int _countdownTime = 0;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        brightness: Brightness.light,
        title: Text(
          '绑定手机号',
          style:
              Theme.of(context).textTheme.headline6,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Container(
        child: Column(
          children: [
            _phoneItem(),
            _codeItem(),
            _btnLogin(context),
          ],
        ),
      ),
    );
  }

  Widget _btnLogin(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 50),
      child: MaterialButton(
        elevation: 0,
        color: Colors.pink,
        textColor: Colors.white,
        child: new Text(
          '绑定手机',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
          ),
        ),
        minWidth: ScreenUtil().setWidth(680),
        height: ScreenUtil().setWidth(90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          // side: BorderSide(
          //   color: Color.fromRGBO(204, 204, 204, 1),
          // ),
        ),
        onPressed: () {
          var phone = _phoneController.text;
          var code = _codeController.text;
          if (phone != null && code != null && phone != '' && code != '') {
            RegExp exp = RegExp(r'^1[3-9]\d{9}$');
            bool matched = exp.hasMatch(phone);
            if (matched) {
              toLogin(context, phone, code);
            } else {
              Fluttertoast.showToast(
                msg: '请正确输入手机号',
                gravity: ToastGravity.CENTER,
                // textColor: Colors.grey,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: '请输入手机号和验证码',
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
          }
        },
      ),
    );
  }

  void toLogin(context, phone, code) async {
    // var userInfo =
    //     Provider.of<UserStateProvide>(context, listen: false).userInfo;
    // userInfo['phone'] = phone;
    // Provider.of<UserStateProvide>(context, listen: false)
    //     .changeUserInfo(userInfo);
    // Navigator.pop(context);
    var response = await HttpUtil()
        .get(Api.setPhone, parameters: {'phone': phone, 'code': code});
    // pref.setString('cartInfo', cartString);
    if (response['success']) {
      Fluttertoast.showToast(
        msg: '绑定成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
      var userInfo =
          Provider.of<UserStateProvide>(context, listen: false).userInfo;
      userInfo['phone'] = phone;
      Provider.of<UserStateProvide>(context, listen: false)
          .changeUserInfo(userInfo);
      if (_timer != null) {
        _timer.cancel();
      }
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    }
  }

  Widget _phoneItem() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 64,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _phoneController,
        autofocus: false,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(32),
          // fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, top: 6, bottom: 6),
          // border: OutlineInputBorder(),
          hintText: '手机号',
          prefixIcon: Icon(Icons.phone_android_outlined),
          // suffixIcon: Icon(Icons.remove_red_eye),
          // icon: Icon(Icons.person), // 在输入框外面添加一个 icon
        ),
        // onEditingComplete: () {
        //   print('1231');
        // },
        toolbarOptions:
            ToolbarOptions(copy: true, cut: true, paste: true, selectAll: true),

        // onTap: () {
        //   FocusScope.of(context).requestFocus(FocusNode());
        // },
        // onAppPrivateCommand: (, ) {

        // },
      ),
    );
  }

  Widget _codeItem() {
    return Container(
      height: 70,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextField(
              controller: _codeController,
              autofocus: false,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                // fontWeight: FontWeight.bold,
              ),
              //           inputDecorationTheme: InputDecorationTheme(
              //   border: OutlineInputBorder(
              //     borderSide: BorderSide(color: kYellow)
              //   ),
              //   labelStyle: TextStyle(
              //     color: kYellow,
              //     fontSize: 24.0
              //   ),
              // ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10, top: 10, bottom: 6),
                // border: OutlineInputBorder(),
                hintText: '验证码',
                prefixIcon: Icon(Icons.code_outlined),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Color(0xffFD3F2A), width: 1),
                // ),
                // suffixIcon: Icon(Icons.remove_red_eye),
                // icon: Icon(Icons.person), // 在输入框外面添加一个 icon
              ),
              // onEditingComplete: () {
              //   print('1231');
              // },
              toolbarOptions: ToolbarOptions(
                  copy: true, cut: true, paste: true, selectAll: true),

              // onTap: () {
              //   FocusScope.of(context).requestFocus(FocusNode());
              // },
              // onAppPrivateCommand: (, ) {

              // },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () async {
              RegExp exp = RegExp(r'^1[3-9]\d{9}$');
              bool matched = exp.hasMatch(_phoneController.text);
              if (_countdownTime == 0) {
                if (matched) {
                  var res = await HttpUtil().get(Api.getCode,
                      parameters: {'phone': _phoneController.text});
                  if (res['success']) {
                    Fluttertoast.showToast(
                      msg: '验证码发送成功',
                      gravity: ToastGravity.CENTER,
                      // textColor: Colors.grey,
                    );
                    const timeout = const Duration(seconds: 1);
                    if (_timer != null) {
                      _timer.cancel();
                    }
                    setState(() {
                      _countdownTime = 60;

                      _timer = Timer.periodic(timeout, (timer) {
                        //callback function
                        //1s 回调一次
                        print('afterTimer=' + DateTime.now().toString());
                        setState(() {
                          if (_countdownTime < 1) {
                            _timer.cancel();
                          } else {
                            _countdownTime = _countdownTime - 1;
                          }
                        });
                        // timer.cancel(); // 取消定时器
                      });
                    });
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: '请输入正确的手机号',
                    gravity: ToastGravity.CENTER,
                    // textColor: Colors.grey,
                  );
                }
              }
            },
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 12),
              width: ScreenUtil().setWidth(210),
              height: ScreenUtil().setWidth(90),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 0.5,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Text(
                _countdownTime == 0 ? '发送验证码' : _countdownTime.toString() + 's',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
