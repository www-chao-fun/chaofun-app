import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';

class CommonBar extends StatelessWidget {
  var title;
  CommonBar({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: KColor.defaultGrayColor, //修改颜色
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      // bottomOpacity: 0,
      elevation: 0, //头部阴影区域高度
    );
  }
}
