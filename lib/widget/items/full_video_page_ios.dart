import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
// import 'package:flutter_tencentplayer_example/widget/tencent_player_bottom_widget.dart';
// import 'package:flutter_tencentplayer_example/widget/tencent_player_gesture_cover.dart';
// import 'package:flutter_tencentplayer_example/widget/tencent_player_loading.dart';
// import 'package:screen/screen.dart';
// import 'package:flutter_tencentplayer/flutter_tencentplayer.dart';
// import 'package:flutter_tencentplayer_example/main.dart';
// import 'package:flutter_tencentplayer_example/util/forbidshot_util.dart';

class FullVideoPageIos extends StatefulWidget {
  String dataSource;
  String title;
  VideoPlayerController controller;

  //UI
  bool showBottomWidget;
  bool showClearBtn;
  bool detail;

  FullVideoPageIos(
      {this.controller,
      this.showBottomWidget = true,
      this.showClearBtn = true,
      this.dataSource,
      this.detail = false,
      this.title});

  @override
  _FullVideoPageIosState createState() => _FullVideoPageIosState();
}

class _FullVideoPageIosState extends State<FullVideoPageIos> with RouteAware {
  VideoPlayerController controller;
  VoidCallback listener;

  bool isLock = false;
  bool showCover = false;
  Timer timer;
  var i = 1;

