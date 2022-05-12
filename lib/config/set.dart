import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/store/index.dart';

class KSet {
  static const String imgOrigin = 'https://i.chao.fun/';
  static const String refreshReadyText = '松手刷新页面';
  static const String refreshingText = '正在刷新中...'; //正在刷新中...
  static const String refreshText = '下拉刷新页面';
  static const String refreshedText = '刷新完成';

  static const String loadingText = '加载中...';
  static const String loadedText = '加载完成';
// static const String refreshedText = '刷新完成';
// static const String refreshedText = '刷新完成';

  static const Color textRefreshColor = Color.fromRGBO(152, 153, 153, 1);
  static const List<Map> pubList = [
    {
      "type": "link",
      "label": '链接',
      "icon": 'assets/images/_icon/link.png',
    },
    {
      "type": "image",
      "label": '图片/视频',
      "icon": 'assets/images/_icon/image.png',
    },
    {
      "type": "textarea",
      "label": '文字',
      "icon": 'assets/images/_icon/article.png',
    },
    {
      "type": "vote",
      "label": '投票',
      "icon": 'assets/images/_icon/toupiao.png',
    },
  ];

  static reLoad(context) {
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => IndexPage()),
      (route) => route == null,
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static islink(txtContent) {
    // var check_www = 'w{3}' + '[^\\s]*';
    // var check_http =
    //     '(https|http|ftp|rtsp|mms)://' + '[^(\\s|(\\u4E00-\\u9FFF)))]*';
    // var strRegex = check_http;
    var httpReg =
        new RegExp(r'(https|http|ftp|rtsp|mms)://[^(\s|(\u4E00-\u9FFF)))]*');
    // var hasLink = httpReg.hasMatch(txtContent);
    var link = httpReg.allMatches(txtContent);
    List listUrl = [];
    for (Match m in link) {
      listUrl.add(m.group(0));
    }
    print(listUrl);
    // print(hasLink);
    if (listUrl.length > 0) {
      return listUrl[0];
    } else {
      return '';
    }
  }

}
