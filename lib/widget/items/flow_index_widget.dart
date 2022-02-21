import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/check.dart';


import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';


class FlowIndexWidget extends StatelessWidget {
  Map item1;
  Map item2;
  bool isForum;
  String type;
  String cate;
  bool isComment;
  bool isTag;
  double item1DrawWidth = 373;
  double item2DrawWidth = 373;
  BoxFit item1Fit = BoxFit.fitWidth;
  BoxFit item2Fit = BoxFit.fitWidth;

  static double cellHeight = 220;
  FlowIndexWidget({Key key, this.item1, this.item2, this.isForum = false, this.isTag = false, this.type, this.cate, this.isComment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    clearMemoryImageCache();

    if (item2 != null) {

    }

    computeWidthAndFit();
    return Container(height: ScreenUtil().setHeight(cellHeight),child: Row(
      children: [
        getFlowItem(context, item1, item1DrawWidth, item1Fit),
        Spacer(),
        getFlowItem(context, item2, item2DrawWidth, item2Fit),
      ],
    ));
  }

  Widget getFlowItem(BuildContext context, Map item, double width, BoxFit boxFit) {

    print(width);
    if (item == null){
      return Container();
    }

    Stack stack = null;
    if (item['type'] == 'image' || item['type'] == 'article') {
      stack = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ScreenUtil().setWidth(width),
            height: ScreenUtil().setHeight(cellHeight),
            color: Colors.white,
            margin: EdgeInsets.only(top: 0, bottom: 0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/postdetail',
                  arguments: {"postId": item['postId'].toString()},
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.medium,
                  imageUrl: KSet.imgOrigin + (item['imageName'] ?? '') + '?x-oss-process=image/format,webp/quality,q_75/resize,h_420',
                  width: ScreenUtil().setWidth(width),
                  // fit: (item['width'] != null && item['height'] != null) &&
                  //         item['height'] < item['width']
                  //     ? BoxFit.fitWidth
                  //     : BoxFit.fitHeight,
                  fit:boxFit,
                  placeholder: (context, url) =>
                      Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(254, 149, 0, 100)),
                          ),
                        ),
                      ),
                  height: ScreenUtil().setHeight(cellHeight),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      stack = Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: ScreenUtil().setWidth(width),
              height: ScreenUtil().setHeight(cellHeight),
              color: Colors.white,
              margin: EdgeInsets.only(top: 0, bottom: 0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/postdetail',
                    arguments: {"postId": item['postId'].toString()},
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: CachedNetworkImage(
                    filterQuality: FilterQuality.medium,
                    imageUrl: (KSet.imgOrigin +
                        (item['type'] == 'inner_video'
                            ? ( item['video'] ?? '' )
                            : (item['imageName'] ?? ''))) +
                        '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,h_420',
                    // width: ScreenUtil().setWidth(width),
                    // fit: (item['width'] != null && item['height'] != null) &&
                    //         item['height'] < item['width']
                    //     ? BoxFit.fitWidth
                    //     : BoxFit.fitHeight,
                    fit: boxFit,
                    placeholder: (context, url) =>
                        Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromRGBO(254, 149, 0, 100)),
                            ),
                          ),
                        ),
                    height: ScreenUtil().setHeight(cellHeight),
                  ),
                ),
              ),
            ),
          ]);
    }


    // if (item['type'] == 'inner_video') {
    //   type = "视频";
    // }
    //
    // if (item['type'] == 'gif') {
    //   type = "GIF";
    // }
    //


    if (item['type'] == 'inner_video' || item['type'] == 'gif') {
      stack.children.add(
          Positioned(
              child: Image.asset(
                'static/player_play.png',
                width: 24,
                height: 24,
              )));
    }

    if (isForum == false) {
      stack.children.add(
          Positioned(
          bottom: 10,
          left: 10,
          child: Text(item['forum']['name'] + (item['tags'] != null && item['tags'].length > 0 ? '#' + item['tags'][0]['name'] : ''), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,  color: Colors.white,  backgroundColor: Color.fromRGBO(1, 1, 1, 0.5)))));

    } else {
      if (!isTag && item['tags'] != null && item['tags'].length > 0) {
        stack.children.add(
            Positioned(
                bottom: 10,
                left: 10,
                child: Text('#' + item['tags'][0]['name'], style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    backgroundColor: Color.fromRGBO(1, 1, 1, 0.5)))));

      }

    }
    return stack;
  }

  void computeWidthAndFit() {

    double item1Height = 800;
    double item2Height = 800;
    double item1Width = 800;
    double item2Width = 800;

    if (item1 != null) {
      item1Height = item1['height'] ?? 800;
      item1Width = item1['width'] ?? 800;
    }

    if (item2 != null) {
      item2Height = item2['height'] ?? 800;
      item2Width = item2['width'] ?? 800;
    }

    double item1RatioWidth = item1Width * (cellHeight /item1Height);
    double item2RatioWidth = item2Width * (cellHeight /item2Height);

    double total = item1RatioWidth + item2RatioWidth;

    // print("item1RatioWidth: " + item1RatioWidth.toString());
    // print("item2RatioWidth: " + item2RatioWidth.toString());
    // print("total: " + total.toString());

    item1DrawWidth = 746 * item1RatioWidth / total;
    item2DrawWidth = 746 * item2RatioWidth / total;
    //
    if (item1DrawWidth < 150) {
      item1DrawWidth = 150;
      item2DrawWidth = 746.0 - 150;
    }

    if (item2DrawWidth < 150) {
      item2DrawWidth = 150;
      item1DrawWidth = 746.0 - 150;
    }

    //todo: 这里一只有问题，还没有解决，挺奇怪的
    //
    // if (item1Width / item1Height > item1DrawWidth / cellHeight ) {
    //   item1Fit = BoxFit.fitWidth;
    // } else {
    //   item1Fit = BoxFit.fitHeight;
    //
    // }
    //
    // if (item2Width / item2Height > item2DrawWidth / cellHeight ) {
    //   item2Fit = BoxFit.fill;
    // } else {
    //   item2Fit = BoxFit.scaleDown;
    // }

    item1Fit =  BoxFit.cover;
    item2Fit =  BoxFit.cover;
  }
}
