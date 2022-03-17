import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:images_picker/images_picker.dart';
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

class SelfHeader extends StatefulWidget {
  List imgDataArr = [];
  int index;
  String heroTag;
  var showMore;
  Function callBack;
  PageController controller;
  GestureTapCallback onLongPress;

  SelfHeader(
      {Key key,
      @required this.imgDataArr,
      this.index,
      this.onLongPress,
      this.controller,
      this.showMore,
      this.callBack,
      this.heroTag})
      : super(key: key) {
    controller = PageController(initialPage: this.index);
  }

  @override
  _SelfHeaderState createState() => _SelfHeaderState();
}

class _SelfHeaderState extends State<SelfHeader> {
  int currentIndex = 1;
  var imgDataArr;
  bool isBig = false;
  bool haspermission = true;
  GlobalKey _globalKey = GlobalKey();
  var showMore;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _requestPermission();
    imgDataArr = widget.imgDataArr;
    showMore = (widget.showMore == null ? false : true);
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
    // print('------------------------------');
    // print(widget.imgDataArr[0]);

    var response = await Dio().get(widget.imgDataArr[currentIndex],
        options: Options(responseType: ResponseType.bytes));
    print('response------------------------------------------------');
    print(response);
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    int strlenght = 32;

    /// 生成的字符串固定长度
    String left = '';
    for (var i = 0; i < strlenght; i++) {
// right = right + (min + (Random().nextInt(max - min))).toString();
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: left);
    print(result);
    if (Platform.isIOS) {
      Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
    } else {
      if (haspermission) {
        Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
      } else {
        _requestPermission();
      }
    }

    if (type == 1) {
      Navigator.of(context).pop();
    }
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
                ),
              ),
            ),
          ),
          showMore
              ? Positioned(
                  left: 20,
                  bottom: MediaQuery.of(context).padding.top + 15,
                  child: InkWell(
                    onTap: () {
                      getImage(false);
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(140),
                      height: ScreenUtil().setWidth(50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '修改头像',
                        style: TextStyle(
                          fontSize: ScreenUtil().setWidth(26),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 0,
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

  Future getImage(isTakePhoto) async {
    // Navigator.pop(context);
    // var image = await ImagePicker.pickImage(
    //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
    List res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.image,
    );
    _upLoadImage(File(res[0].path));
  }

  //上传图片
  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });
    Dio dio = new Dio();
    var res =
        await dio.post("https://chao.fun/api/upload_image", data: formdata);
    print('上传结束');
    print(res);
    print(res.data['data']);
    if (res.data['success']) {
      // setState(() {});
      // String name = res.data['data'];
      var response = await HttpUtil()
          .get(Api.setIcon, parameters: {'imageName': res.data['data']});
      if (response['success']) {
        widget.callBack();
        Navigator.pop(context);
      }
    } else {
      Fluttertoast.showToast(
        msg: res.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