  _FullVideoPageIosState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.value.aspectRatio > 1) {
      // if (Platform.isAndroid) {
      //   SystemChrome.setEnabledSystemUIOverlays([]);
      //   SystemChrome.setPreferredOrientations([
      //     DeviceOrientation.landscapeLeft,
      //     DeviceOrientation.landscapeRight,
      //   ]);
      // }
    }
    _initController();
    controller.addListener(listener);

    hideCover();
    // ForbidShotUtil.initForbid(context);
    // Screen.keepOn(true);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)); //订阅
    super.didChangeDependencies();
  }

  // @override
  // void didPopNext() {
  //   print('开始返回');
  //   // Covering route was popped off the navigator.
  //   SystemChrome.setEnabledSystemUIOverlays(
  //       [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //   ]);
  //   controller.dispose();
  //   // controller.pause();
  //   print('返回NewView');
  //   super.didPopNext();
  // }

  @override
  void didPush() {
    debugPrint("------> didPush");
    super.didPush();
  }

  @override
  void didPop() {
    // if (Platform.isAndroid) {
    //   SystemChrome.setEnabledSystemUIOverlays(
    //       [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //   ]);
    // }

    controller.pause();
    debugPrint("------> didPop");
    super.didPop();
  }

  @override
  void didPopNext() {
    debugPrint("------> didPopNext");
    super.didPopNext();
  }

  @override
  void didPushNext() {
    debugPrint("------> didPushNext");
    super.didPushNext();
  }

  @override
  void dispose() {
    super.dispose();
    // controller.pause();
    // if (Platform.isAndroid) {
    //   SystemChrome.setEnabledSystemUIOverlays(
    //       [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //   ]);
    // }

    controller.removeListener(listener);
    // if (widget.controller == null) {
    //   controller.dispose();
    // }
    // controller.dispose();
    // ForbidShotUtil.disposeForbid();
    // Screen.keepOn(false);
  }

  _initController() {
    if ((widget.controller != null)) {
      controller = widget.controller;
      Future.delayed(Duration(milliseconds: 300)).then((e) {
        controller.play();
      });

      // return;
    } else {
      controller = VideoPlayerController.network(widget.dataSource)
        ..initialize().then((_) {
          controller.play();
        });
    }
    // controller = widget.controller;
    // Future.delayed(Duration(milliseconds: 300)).then((e) {
    //   controller.play();
    // });
    // controller.play();

    // controller = VideoPlayerController.network(widget.dataSource)
    //   ..initialize().then((_) {
    //     controller.play();
    //   });

    // Future.delayed(Duration(milliseconds: 1000)).then((e) {
    //   controller.play();
    // });
  }

  bool oks() {
    // if (!widget.detail && i == 1) {
    //   setState(() {
    //     i = 2;
    //   });
    //   controller.play();
    // }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // if (Platform.isAndroid) {
    //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     // statusBarIconBrightness: Brightness.dark,
    //   ); //Colors.black38
    //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    // }
    return RotatedBox(
      quarterTurns: 1,
      child: Scaffold(
        body: GestureDetector(
          // behavior: HitTestBehavior.opaque,
          behavior: HitTestBehavior.translucent,
          // onTap: () {
          //   hideCover();
          // },
          onDoubleTap: () {
            // if (!widget.showBottomWidget || isLock) return;
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.only(
                top: widget.controller.value.aspectRatio > 1 ? 0 : 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                /// 视频
                (controller.value.isInitialized)
                    ? (widget.detail
                        ? Hero(
                            tag: 'hero',
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ))
                    : Image.asset('static/place_nodata.png'),

                /// 支撑全屏
                Container(),

                /// 半透明浮层hideCover();
                InkWell(
                  onTap: () {
                    hideCover();
                  },
                  child: Container(
                    height: widget.controller.value.aspectRatio > 1
                        ? ScreenUtil().setHeight(1334)
                        : ScreenUtil().setHeight(1334),
                    color: widget.controller.value.aspectRatio > 1
                        ? (showCover
                            ? Color.fromRGBO(0, 0, 0, 0.1)
                            : Colors.transparent)
                        : Colors.transparent,
                  ),
                ),

                /// 进度、清晰度、速度
                Offstage(
                  offstage: !(widget.showBottomWidget && showCover),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 0),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: _VideoPlayerBottomWidget(),
                    ),
                  ),
                ),

                /// 头部浮层
                !isLock && showCover
                    ? Positioned(
                        top: 0,
                        // left: MediaQuery.of(context).padding.top,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (Platform.isAndroid) {
                              SystemChrome.setEnabledSystemUIOverlays([
                                SystemUiOverlay.top,
                                SystemUiOverlay.bottom
                              ]);
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                              ]);
                            }
                            Navigator.pop(context, controller);
                          },
                          child: Container(
                            width: ScreenUtil().setHeight(1334),
                            alignment: Alignment.centerLeft,
                            // color: Colors.white,
                            padding: EdgeInsets.only(
                              top: widget.controller.value.aspectRatio > 1
                                  ? 20
                                  : 34,
                              left: MediaQuery.of(context).padding.top,
                              right: ScreenUtil().setWidth(20),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'static/icon_back.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(10),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _VideoPlayerBottomWidget() {
    return InkWell(
      onTap: () {
        delayHideCover();
      },
      child: Container(
        // width: ScreenUtil().setWidth(700),
        height: ScreenUtil().setWidth(100),
        padding: EdgeInsets.only(left: 5, right: 15, bottom: 10, top: 5),
        color: widget.controller.value.aspectRatio > 1
            ? (showCover ? Color.fromRGBO(0, 0, 0, 0.3) : Colors.transparent)
            : Colors.transparent,
        alignment: controller.value.aspectRatio > 1
            ? Alignment.topCenter
            : Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (controller.value.isPlaying) {
                  // setState(() {
                  //   controller.pause();
                  // });
                  controller.pause();
                } else {
                  // setState(() {
                  //   controller.play();
                  // });
                  controller.play();
                }
              },
              child: controller.value.isPlaying
                  ? Image.asset(
                      'static/player_pause.png',
                      width: 24,
                      height: 24,
                    )
                  : Image.asset(
                      'static/player_play.png',
                      width: 24,
                      height: 24,
                    ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                ),
              ),
            ),
            SizedBox(
              width: 14,
            ),
            _doTimes(),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                // setState(() {
                if (controller.value.volume == 0.0) {
                  controller.setVolume(1.0);
                } else {
                  controller.setVolume(0.0);
                }
                // });
              },
              child: Icon(
                controller.value.volume == 1.0
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
        // child: _doTimes(),
        // child: VideoProgressIndicator(
        //   controller,
        //   allowScrubbing: true,
        //   padding: EdgeInsets.only(top: 20),
        // ),
      ),
    );
  }

  Widget _doTimes() {
    print('长度');
    print(controller.value);
    if (controller.value.duration != null) {
      var cur = controller.value.position.toString();

      cur = cur.substring(2, 7);
      var dur = controller.value.duration.toString();
      dur = dur.substring(2, 7);
      return RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: cur + '/',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            // fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(
              text: dur,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        '加载失败',
        style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(26)),
      );
    }
  }

  List<String> clearUrlList = [
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f10.mp4',
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f20.mp4',
    'http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/e1ab85305285890781763144364/v.f30.mp4',
  ];

  // changeClear(int urlIndex, {int startTime}) {
  //   controller?.removeListener(listener);
  //   controller?.pause();
  //   controller = TencentPlayerController.network(clearUrlList[urlIndex],
  //       playerConfig: PlayerConfig(
  //           startTime: startTime ?? controller.value.position.inSeconds));
  //   controller?.initialize().then((_) {
  //     if (mounted) setState(() {});
  //   });
  //   controller?.addListener(listener);
  // }

  hideCover() {
    if (!mounted) return;
    setState(() {
      showCover = !showCover;
    });
    delayHideCover();
  }

  delayHideCover() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    if (showCover) {
      timer = new Timer(Duration(seconds: 4), () {
        if (!mounted) return;
        setState(() {
          showCover = false;
        });
      });
    }
  }
}
