

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmojiPage extends StatefulWidget {
  var callBack;
  EmojiPage({Key key, this.callBack}) : super(key: key);
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
  List<dynamic> allEmojis = [];


  @override
  void initState() {
    _getEmoji();
  }

  _getEmoji() async {
    var response = await HttpUtil().get(Api.getEmojis, alterFailed: true);
    if (response['success']) {
      setState(() {
        allEmojis = response['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.titleLarge.color, //修改颜色
                size: 16),
            title: Text(
              '选择表情',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge.color,
                fontSize: ScreenUtil().setSp(34),
              ),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          preferredSize: Size.fromHeight(60),
        ),
        body: ListView.builder(itemBuilder: (BuildContext context, int vIndex) {
          return
            Container(height: ScreenUtil().setWidth(200),

              child:
              ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int hIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: ScreenUtil().setWidth(180),
                    width: ScreenUtil().setWidth(187),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.callBack(allEmojis[vIndex * 4 + hIndex]['name']);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: ScreenUtil().setWidth(180),
                            width: ScreenUtil().setWidth(180),
                            child: Image.network(
                              'https://i.chao.fun/' + allEmojis[vIndex * 4 + hIndex]['name'] + '?x-oss-process=image/resize,h_360/format,webp/quality,q_75',
                              height: ScreenUtil().setWidth(180),
                              width: ScreenUtil().setWidth(180),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Positioned(
                        //   bottom: 10,
                        //   right: 0,
                        //   child: InkWell(
                        //     onTap: () {
                        //
                        //     },
                        //     child: Icon(
                        //       Icons.delete_forever,
                        //       size: 20,
                        //       color: Colors.black54,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
              itemCount:  vIndex == (allEmojis.length / 4).ceil() - 1 ? allEmojis.length % 4 : 4,
            )
          );
        },

          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: (allEmojis.length / 4).ceil(),

        )
    );
  }



}