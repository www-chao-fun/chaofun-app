import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color.dart';

class KFont {
  // 原价文本
  static TextStyle oriPriceStyle =
      TextStyle(color: Colors.black26, decoration: TextDecoration.lineThrough);
  static TextStyle presentPriceStyle = TextStyle(
    color: KColor.presentPriceColor,
    fontSize: ScreenUtil().setSp(40),
  );
  static TextStyle descFontStyle = TextStyle(
    fontSize: ScreenUtil().setSp(24),
    color: Color.fromRGBO(33, 29, 47, 0.5),
  );
  static TextStyle titleFontStyle = TextStyle(
    fontSize: ScreenUtil().setSp(32),
    color: KColor.defaultTitleColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle placeFontStyle = TextStyle(
    fontSize: ScreenUtil().setSp(30),
    color: KColor.defaultTitleColor,
  );
  static TextStyle homeNavActStyle = TextStyle(
    fontSize: 15,
    color: KColor.defaultTitleColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle homeNavStyle = TextStyle(
    fontSize: 15,
    color: KColor.defaultPlaceColor,
    // fontWeight: FontWeight.bold,
  );
  static TextStyle navBarBottomStyle = TextStyle(
    fontSize: 12,
  );
  // style: TextStyle(
  //               fontSize: ScreenUtil().setSp(26),
  //               color: KColor.defaultGrayColor,
  //             ),
}
