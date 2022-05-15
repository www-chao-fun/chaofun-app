


import 'package:flutter/material.dart';

class SaveToast {
  static void show(BuildContext context, int postId) {
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      //外层使用Positioned进行定位，控制在Overlay中的位置
      return new Positioned(
          left: MediaQuery.of(context).size.width * 0.05,
          top: MediaQuery.of(context).size.height * 0.8,
          child: new Material(
              child: Row(
                children: [
                  new InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/saveFolderList',
                        arguments: {'type': 'choose', 'postId': postId},
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      alignment: Alignment.center,
                      child: new Center(
                        child: new TextButton(
                            child: Text('已收藏,点击可加入收藏夹')
                        ),
                      ),
                    ),
                  )
                ],
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