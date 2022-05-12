


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_screenutil/screen_util.dart';

class ForumListNormalView extends StatefulWidget {
  final Map forumInfo;
  ForumListNormalView({Key key, this.forumInfo}) : super(key: key);
  ForumListNormalViewState createState() => ForumListNormalViewState();
}


class ForumListNormalViewState extends State<ForumListNormalView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(110),
      alignment: Alignment.centerLeft,
      // margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.2,
            color: Color.fromRGBO(240, 240, 240, 1),
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/forumpage',
                arguments: {"forumId": widget.forumInfo['id'].toString()},
              );
            },
            child: Container(
              width: ScreenUtil().setWidth(64),
              height: ScreenUtil().setWidth(64),
              margin: EdgeInsets.only(
                right: 8,
                left: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: KSet.imgOrigin +
                      widget.forumInfo['imageName'] +
                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Image.asset("assets/images/img/place.png"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/forumpage',
                  arguments: {"forumId": widget.forumInfo['id'].toString()},
                );
              },
              child: Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.forumInfo['name'],
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '帖子数量: ' + (widget.forumInfo['posts'] == null? '':  widget.forumInfo['posts'].toString()),
                        style: TextStyle(
                          color: KColor.defaultPlaceColor,
                          fontSize: ScreenUtil().setSp(26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   width: ScreenUtil().setWidth(80),
          //   alignment: Alignment.center,
          //   child: InkWell(
          //     onTap: () {},
          //     child: Image.asset(
          //       'assets/images/_icon/push_forum_icon.png',
          //       width: ScreenUtil().setWidth(50),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}