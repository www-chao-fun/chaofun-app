// import 'package:better_player/better_player.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/main.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/widget/items/full_video_page.dart';
import 'package:flutter_chaofan/widget/items/full_video_page_ios.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/cupertino.dart';

import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

class VideoWidget extends StatefulWidget {
  var item;
  var height;
  var detail;
  var video = false;
  var isAssets;
  VideoWidget(
      {Key key,
      this.item,
      this.height = 240.0,
      this.detail = false,
      this.isAssets = false,
      this.video = false})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> with RouteAware {
  // VideoPlayerController _videoPlayerController;
  bool startedPlaying = false;
  bool isPlay = false;
  bool isFinished = false;

  VideoPlayerController _videoPlayerController = null;
  Future<void> _initializeVideoPlayerFuture;

  bool initialized = false;

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Material(
  //     elevation: 0,
  //     child: Center(
  //       child:
  //     ),
  //   );
  // }
  var item;

  bool showBottomWidget = true;
  bool showClearBtn = false;

  bool canshow = false;

  var height;
  var detail = false;
  var init = false;
  var video = false;
  bool toFull = false;
  String dataSource;

  _VideoWidgetState() {}

  static const _examplePlaybackRates = [
    0.5,
    1.0,
    1.5,
    2.0,
  ];

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    item = widget.item;
    height = widget.height;
    detail = widget.detail;
    video = widget.video;
    if (widget.detail == true || !(widget.video)) {
      _inits();
    }

  }

  _inits() async {
    if (widget.video) {
      if (widget.isAssets) {
        _videoPlayerController =
            VideoPlayerController.file(File(widget.item['video']))
              ..initialize().then((value) {
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                print('视频加载value');
                setState(() {
                  canshow = true;
                });

                Future.delayed(Duration(milliseconds: 200)).then((e) {
                  setState(() {
                    initialized = true;
                  });
                  _videoPlayerController.play();
                });

                _videoPlayerController.addListener(() {
                  try {
                    if (_videoPlayerController.value.isPlaying) {
                      print(_videoPlayerController.value.position.inSeconds);
                      print('___________________________________');
                      print(_videoPlayerController.value.duration.inSeconds);
                      if (mounted &&
                          _videoPlayerController.value.position.inSeconds ==
                              _videoPlayerController.value.duration.inSeconds) {
                        setState(() {
                          isFinished = true;
                        });
                      } else {
                        setState(() {
                          isFinished = false;
                        });
                      }
                    }
                  } catch (e) {
                    _inits();
                  }
                });
              });
      } else {
        dataSource = KSet.imgOrigin + widget.item['video'];
        _videoPlayerController =
            VideoPlayerController.network(KSet.imgOrigin + widget.item['video'])
              ..initialize().then((value) {
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                print('视频加载value');
                setState(() {
                  canshow = true;
                });

                Future.delayed(Duration(milliseconds: 200)).then((e) {
                  setState(() {
                    initialized = true;
                  });
                  _videoPlayerController.play();
                });

                _videoPlayerController.addListener(() {
                  try {
                    if (_videoPlayerController.value.isPlaying) {
                      print(_videoPlayerController.value.position.inSeconds);
                      print('___________________________________');
                      print(_videoPlayerController.value.duration.inSeconds);
                      if (mounted &&
                          _videoPlayerController.value.position.inSeconds ==
                              _videoPlayerController.value.duration.inSeconds) {
                        setState(() {
                          isFinished = true;
                        });
                      } else {
                        setState(() {
                          isFinished = false;
                        });
                      }
                    }
                  } catch (e) {
                    _inits();
                  }
                });
              });
      }
    } else {
      dataSource = KSet.imgOrigin + widget.item['imageName'];
      _videoPlayerController = VideoPlayerController.network(
          KSet.imgOrigin + widget.item['imageName'])
        ..initialize().then((_) {
          setState(() {
            initialized = true;
          });
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          _videoPlayerController.setLooping(
              Provider.of<UserStateProvide>(context, listen: false).loopGif);
          _videoPlayerController.addListener(() {
            try {
              if (_videoPlayerController.value.isPlaying) {
                if (mounted &&
                    _videoPlayerController.value.position.inSeconds ==
                        _videoPlayerController.value.duration.inSeconds) {
                  if (!_videoPlayerController.value.isLooping) {
                    setState(() {
                      isFinished = true;
                    });
                  }
                } else {
                  setState(() {
                    isFinished = false;
                  });
                }
              }
            } catch (e) {
              _inits();
            }
          });
          Future.delayed(Duration(milliseconds: 200)).then((e) {
            _videoPlayerController.play();
          });
        });
      // canshow = true;
    }

  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)); //订阅
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!toFull && _videoPlayerController != null) {
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
      _videoPlayerController = null;
      canshow = false;
    }
    Wakelock.disable();
    // _videoPlayerController.pause();
    // _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    debugPrint("------> didPush");
    super.didPush();
  }

  @override
  void didPop() {
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
    }

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

  Widget _doIcons() {
    if (isFinished) {
      return Icon(
        Icons.refresh,
        color: Colors.white,
        size: 40.0,
      );
    } else if (_videoPlayerController.value.isPlaying) {
      return SizedBox.shrink();
    } else {
      return Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 40.0,
      );
    }
  }

  Widget _videos() {
    return Container(
      height: ScreenUtil().setWidth(500),
      child: Container(
        padding: const EdgeInsets.all(0),
        height: ScreenUtil().setWidth(500),
        color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            // Container()
            Container(
              height: ScreenUtil().setWidth(500),
              alignment: Alignment.center,
              child: widget.detail
                  ? Hero(
                      tag: 'hero',
                      child: AspectRatio(
                        aspectRatio:
                            _videoPlayerController.value.aspectRatio != null
                                ? _videoPlayerController.value.aspectRatio
                                : 16 / 9,
                        child: VideoPlayer(_videoPlayerController),
                        // child: BetterPlayer.network(
                        //   dataSource,
                        //   betterPlayerConfiguration: BetterPlayerConfiguration(
                        //     aspectRatio: 16 / 9,
                        //   ),
                        // ),
                      ),
                    )
                  : (initialized
                      ? AspectRatio(
                          aspectRatio:
                              _videoPlayerController.value.aspectRatio != null
                                  ? _videoPlayerController.value.aspectRatio
                                  : 16 / 9,
                          child: VideoPlayer(_videoPlayerController),
                        )
                      : Container(
                          height: ScreenUtil().setWidth(500),
                          width: ScreenUtil().setWidth(750),
                          // color: Colors.white,
                          child: Stack(
                            children: [
                              Container(
                                height: ScreenUtil().setWidth(500),
                                width: ScreenUtil().setWidth(750),
                                child: CachedNetworkImage(
                                    height: ScreenUtil().setWidth(500),
                                    width: ScreenUtil().setWidth(750),
                                    filterQuality: FilterQuality.high,
                                    imageUrl: (KSet.imgOrigin +
                                            (video
                                                ? item['video']
                                                : item['imageName'])) +
                                        '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,w_750'),
                              ),
                              Positioned(
                                bottom: ScreenUtil().setWidth(150),
                                left: ScreenUtil().setWidth(345),
                                child: Container(
                                  height: ScreenUtil().setWidth(60),
                                  width: ScreenUtil().setWidth(60),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    backgroundColor: Colors.transparent,
                                    color: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromRGBO(255, 255, 255, 1)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
            ),
            Container(
              width: ScreenUtil().setWidth(750),
            ),
            // ClosedCaption(text: _videoPlayerController.value.caption.text),
            _closedCaption(),
            // _ControlsOverlay(controller: _videoPlayerController),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                // width: ScreenUtil().setWidth(700),
                height: ScreenUtil().setWidth(50),
                padding: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
                // color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _doTimes(),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: VideoProgressIndicator(
                          _videoPlayerController,
                          allowScrubbing: true,
                          padding: EdgeInsets.only(top: 0),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    InkWell(
                      onTap: () {
                        if (_videoPlayerController.value.volume == 0.0) {
                          _videoPlayerController.setVolume(1.0);
                        } else {
                          _videoPlayerController.setVolume(0.0);
                        }
                      },
                      child: Icon(
                        _videoPlayerController.value.volume == 1.0
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white,
                        size: ScreenUtil().setWidth(34),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    InkWell(
                      onTap: () async {
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return FullVideoPage(
                        //     controller: _videoPlayerController,
                        //     dataSource: dataSource,
                        //   );
                        // }));
                        setState(() {
                          toFull = true;
                        });
                        Navigator.push(context, new MaterialPageRoute(
                            builder: (BuildContext context) {
                          if (Platform.isAndroid ||
                              _videoPlayerController.value.aspectRatio > 1) {
                            return FullVideoPage(
                              controller: _videoPlayerController,
                              dataSource: dataSource,
                              detail: widget.detail,
                              title: widget.item['title'],
                            );
                          } else {
                            return FullVideoPageIos(
                              controller: _videoPlayerController,
                              dataSource: dataSource,
                              detail: widget.detail,
                              title: widget.item['title'],
                            );
                          }
                        })).then((result) {
                          //处理代码
                          print('处理代码');
                          print(result);
                          if (result != null) {
                            setState(() {
                              // canshow = false;
                              _videoPlayerController = result;
                              initialized = true;
                              canshow = true;
                            });
                            // _videoPlayerController.play();
                            _videoPlayerController.addListener(() {
                              if (_videoPlayerController
                                      .value.position.inSeconds ==
                                  _videoPlayerController
                                      .value.duration.inSeconds) {
                                setState(() {
                                  isFinished = true;
                                });
                              } else {
                                setState(() {
                                  isFinished = false;
                                });
                              }
                            });
                          } else {
                            _inits();
                          }
                        });

                      },
                      child: Image.asset(
                        'static/full_screen_on.png',
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                      ),
                    ),
                  ],
                ),
                // child: _doTimes(),
                // child: VideoProgressIndicator(
                //   _videoPlayerController,
                //   allowScrubbing: true,
                //   padding: EdgeInsets.only(top: 20),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closedCaption() {
    return Stack(
      children: <Widget>[
        // AnimatedSwitcher(
        //   duration: Duration(milliseconds: 50),
        //   reverseDuration: Duration(milliseconds: 200),
        //   child: _videoPlayerController.value.isPlaying
        //       ? SizedBox.shrink()
        //       : Container(
        //           color: Colors.black26,
        //           height: 80,
        //           width: 80,
        //           child: Center(
        //             child: Icon(
        //               Icons.play_arrow,
        //               color: Colors.white,
        //               size: 100.0,
        //             ),
        //           ),
        //         ),
        // ),

        GestureDetector(
          onTap: () {},
          onHorizontalDragUpdate: (details) {
            // print(details);
          },
          child: Container(
            height: ScreenUtil().setWidth(500),
            width: ScreenUtil().setWidth(750),
            // color: Colors.red,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    print('okok');
                    if (isFinished) {
                      setState(() {
                        isPlay = false;
                        _videoPlayerController.seekTo(Duration(seconds: 0));
                      });
                      _videoPlayerController.play();
                    } else if (_videoPlayerController.value.isPlaying) {
                      print('oOOO');
                      setState(() {
                        isPlay = false;
                      });
                      _videoPlayerController.pause();
                    } else {
                      setState(() {
                        isPlay = true;
                      });
                      _videoPlayerController.play();
                    }
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(500),
                    width: ScreenUtil().setWidth(750),
                    // color: Colors.red,
                    child: _doIcons(),
                    // color: (_videoPlayerController.value.isPlaying)
                    //     ? Colors.transparent
                    //     : Color.fromRGBO(0, 0, 0, 0.5),
                  ),
                ),
              ],
            ),
            color: (_videoPlayerController.value.isPlaying)
                ? Colors.transparent
                : Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: _videoPlayerController.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              _videoPlayerController.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${_videoPlayerController.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _doTimes() {
    print('长度');
    print(_videoPlayerController.value);
    if (_videoPlayerController.value.duration != null) {
      var cur = _videoPlayerController.value.position.toString();

      cur = cur.substring(2, 7);
      var dur = _videoPlayerController.value.duration.toString();
      dur = dur.substring(2, 7);
      return RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: cur + '/',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
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
      // _inits();
      return Text(
        'loading...',
        style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(26)),
      );
    }
  }

  Widget _beImage() {
    return InkWell(
      onTap: () {
        if (_videoPlayerController == null || !initialized) {
          _inits();

          // Future.delayed(Duration(milliseconds: 300)).then((e) {
          //   if (initialized) {
          //     // 视频已初始化
          //     print('视频已初始化');
          //     // Future.delayed(Duration(milliseconds: 500)).then((e) {
          //     _videoPlayerController.play();
          //     // });
          //   } else {
          //     //未初始化
          //     print('视频未初始化-------------------');
          //     print('dataSource $dataSource');
          //     // VideoPlayerController _videoPlayerControllers =
          //     //     VideoPlayerController.network(dataSource);

          //     // _inits();
          //     // setState(() {
          //     // _videoPlayerController = VideoPlayerController.network(dataSource);
          //     _videoPlayerController.initialize().then((_) {
          //       _videoPlayerController.play();
          //     });
          //     // });
          //   }
          // });
        } else {
          setState(() {
            canshow = true;
          });
          _videoPlayerController.play();
        }
      },
      child: Container(
        // color: Colors.blue,
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setWidth(500),
        alignment: Alignment.center,
        child: Stack(
          children: [
            canshow || !initialized
                ? Container(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setWidth(500),
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                        height: ScreenUtil().setWidth(500),
                        width: ScreenUtil().setWidth(750),
                        filterQuality: FilterQuality.high,
                        imageUrl: (KSet.imgOrigin +
                                (video ? item['video'] : item['imageName'])) +
                            '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,w_750'),
                    // width: ScreenUtil().setWidth(750),

                    // child: Image.network(),
                  )
                : Container(
                    height: 0,
                  ),
            Positioned(
              child: Container(
                alignment: Alignment.center,
                color: Color.fromRGBO(0, 0, 0, 0.1),
                child: canshow && (!initialized)
                    ? Container(
                        width: ScreenUtil().setWidth(60),
                        height: ScreenUtil().setWidth(60),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(254, 149, 0, 100)),
                        ),
                      )
                    : (!canshow || !_videoPlayerController.value.isPlaying
                        ? Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40.0,
                          )
                        : Text('')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // item = widget.item;

    if (!widget.detail) {
      return VisibilityDetector(
        key: Key(item['postId'].toString()),
        onVisibilityChanged: (VisibilityInfo info) async {
          var visiblePercentage = info.visibleFraction * 100;
          print(visiblePercentage);
          if (visiblePercentage >= 99) {
            if (!video) {
              canshow = true;
              _videoPlayerController.play();
            }
          } else {
            print('778899');
            print(_videoPlayerController);
            if (_videoPlayerController != null) {
              _videoPlayerController.pause();
            }
          }
        },
        child: Container(
          color: Colors.black,
          height: ScreenUtil().setWidth(500),
          child: (canshow && initialized) ? _videos() : _beImage(),
          // child: canshow?_videos():Image.network(KSet.imgOrigin+),
        ),
      );
    } else {
      // _videoPlayerController.play();
      return Container(
        height: ScreenUtil().setWidth(500),
        child: _videos(),
      );
    }
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);
  static const _examplePlaybackRates = [
    0.5,
    1.0,
    1.5,
    2.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  height: 80,
                  width: 80,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        Container(
          height: ScreenUtil().setWidth(420),
          width: ScreenUtil().setWidth(750),
          color: Colors.red,
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 100.0,
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            Future.delayed(Duration(milliseconds: 500)).then((e) {
              try {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              } catch (e) {}
            });
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
