import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/utils/ImageUtils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_chaofan/config/index.dart';

class ImageWidget extends StatelessWidget {
  String imgurl;
  Map item;
  ImageWidget({Key key, this.imgurl, this.item}) : super(key: key);

  doImgList(lis) {
    var arr = [];
    lis['images'].forEach((i) {
      arr.add(KSet.imgOrigin + i);
    });
    return arr;
  }

  @override
  Widget build(BuildContext context) {
    if (item['imageNums'] == 1) {
      return getOne(context);
    } else if (item['imageNums'] == 2 || item['imageNums'] == 4) {
      return getTwo(context);
    } else {
      return getThree(context);
    }
  }

  Widget getOne(context) {
    // var hight = (item['width'] == null || item['height'] == null)
    //     ? 690
    //     : min((double.parse(item['height'].toString()) / item['width']) * 690,
    //         690);
    var hight = 500;
    return Container(
      width: ScreenUtil().setWidth(690),
      height: ScreenUtil().setWidth(hight),
      color: Color.fromRGBO(245, 245, 245, 1),
//       alignment: Alignment.center,
      // 设置盒子最大或最小高度宽度
      // constraints: ((item['width'] == null || item['height'] == null) ||
      //         (item['width'] > item['height'] ||
      //             item['width'] == item['height'])
      //     ? BoxConstraints(
      //         // minHeight: ScreenUtil().setWidth(250),
      //         )
      //     : BoxConstraints(
      //         maxHeight: ScreenUtil().setWidth(730),
      //       )),
      margin: EdgeInsets.only(top: 5),
      child: Stack(
          children: [
            InkWell(
              onTap: () {
                print('点击图片');
                // JhPhotoAllScreenShow
                Navigator.of(context).push(
                  FadeRoute(
                    page: JhPhotoAllScreenShow(
                      imgDataArr: [imgurl],
                      imgHeight: item['height'],
                      imgWidth: item['width'],
                      index: 0,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: CachedNetworkImage(
                    filterQuality: FilterQuality.high,
                    imageUrl:  ImageUtils.ossUrl(imgurl, item['width'], item['height'] ,ScreenUtil().setWidth(690), ScreenUtil().setWidth(hight)),
                    width: ScreenUtil().setWidth(690),
                    // fit: BoxFit.fitHeight,
                    fit: BoxFit.fitHeight,
                    height: ScreenUtil().setWidth(hight),
                    placeholder: (context, url) => Center(
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
                    // fit: BoxFit.scaleDown,
                    // height:
                    //     ScreenUtil().setWidth(hight),
                    errorWidget: (context, url, error) => FadeInImage.assetNetwork(
                      placeholder: "assets/images/img/place.png",
                      image:  ImageUtils.ossUrl(imgurl, item['width'], item['height'] ,ScreenUtil().setWidth(690), ScreenUtil().setWidth(hight)),
                    )),
              ),
            ),
            Visibility(
                visible: ImageUtils.longImage(item['width'], item['height']),
                child:
                Positioned(
                  bottom: 0,
                    left: 0,
                    child:
                  Container(
                  color: Colors.blueAccent,
                  padding: EdgeInsets.fromLTRB(4,1,4,1),
                  child: Text('长图', style: TextStyle(color: Colors.white),),
                  )
                )

            )

          ]),
    );
  }

// 两列图
  List<Widget> _listViewByUser2(context) {
    // var hight = (item['width'] == null || item['height'] == null)
    //     ? 345
    //     : min((double.parse(item['height'].toString()) / item['width']) * 345,
    //         690);
    var hight = 500;
    List asd = doImgList(item);
    if(asd.length > 2 ) {
      hight = 250;
    }
    List<Widget> b = [];
    asd.forEach((element) {});
    for (var key = 0; key < asd.length; key++) {
      var c = Container(
        width: ScreenUtil().setWidth(340),
        height: ScreenUtil().setWidth(hight),
        color: Colors.white,
        margin: EdgeInsets.only(top: 0, bottom: 2),
        child: InkWell(
          onTap: () {
            print('点击图片');
            // JhPhotoAllScreenShow
            Navigator.of(context).push(
              FadeRoute(
                page: JhPhotoAllScreenShow(
                  imgDataArr: doImgList(item),
                  index: key,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: CachedNetworkImage(
              filterQuality: FilterQuality.medium,
              imageUrl: ImageUtils.ossUrl(asd[key], null, null ,ScreenUtil().setWidth(340), ScreenUtil().setWidth(hight)),
              width: ScreenUtil().setWidth(340),
              // fit: (item['width'] != null && item['height'] != null) &&
              //         item['height'] < item['width']
              //     ? BoxFit.fitWidth
              //     : BoxFit.fitHeight,
              fit: (item['width'] != null &&
                      item['height'] != null &&
                      item['width'] > item['height'])
                  ? BoxFit.fitHeight
                  : BoxFit.fitWidth,
              placeholder: (context, url) => Center(
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
              height: ScreenUtil().setWidth(hight),
              errorWidget: (context, url, error) => FadeInImage.assetNetwork(
                placeholder: "assets/images/img/place.png",
                image: ImageUtils.ossUrl(asd[key], null, null ,ScreenUtil().setWidth(340), ScreenUtil().setWidth(hight)),
              ),
            ),
          ),
        ),
      );
      b.add(c);
    }
    return b;
  }

  Widget getTwo(context) {
    return Container(
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 2.5,
        children: _listViewByUser2(context),
      ),
    );
  }

  List<Widget> _listViewByUser(context) {
    // var hight = (item['width'] == null || item['height'] == null)
    //     ? 270
    //     : min((double.parse(item['height'].toString()) / item['width']) * 225,
    //         270);
    var hight = 300;
    List asd = doImgList(item);
    if (asd.length <= 3) {
      hight = 350;
    } else if (asd.length <=6) {
      hight = 250;
    } else {
      hight = 166;
    }
    List<Widget> b = [];
    for (var key = 0; key < asd.length; key++) {
      var c = Container(
        width: ScreenUtil().setWidth(225),
        height: ScreenUtil().setWidth(hight),
        color: Colors.white,
        margin: EdgeInsets.only(top: 0, bottom: 2),
        child: InkWell(
          onTap: () {
            print('点击图片');
            print(doImgList(item));
            // JhPhotoAllScreenShow
            Navigator.of(context).push(
              FadeRoute(
                page: JhPhotoAllScreenShow(
                  imgDataArr: doImgList(item), //[imgurl],
                  index: key,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            // child: Image.network(src),
            child: CachedNetworkImage(
              filterQuality: FilterQuality.medium,
              imageUrl: ImageUtils.ossUrl(asd[key], null, null ,ScreenUtil().setWidth(225), ScreenUtil().setWidth(hight)),
              width: ScreenUtil().setWidth(225),
              // fit: item['height'] < item['width']
              //     ? BoxFit.fitWidth
              //     : BoxFit.fitHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
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
              height: ScreenUtil().setWidth(hight),
              errorWidget: (context, url, error) => FadeInImage.assetNetwork(
                  placeholder: "assets/images/img/place.png",
                  image: ImageUtils.ossUrl(asd[key], null, null ,ScreenUtil().setWidth(225), ScreenUtil().setWidth(hight)),),
            ),
          ),
        ),
      );
      b.add(c);
    }
    return b;
  }

  Widget getThree(context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 2.5,
        children: _listViewByUser(context),
        // children: [
        //   Container(
        //     width: ScreenUtil().setWidth(225),
        //     height:
        //         ScreenUtil().setWidth((item['height'] / item['width']) * 225),
        //     color: Color.fromRGBO(245, 245, 245, 1),
        //     margin: EdgeInsets.only(top: 5),
        //     child: InkWell(
        //       onTap: () {
        //         print('点击图片');
        //         print(doImgList(item));
        //         // JhPhotoAllScreenShow
        //         Navigator.of(context).push(
        //           FadeRoute(
        //             page: JhPhotoAllScreenShow(
        //               imgDataArr: doImgList(item), //[imgurl],
        //             ),
        //           ),
        //         );
        //       },
        //       child: ClipRRect(
        //         borderRadius: BorderRadius.all(Radius.circular(4)),
        //         child: CachedNetworkImage(
        //           imageUrl: imgurl + 'x-oss-process=image/resize,h_1228/format,webp/quality,q_75',
        //           width: ScreenUtil().setWidth(225),
        //           height: ScreenUtil()
        //               .setWidth((item['height'] / item['width']) * 225),
        //           errorWidget: (context, url, error) => Icon(Icons.error),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
    );
  }
}
