


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_screenutil/screen_util.dart';

class SimpleUserListView extends StatefulWidget {
  final Map userInfo;
  SimpleUserListView({Key key, this.userInfo}) : super(key: key);
  SimpleUserListViewState createState() => SimpleUserListViewState();
}


class SimpleUserListViewState extends State<SimpleUserListView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      // margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.2,
            color: Color.fromRGBO(240, 240, 240, 1),
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/userMemberPage',
            arguments: {"userId": widget.userInfo['userId'].toString()},
          );
        },
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(
                right: 8,
                left: 10,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: KSet.imgOrigin +
                      widget.userInfo['icon'] +
                      '?x-oss-process=image/format,webp/quality,q_75/resize,h_80',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Image.asset("assets/images/img/place.png"),
                  ),
                ),
                // child: Image.network(
                //   KSet.imgOrigin +
                //       userInfo['icon'] +
                //       '?x-oss-process=image/format,webp/quality,q_75/resize,h_80',
                //   width: 30,
                //   height: 30,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.userInfo['userName'],
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '获赞:' +  widget.userInfo['ups'].toString(),
                        style: TextStyle(
                          color: KColor.defaultPlaceColor,
                          fontSize: ScreenUtil().setSp(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}