import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                top: MediaQueryData.fromWindow(window).padding.top, left: 0),
            child: Material(
              // color: Colors.white,
              child: Ink(
                padding: EdgeInsets.all(20),
                child: InkWell(
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: ScreenUtil().setHeight(500),
            // color: Colors.black,
            padding: EdgeInsets.only(top: 40),
            child: Image.asset(
              'assets/images/icon/logo.png',
              width: ScreenUtil().setWidth(240),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: MaterialButton(
              color: Colors.white,
              textColor: Colors.pink,
              child: new Text(
                '验证码登录',
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
              onPressed: () {},
            ),
          ),
          Container(
            child: MaterialButton(
              color: Colors.pink,
              textColor: Colors.white,
              child: new Text(
                '账号密码登录',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  color: Colors.white,
                ),
              ),
              minWidth: ScreenUtil().setWidth(680),
              height: ScreenUtil().setWidth(90),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: Colors.pink),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/accoutlogin');
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 40),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('没有账号？去注册'),
            ),
          ),
        ],
      ),
    );
  }
}
