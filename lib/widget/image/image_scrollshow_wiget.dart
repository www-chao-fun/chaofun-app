import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:permission_handler/permission_handler.dart';

const Color selColor = Colors.white;
const Color otherColor = Colors.grey;

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class JhPhotoAllScreenShow extends StatefulWidget {
  List imgDataArr = [];
  int index;
  String heroTag;
  PageController controller;
  GestureTapCallback onLongPress;

  JhPhotoAllScreenShow(
      {Key key,
      @required this.imgDataArr,
      this.index,
      this.onLongPress,
      this.controller,
      this.heroTag})
      : super(key: key) {
    controller = PageController(initialPage: this.index);
  }

  @override
  _JhPhotoAllScreenShowState createState() => _JhPhotoAllScreenShowState();
}

class _JhPhotoAllScreenShowState extends State<JhPhotoAllScreenShow> {
  int currentIndex = 1;
  var imgDataArr;
  bool isBig = false;
  bool haspermission = true;
  GlobalKey _globalKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermission();
    imgDataArr = widget.imgDataArr;

    setState(() {
      currentIndex = widget.index;
    });
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      //SystemUiOverlayStyle
      statusBarColor: Colors.transparent,
      // statusBarIconBrightness: Brightness.dark,
    ); //Colors.black38
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    if (info.contains("granted")) {
      setState(() {
        haspermission = true;
      });
    } else {
      setState(() {
        haspermission = false;
      });
    }
    // Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
    // PermissionStatus.granted   denied
    // final info = statuses[Permission.storage].toString();
    // print(info);PermissionHandler
  }

  _save(context, type) async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/" + getFileName(widget.imgDataArr[currentIndex]);
    await Dio().download(widget.imgDataArr[currentIndex], savePath);
    final result = await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
    // print(result);
    if (Platform.isIOS) {
      Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
    } else {
      if (haspermission) {
        Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
      } else {
        _requestPermission();
      }
    }

    print(await File(savePath).length());

    // 清理文件
    File(savePath).delete();

    if (type == 1) {
      Navigator.of(context).pop();
    }
  }

  String getFileName(String url) {
    var splitList = url.split("/");
    var subPrefix = splitList[splitList.length -1];
    return subPrefix.split("?")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      height: 125,
                      child: Container(
                        color: KColor.defaultPageBgColor,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  _save(context, 1);
                                },
                                child: Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '保存图片',
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Colors.black,
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:
                            CachedNetworkImageProvider(imgDataArr[index]),
                        initialScale: PhotoViewComputedScale.contained * 1,
                        heroAttributes:
                            PhotoViewHeroAttributes(tag: imgDataArr[index]),
                      );
                    },
                    itemCount: imgDataArr.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes,
                        ),
                      ),
                    ),
                    backgroundDecoration: null, //widget.backgroundDecoration,
                    pageController: widget.controller,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                  // child: PhotoViewGallery.builder(
                  //   scrollPhysics: const BouncingScrollPhysics(),
                  //   builder: (BuildContext context, int index) {
                  //     return PhotoViewGalleryPageOptions(
                  // imageProvider: NetworkImage(
                  //   imgDataArr[index],
                  // ),
                  //       // heroAttributes:
                  //       //     PhotoViewHeroAttributes(tag: widget.heroTag)
                  //       heroAttributes: widget.heroTag != null
                  //           ? PhotoViewHeroAttributes(tag: widget.heroTag)
                  //           : null,
                  //     );
                  //     // return FadeInImage.assetNetwork(
                  //     //   placeholder: "assets/images/img/place.png",
                  //     //   image: imgurl + '?x-oss-process=image/resize,h_400',
                  //     //   fit: BoxFit.contain,
                  //     // );
                  //   },
                  //   itemCount: imgDataArr.length,
                  //   loadingBuilder: (context, progress) {
                  //     // ?x-oss-process=image/resize,h_1228
                  //     if (imgDataArr.length == 1) {
                  // return CachedNetworkImage(
                  //     imageUrl: imgDataArr[currentIndex] +
                  //         '?x-oss-process=image/resize,h_1228');
                  //     } else {
                  //       return FadeInImage.assetNetwork(
                  //         placeholder: imgDataArr[currentIndex] +
                  //             "?x-oss-process=image/resize,h_512",
                  //         image: imgDataArr[currentIndex] +
                  //             "?x-oss-process=image/resize,h_512",
                  //         fit: BoxFit.contain,
                  //       );
                  //     }
                  //   },
                  //   // loadingChild: FadeInImage.assetNetwork(
                  //   //   placeholder:
                  //   //       imgDataArr[0] + "?x-oss-process=image/resize,h_512",
                  //   //   image:
                  //   //       imgDataArr[0] + "?x-oss-process=image/resize,h_512",
                  //   //   fit: BoxFit.contain,
                  //   // ),
                  //   backgroundDecoration: null,
                  //   pageController: widget.controller,
                  //   enableRotation: false,
                  //   onPageChanged: (index) {
                  //     setState(() {
                  //       currentIndex = index;
                  //     });
                  //   },
                  // ),
                ),
              ),
              behavior: HitTestBehavior.opaque,

              // onLongPress: widget.onLongPress != null
              //     ? widget.onLongPress
              //     : () {
              //         print('长按图片');
              //       },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
            child: Container(
              width: ScreenUtil().setWidth(750),
              alignment: Alignment.center,
              child: Container(
                width: ScreenUtil().setWidth(120),
                height: ScreenUtil().setWidth(60),
                color: Color.fromRGBO(0, 0, 0, 0.5),
                alignment: Alignment.center,
                child: Text(
                  (currentIndex + 1).toString() +
                      '/' +
                      imgDataArr.length.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 30,
          //   width: MediaQuery.of(context).size.width,
          //   child: Center(
          //     child: Text("${currentIndex + 1}/${widget.imgDataArr.length}",
          //         style: TextStyle(color: Colors.white, fontSize: 16)),
          //   ),
          // ),
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.top + 15,
            // child: IconButton(
            //   color: Colors.white,
            //   icon: Icon(
            //     Icons.close,
            //     size: 30,
            //     color: Colors.black,
            //   ),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            child: InkWell(
              onTap: () {
                _save(context, 2);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 60,
                  height: 30,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.download_outlined,
                    color: Colors.white,
                  ),
                  // child: Text(
                  //   '保存图片',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          Positioned(
            left: ScreenUtil().setWidth(330),
            bottom: MediaQuery.of(context).padding.top + 15,
            // child: IconButton(
            //   color: Colors.white,
            //   icon: Icon(
            //     Icons.close,
            //     size: 30,
            //     color: Colors.black,
            //   ),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //     bottom: MediaQuery.of(context).padding.top + 25,
          //     left: 20,
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(20),
          //       child: InkWell(
          //         onTap: () {
          //           setState(() {
          //             isBig = true;
          //           });
          //         },
          //         child: Container(
          //           alignment: Alignment.center,
          //           width: 78,
          //           height: 24,
          //           color: Color.fromRGBO(235, 235, 235, 0.7),
          //           child: Text(
          //             '查看原图',
          //             style: TextStyle(fontSize: 14, color: Colors.white),
          //           ),
          //         ),
          //       ),
          //     )),

//           Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
// //                color: Colors.red,
//                 width: widget.imgDataArr.length >= 6
//                     ? 200
//                     : widget.imgDataArr.length < 3 ? 50 : 100,
//                 height: widget.imgDataArr.length == 1 ? 0 : 50,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: List.generate(
//                     widget.imgDataArr.length,
//                     (i) => GestureDetector(
//                       child: CircleAvatar(
// //                      foregroundColor: Theme.of(context).primaryColor,
//                         radius: 5.0,
//                         backgroundColor:
//                             currentIndex == i ? selColor : otherColor,
//                       ),
//                     ),
//                   ).toList(),
//                 ),
//               ))
        ],
      ),
    );
  }
}
