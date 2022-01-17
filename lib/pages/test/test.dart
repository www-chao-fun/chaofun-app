import '../../config/color.dart';
import '../../pages/test/photoView/photo_view_page.dart';

import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('测试页面'),
        ),
        body: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_album),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('图片预览'),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: KColor.arrowColor,
                    size: 22,
                  ),
                ],
              ),
              onTap: () {
                //       Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) {
                //     return TestPage();
                //   }),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              onTap: () {
                Navigator.pushNamed(context, "/photoapp");
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('点击拍照'),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: KColor.arrowColor,
                    size: 22,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/videopage",
                );
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('视频播放器'),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: KColor.arrowColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
