import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends StatelessWidget {
  String version;
  var appVersionInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: AppBar(
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
            '联系我们',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        preferredSize: Size.fromHeight(40),
      ),
      body: ListView(
        children: [
          Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.5,
                  color: Color.fromRGBO(241, 239, 239, 1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewExample(
                            // url: 'http://192.168.8.208:9010/uupieh5/#/test',
                            url: 'https://chao.fan/webview/contact',
//                            url: 'http://192.168.8.208:8099/webview/contact',
                            // url: 'https://chao.fan',
                            title: '反馈建议',
                            showAction: 0,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Text(
                        '反馈建议',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: KColor.defaultBorderColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget btn(context) {
    return MaterialButton(
      elevation: 0,
      color: Colors.white,
      textColor: Colors.black,
      child: RichText(
        text: TextSpan(
          text: '立即更新',
          style: TextStyle(
            // fontSize: 30,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(text: 'new', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: KColor.defaultBorderColor),
      ),
      onPressed: () async {},
    );
  }
}
