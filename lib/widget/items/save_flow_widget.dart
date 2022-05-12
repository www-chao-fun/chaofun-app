


import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext context) {
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      //外层使用Positioned进行定位，控制在Overlay中的位置
      return new Positioned(
          top: MediaQuery
              .of(context)
              .size
              .height * 0.8,
          child: new Material(
              child:
              new InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/usersavepage',
                  );
                },
                child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                alignment: Alignment.center,
                child: new Center(
                  child: new Card(
                    child: new Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('点击收藏到具体的文件夹')
                    ),
                    color: Colors.grey,
                  ),
                ),
              ),
              )
          )
      );
    });
    //往Overlay中插入插入OverlayEntry
    Overlay.of(context).insert(overlayEntry);
    //两秒后，移除Toast
    new Future.delayed(Duration(seconds: 2)).then((value) {
      overlayEntry.remove();
    });
  }
}