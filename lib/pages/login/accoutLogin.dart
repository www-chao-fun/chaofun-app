import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chaofan/database/userHelper.dart';

class AccoutLoginPage extends StatefulWidget {
  var arguments;
  AccoutLoginPage({Key key, this.arguments}) : super(key: key);
  _AccoutLoginPageState createState() => _AccoutLoginPageState();
}

class _AccoutLoginPageState extends State<AccoutLoginPage> {
  TextEditingController _inputController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  FocusNode blankNode = FocusNode();
  var db = UserHelper();
  var from;
  var pref;
  bool _isShow = true;
  String loginType = 'account';
  Timer _timer;
  int _countdownTime = 0;
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      from = widget.arguments['from'];
      print('from${from}');
    }

    prs();
    setState(() {
      // _inputController;
    });
  }

  void prs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pref = prefs;
    });
  }
  // 定义 controller

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        blankNode.unfocus();
      },
      child: Scaffold(
        // backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      top: MediaQueryData.fromWindow(window).padding.top,
                      left: 0,
                      right: 0,
                    ),
                    child: _topNav(),
                  ),
                  // Container(
                  //   alignment: Alignment.center,
                  //   height: ScreenUtil().setHeight(350),
                  //   // color: Colors.black,
                  //   padding: EdgeInsets.only(bottom: 40),
                  //   child: Image.asset(
                  //     'assets/images/icon/logo.png',
                  //     width: ScreenUtil().setWidth(240),
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20, bottom: 20, top: 50),
                    child: Text(
                      loginType == 'account' ? '密码登录' : '短信登录',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(38),
                      ),
                    ),
                  ),
                  loginType == 'account' ? _loginItem() : _phoneItem(),
                  loginType == 'account' ? _passwordItem() : _codeItem(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (loginType == 'phone') {
                            loginType = 'account';
                          } else {
                            loginType = 'phone';
                          }
                        });
                      },
                      child: Text(
                        loginType == 'account' ? '短信登录' : '密码登录',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  _btnLogin(context),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 40),
                    // color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        '没有账号？去注册',
                        style: TextStyle(color: KColor.defaultLinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnLogin(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 50),
      child: MaterialButton(
        color: Colors.pink,
        textColor: Colors.white,
        child: new Text(
          '登录',
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
        onPressed: () {
          if (loginType == 'account') {
            var accout = _inputController.text;
            var pwd = _passwordController.text;
            if (accout != null && pwd != null && accout != '' && pwd != '') {
              toLogin(context, accout, pwd);
            } else {
              Fluttertoast.showToast(
                msg: '请输入用户名或密码',
                gravity: ToastGravity.CENTER,
                // textColor: Colors.grey,
              );
            }
          } else {
            var phone = _phoneController.text;
            var code = _codeController.text;
            if (phone != null && code != null && phone != '' && code != '') {
              toLogin(context, phone, code);
            } else {
              Fluttertoast.showToast(
                msg: '请输入手机号和验证码',
                gravity: ToastGravity.CENTER,
                // textColor: Colors.grey,
              );
            }
          }
        },
      ),
    );
  }

  void toLogin(context, accout, pwd) async {
    var response;
    if (loginType == 'account') {
      response = await HttpUtil().get(Api.userAccountLogin,
          parameters: {'userName': accout, 'password': pwd});
    } else {
      response = await HttpUtil()
          .get(Api.phoneLogin, parameters: {'phone': accout, 'code': pwd});
    }
    // pref.setString('cartInfo', cartString);
    if (response['success']) {
      Provider.of<UserStateProvide>(context, listen: false).changeState(true);
      await db.clear('table_user');
      await db.clear('All_page');
      await db.clear('table_addjoin');
      Fluttertoast.showToast(
        msg: '登录成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );

      if (from != null) {
        // Provider.of<UserStateProvide>(context).changeState(true);

        getUserInfo(context);
      } else {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => IndexPage()),
            (route) => route == null,
          );
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    }
  }

  void getUserInfo(context) async {
    var response = await HttpUtil().get(Api.getUserInfo);
    print(response);
    if (response['data'] != null) {
      Provider.of<UserStateProvide>(context, listen: false).changeState(true);
      Provider.of<UserStateProvide>(context, listen: false)
          .changeUserInfo(response['data']);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {}
  }

  Widget _loginItem() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 64,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _inputController,
        autofocus: false,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(32),
          // fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, top: 6, bottom: 6),
          // border: OutlineInputBorder(),
          hintText: '用户名/手机号',
          prefixIcon: Icon(Icons.person),
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

  Widget _passwordItem() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 70,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _passwordController,
        obscureText: _isShow,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(32),
          // fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 10,
            top: 6,
            bottom: 6,
            right: 0,
          ),
          hintText: '请输入密码',
          prefixIcon: Icon(Icons.lock),
          suffix: GestureDetector(
            onTap: _showPassword,
            child: Icon(
              Icons.remove_red_eye,
              color: !_isShow ? Colors.red : Colors.grey,
            ),
          ),
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(28), //边角为30
          //   ),
          //   borderSide: BorderSide(
          //     color: Colors.amber, //边线颜色为黄色
          //     width: 2, //边线宽度为2
          //   ),
          // ),
        ),
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

  void _showPassword() {
    setState(() {
      _isShow = !_isShow;
    });
  }

  Widget _topNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
            // color: Colors.white,
            padding: EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                // Navigator.pop(context);
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: KColor.defaultGrayColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}
