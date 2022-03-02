import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';

class IframeVideoWidget extends StatelessWidget {
  Map item;
  IframeVideoWidget({Key key, this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.black,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebViewExample(url: item['link'], title: item['title']),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: FadeInImage.assetNetwork(
                height: 240,
                placeholder: "assets/images/img/place.png",
                image: KSet.imgOrigin +
                    item['cover'] +
                    '?x-oss-process=image/resize,h_512/format,webp/quality,q_75',
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned(
              left: 30,
              bottom: 30,
              child: Image.asset(
                'assets/images/icon/play.png',
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
