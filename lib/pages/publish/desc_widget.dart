import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DescWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(40)),
      child: Text(
        '严禁发布色情、暴恐、赌博及其他违反网络安全法的内容，或涉嫌隐私或未经授权的私人图片及信息，如违规发布，请自行删除或管理员强制删除',
        style: TextStyle(color: KColor.defaultGrayColor),
      ),
    );
  }
}
