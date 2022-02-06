import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chaofan/database/userHelper.dart';

class RegisterPage extends StatefulWidget {
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _inputController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  FocusNode blankNode = FocusNode();
  var db = UserHelper();
  bool check = false;
  var pref;
  bool _isShow = true;
  bool _checkValue = false;

  String loginType = 'account';
  Timer _timer;
  int _countdownTime = 0;
  ClipboardData data = null;


  void initState() {
    super.initState();
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

    data = await Clipboard.getData('text/plain');
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
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
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20, bottom: 20, top: 50),
                      child: Text(
                        '注册账号',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(36),
                        ),
                      ),
                    ),
                    _loginItem(),
                    _passwordItem(),
                    // _checkBox(),
                    _phoneItem(),
                    _codeItem(),
                    _xieyi(),
                    _btnLogin(context),
                  ],
                ),
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
        color: _checkValue ? Colors.pink : Color.fromRGBO(204, 204, 204, 1),
        textColor: Colors.white,
        child: new Text(
          '注册',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
          ),
        ),
        minWidth: ScreenUtil().setWidth(680),
        height: ScreenUtil().setWidth(90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: _checkValue ? Colors.pink : Color.fromRGBO(204, 204, 204, 1),
          ),
        ),
        onPressed: () {
          if (_checkValue) {
            var accout = _inputController.text;
            var pwd = _passwordController.text;
            var phone = _phoneController.text;
            var code = _codeController.text;
            if (accout != null && pwd != null && accout != '' && pwd != '') {
              if (phone != null && code != null && phone != '' && code != '') {
                RegExp exp = RegExp(r'^1[3-9]\d{9}$');
                bool matched = exp.hasMatch(phone);
                if (matched) {
                  toLogin(context, accout, pwd, phone, code);
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
            } else {
              Fluttertoast.showToast(
                msg: '请输入用户名或密码',
                gravity: ToastGravity.CENTER,
                // textColor: Colors.grey,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: '请阅读并勾选《用户协议及隐私政策》',
              gravity: ToastGravity.BOTTOM,
              // textColor: Colors.grey,
            );
          }
        },
      ),
    );
  }

  void toLogin(context, accout, pwd, phone, code) async {
    var inviter = null;
    if (data != null && data.text != null && data.text.contains("inviter") && data.text.contains("chao.fun")) {
      var uri = Uri.parse(data.text);
      uri.queryParameters.forEach((k, v) {
        if (k == 'inviter') {
          inviter = v;
        }
      });
    }

    var response = await HttpUtil().get(Api.userRegister, parameters: {
      'userName': accout,
      'password': pwd,
      'phone': phone,
      'code': code,
      'inviter': inviter
    });

    // pref.setString('cartInfo', cartString);
    if (response['success']) {
      Provider.of<UserStateProvide>(context, listen: false).changeState(true);
      await db.clear('table_user');
      await db.clear('All_page');
      await db.clear('table_addjoin');
      Fluttertoast.showToast(
        msg: '注册成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushNamed(context, '/addForumPage');
      });
      // Future.delayed(Duration(seconds: 1), () {
      //   Future.delayed(Duration(seconds: 1), () {
      //     Navigator.pushNamed(context, '/addForumPage');
      //   });
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     new MaterialPageRoute(builder: (context) => IndexPage()),
      //     (route) => route == null,
      //   );

      //   // Navigator.pushReplacementNamed(context, '/addForumPage');
      // });
    } else {
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    }
  }

  Widget _loginItem() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 64,
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _inputController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, top: 6, bottom: 6),
          // border: OutlineInputBorder(),
          hintText: '请输入用户名',
          prefixIcon: Icon(Icons.person),
          // suffixIcon: Icon(Icons.remove_red_eye),
          // icon: Icon(Icons.person), // 在输入框外面添加一个 icon
        ),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(32),
          // fontWeight: FontWeight.bold,
        ),
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
        ),
      ),
    );
  }

  Widget _checkBox() {
    return Container(
      child: Row(
        children: [
          Checkbox(
            value: this.check,
            activeColor: Colors.blue,
            onChanged: (bool val) {
              // val 是布尔值
              this.setState(() {
                this.check = !this.check;
              });
            },
          ),
          Text(
            '绑定手机号，可以使用手机号登录哦~',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _xieyi() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 10, left: 20),
      color: Colors.white,

      child: Row(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(34),
            child: InkWell(
              onTap: () {
                setState(() {
                  _checkValue = !_checkValue;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _checkValue
                      ? Colors.blue
                      : Color.fromRGBO(204, 204, 204, 1),
                ),
                child: Container(
                  child: _checkValue
                      ? Icon(
                          Icons.check,
                          size: 18.0,
                          color: Colors.white,
                        )
                      : Text(''),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            '已阅读并同意',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => WebViewExample(
                  //     url: 'https://chao.fun/p/417588', title: '炒饭用户及隐私政策'),
                  builder: (context) => ChaoFunWebView(
                    // url: 'https://chao.fun/p/417588',
                    url:
                        'https://chao.fun/webview/useragree', //'https://chao.fun/webview/agreement',
                    title: '用户服务协议',
                    showAction: false,
                  ),
                ),
              );
            },
            child: Text(
              '《用户服务协议》',
              style: TextStyle(
                color: Colors.blue,
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
          Text(
            '及',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => WebViewExample(
                  //     url: 'https://chao.fun/p/417588', title: '炒饭用户及隐私政策'),
                  builder: (context) => ChaoFunWebView(
                    // url: 'https://chao.fun/p/417588',
                    url:
                        'https://chao.fun/webview/agreement', //'https://chao.fun/webview/agreement',
                    title: '隐私政策',
                    showAction: false,
                  ),
                ),
              );
            },
            child: Text(
              '《隐私政策》',
              style: TextStyle(
                color: Colors.blue,
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
        ],
      ),

      // child: Text('点击阅读《用户协议及隐私政策》'),
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
          color: Colors.white,
          child: Container(
            color: Colors.white,
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
        ),
        Material(
          color: Colors.white,
          child: Ink(
            padding: EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                // Navigator.pop(context);
                // 跳转并关闭所有页面
                Navigator.pushAndRemoveUntil(
                  context,
                  new MaterialPageRoute(builder: (context) => IndexPage()),
                  (route) => route == null,
                );

                //跳转并关闭当前页面
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   new MaterialPageRoute(builder: (context) => new MyHomePage()),
                //   (route) => route == null,
                // );
              },
              child: Icon(
                Icons.close,
                color: KColor.defaultGrayColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
