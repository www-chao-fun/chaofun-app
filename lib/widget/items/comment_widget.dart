import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/content_utils.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';

import '../im/ui.dart';

class CommentWidget extends StatefulWidget {
  String imgurl;
  Map item;
  Function callBack;
  CommentWidget({Key key, this.imgurl, this.item, this.callBack})
      : super(key: key);
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  var item;
  var a;

  Duration duration = Duration();
  var init = false;

  AudioPlayer player = null;
  var playing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    if (item['audio'] != null) {
      player = AudioPlayer();
      duration = Duration();
      getDuration();
    }
    // islink('https://chao.fan我的炒饭https://chao.fan和https://www.baidu.com');
  }

  @override
  void dispose() {
    super.dispose();
    if (player != null) {
      player.stop();
      player.dispose();
    }
  }

  Future<void> getDuration() async {
    if (init == false) {
      try {
        var tmpDuration = await player.setAudioSource(AudioSource.uri(Uri.parse('https://chaofun.oss-cn-hangzhou.aliyuncs.com/' + widget.item['audio'])));
        if (tmpDuration != null) {
          setState(() {
            duration = tmpDuration;
          });
        }
        init = true;
      } catch (e) {

      }
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (item['children'] != null) {
      // a = (item['children'] as List).cast();
      a = item['children'];
    }
    return _comItem(widget.item,);
  }

  Widget ddd(coms) {
    return Container(
      padding: EdgeInsets.only(top: 2, left: 10, bottom: 0),
      child: ListView.builder(
        primary: true,
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        itemBuilder: (c, i) {
          return CommentWidget(key: Key(coms[i]['id'].toString()), item: coms[i], callBack: widget.callBack,);
        },
        // itemExtent: 100.0,
        itemCount: coms.length,
      ),
    );
  }

  Widget _comItem(Map item) {

    var a;
    if (item['children'] != null) {
      // a = (item['children'] as List).cast();
      a = item['children'];
    }
    return Container(
      padding: EdgeInsets.only(left: 10, top: 2, bottom: 0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: ScreenUtil().setWidth(1),
             color: Theme.of(context).hintColor),
          // top: BorderSide(width: 0.5, color: Theme.of(context).hintColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            key: item['globalKey'],
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(bottom: 0),
                  color: item['forumAdminHighlight'] == true ? Color(0x610DC781) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/userMemberPage',
                                    arguments: {
                                      "userId":
                                      item['userInfo']['userId'].toString()
                                    },
                                  );
                                }, child:
                            Container(
                              width: ScreenUtil().setWidth(35),
                              height: ScreenUtil().setWidth(35),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(25)),
                                child: Image.network(
                                  KSet.imgOrigin +
                                      item['userInfo']['icon'] +
                                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 2,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/userMemberPage',
                                  arguments: {
                                    "userId":
                                    item['userInfo']['userId'].toString()
                                  },
                                );
                              },
                              child: Text(
                                item['userInfo']['userName'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: KColor.defaultLinkColor,
                                ),
                              ),
                            ),
                            item['userInfo']['userTag'] != null
                                ? Container(
                              margin: EdgeInsets.only(
                                  left: 1, right: 1, top: 1, bottom: 1),
                              color: Color.fromRGBO(221, 221, 221, 0.5),
                              child: Text(
                                item['userInfo']['userTag']['data'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              padding: EdgeInsets.only(left: 1, right: 1),
                            )
                                : Text(''),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 0),
                              child: Text(
                                ' · ' + Utils.moments(item['gmtCreate']),
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(22),
                                  color: item['forumAdminHighlight'] == true ? Colors.black: Color.fromRGBO(204, 204, 204, 1),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            item['forumAdminHighlight'] ? Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 0),
                              child: Text(
                                ' · ' + "版主高亮中",
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(22),
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ): Text(''),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      item['text'] == null || item['text'] == ''  ? new Container() : InkWell(
                        onTap: () {
                          widget.callBack(item);
                        },
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: item['text']));
                          Fluttertoast.showToast(
                            msg: '复制成功',
                            gravity: ToastGravity.CENTER,
                            // textColor: Colors.grey,
                          );
                          print('长按复制');
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.blue,
                          child: !islink(item['text'])
                              ? Text(
                            item['text'] != null ? item['text'] : '',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            // overflow: TextOverflow.ellipsis,
                          )
                              : _doRichText(item['text']),
                        ),
                      ),
                      item['imageNames'] != null
                          ? Container(
                        height: ScreenUtil().setWidth(145),
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(10),
                          bottom: ScreenUtil().setWidth(10),
                        ),
                        child: GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: ScreenUtil().setWidth(8),
                            crossAxisSpacing: ScreenUtil().setWidth(8),
                          ),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  FadeRoute(
                                    page: JhPhotoAllScreenShow(
                                      imgDataArr: doImgList2(
                                          item['imageNames']
                                              .split(',')), //[imgurl],
                                      index: index,
                                      heroTag:
                                      'https://chaofun.oss-cn-hangzhou.aliyuncs.com/biz/7101be096e69b69ab4e296a9f92bea76.jpg',
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: ScreenUtil().setWidth(150),
                                  // color: Colors
                                  //     .primaries[index % Colors.primaries.length],
                                  child: CachedNetworkImage(
                                    filterQuality: FilterQuality.high,
                                    imageUrl: KSet.imgOrigin +
                                        item['imageNames']
                                            .split(',')[index] +
                                        '?x-oss-process=image/resize,,h_300/format,webp/quality,q_75',
                                    // fit: BoxFit.fitHeight,
                                    fit: BoxFit.cover,
                                    height: ScreenUtil().setWidth(150),
                                    placeholder: (context, url) => Center(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          backgroundColor:
                                          Colors.transparent,
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                              Color.fromRGBO(
                                                  254, 149, 0, 100)),
                                        ),
                                      ),
                                    ),
                                    // fit: BoxFit.scaleDown,
                                    // height:
                                    //     ScreenUtil().setWidth(hight),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: item['imageNames'].split(',').length,
                        ),
                      )
                          : Container(
                        height: ScreenUtil().setWidth(0),
                      ),
                      item['audio'] != null
                          ? new Container(
                        width: ScreenUtil().setWidth(380),
                        height: ScreenUtil().setWidth(70),
                        padding: EdgeInsets.only(right: 10.0),
                        child:
                        new FlatButton(
                          padding: EdgeInsets.only(left: 0, right: 4.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StreamBuilder<PlayerState>(
                                  stream: player.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState = playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (processingState == ProcessingState.loading ||
                                        processingState == ProcessingState.buffering) {
                                      return Text('');
                                    } else if (playing != true) {
                                      return Text('');
                                    } else if (processingState != ProcessingState.completed) {
                                      return Text('播放中...');
                                    } else {
                                      player.stop();
                                      return Text('');
                                    }
                                  }
                              ),
                              new Text(twoDigits((duration.inSeconds / 60).toInt()) + ':' + twoDigits((duration.inSeconds % 60).toInt()) , textAlign: TextAlign.start, maxLines: 1),
                              new Space(width: 10.0 / 2),
                              new Image.asset(
                                  'assets/images/chat/sound_left_3.webp',
                                  height: 20.0,
                                  color: Theme.of(context).textTheme.titleLarge.color,
                                  fit: BoxFit.cover),
                              new Space(width: 10.0)
                            ],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onPressed: () async {
                            if (!player.playing) {
                              player.setAudioSource(AudioSource.uri(Uri.parse('https://chaofun.oss-cn-hangzhou.aliyuncs.com/' + widget.item['audio'])));
                              player.play();
                            } else {
                              player.stop();
                            }
                          },
                        ),
                      )
                      : Container(
                        height: ScreenUtil().setWidth(0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            // width: 30,
            height: ScreenUtil().setWidth(40),
            alignment: Alignment.centerLeft,
            // color: Colors.black,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (item['vote'] == 1) {
                          setState(() {
                            item['ups'] = item['ups'] - 1;
                            item['vote'] = 0;
                          });
                        } else if (item['vote'] == 0) {
                          setState(() {
                            item['ups'] = item['ups'] + 1;
                            item['vote'] = 1;
                          });
                        } else if (item['vote'] == -1) {
                          setState(() {
                            item['ups'] = item['ups'] + 2;
                            item['vote'] = 1;
                          });
                        }
                        var response = await HttpUtil().get(Api.upvoteComment,
                            parameters: {'commentId': item['id']});
                      },
                      child: Container(
                        height: ScreenUtil().setWidth(40),
//                        color: Colors.white,
                        child: Container(
                          margin: EdgeInsets.only(left: 0, right: 10),
                          child: Image.asset(
                            item['vote'] == 1
                                ? 'assets/images/_icon/up_active.png'
                                : 'assets/images/_icon/zan.png',
                            width: ScreenUtil().setWidth(28),
                            height: ScreenUtil().setWidth(28),
                            // height: ScreenUtil().setHeight(60),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text((item['ups'] - item['downs']).toString(),
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    InkWell(
                      onTap: () async {
                        if (item['vote'] == 1) {
                          setState(() {
                            item['ups'] = item['ups'] - 2;
                            item['vote'] = -1;
                          });
                        } else if (item['vote'] == 0) {
                          setState(() {
                            item['ups'] = item['ups'] - 1;
                            item['vote'] = -1;
                          });
                        } else if (item['vote'] == -1) {
                          setState(() {
                            item['ups'] = item['ups'] + 1;
                            item['vote'] = 0;
                          });
                        }
                        var response = await HttpUtil().get(Api.downvoteComment,
                            parameters: {'commentId': item['id']});
                      },
                      child: Container(
                        // padding: EdgeInsets.only(left: 10),
                        // width: 40,
                        height: ScreenUtil().setWidth(40),
//                        color: Colors.white,
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 5),
                          child: Image.asset(
                            item['vote'] == -1
                                ? 'assets/images/_icon/down_active.png'
                                : 'assets/images/_icon/cai.png',
                            width: ScreenUtil().setWidth(28),
                            height: ScreenUtil().setWidth(28),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.callBack(item);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          '回复',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height: ScreenUtil().setWidth(350),
                                  child: Column(
                                    children: [
                                      item['forumAdmin'] == true? InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          if (item['forumAdminHighlight'] == true) {
                                            var res = await HttpUtil().get(Api.unHighLightComment,
                                                parameters: {'commentId': item['id']});
                                            if (res['success']) {
                                              setState(() {
                                                item['forumAdminHighlight'] = false;
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: res['errorMessage'],
                                                gravity: ToastGravity.CENTER,
                                              );
                                            }
                                          } else {
                                            var res = await HttpUtil().get(Api.highLightComment,
                                                parameters: {'commentId': item['id']});
                                            if (res['success']) {
                                              setState(() {
                                                item['forumAdminHighlight'] = true;
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: res['errorMessage'],
                                                gravity: ToastGravity.CENTER,
                                              );
                                            }
                                          }
                                        },
                                        child:
                                        Container(
                                          margin: EdgeInsets.only(left: 30, right: 30),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 0.5, color: KColor.defaultBorderColor),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: 10, right: 10),
                                          height: ScreenUtil().setWidth(90),
                                          child: Text('高亮'),
                                        ),
                                      ): Container(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          doWay(context);
                                        },
                                        child:
                                        Container(
                                          margin: EdgeInsets.only(left: 30, right: 30),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 0.5, color: KColor.defaultBorderColor),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: 10, right: 10),
                                          height: ScreenUtil().setWidth(90),
                                          child: Text('举报'),
                                        ),
                                      ),
                                      item['canDeleted'] ? InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          showCupertinoDialog(
                                            //showCupertinoDialog
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text('提示'),
                                                  content: Text('确认删除该评论吗？'),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text('取消'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop('cancel');
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      child: Text('确认'),
                                                      onPressed: () async {
                                                        var res = await HttpUtil()
                                                            .get(Api.deleteComment,
                                                            parameters: {
                                                              'commentId':
                                                              item['id']
                                                            });
                                                        if (res['success']) {
                                                          Navigator.of(context)
                                                              .pop('ok');
                                                          item['text'] = '【已删除】';
                                                          item['imageNames'] = null;
                                                          item['audio'] = null;
                                                          setState(() {
                                                            item = item;
                                                          });
                                                        } else {
                                                          Fluttertoast.showToast(
                                                            msg: res['errorMessage']
                                                                .toString(),
                                                            gravity:
                                                            ToastGravity.CENTER,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child:
                                        Container(
                                          margin: EdgeInsets.only(left: 30, right: 30),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 0.5, color: KColor.defaultBorderColor),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: 10, right: 10),
                                          height: ScreenUtil().setWidth(90),
                                          child: Text('删除'),
                                        ),
                                      ) : Container(),
                                    ],
                                  )
                              )
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.more_horiz_sharp, color:  Colors.grey,)
                        )
                    )
                  ],
                ),
              ],
            ),
          ),
          item['children'] != null && item['children'].length > 0
              ? Container(
                  child: ddd(a),
                )
              : Container(),
        ],
      ),
    );
  }

  _doRichText(txtContent) {
    var httpReg =
        new RegExp(r'(https|http|ftp|rtsp|mms)://[^(\,|\s|(\u4E00-\u9FFF)))]*');
    var link = httpReg.allMatches(txtContent);
    List listUrl = [];
    for (Match m in link) {
      listUrl.add(m.group(0));
    }
    txtContent = txtContent.replaceAll(httpReg, '###*k*_');
    // print('txtContent');
    print(txtContent);
    var arr = txtContent.split('###*k*_');
    List<TextSpan> brr = [];
    for (var i = 0; i < arr.length; i++) {
      brr.add(TextSpan(text: arr[i]));
      if (i < listUrl.length) {
        brr.add(TextSpan(
          text: ' ' + listUrl[i] + ' ',
          style:
              TextStyle(fontSize: ScreenUtil().setSp(28), color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              print(listUrl[i]);
              Utils.toNavigate(context, listUrl[i], '外部链接');
            }, //TapGestureRecognizer
        ));
      }
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: ScreenUtil().setSp(30), color: Colors.black),
        children: brr,
      ),
    );
    return Text('有链接');
    // for (Match m in link) {
    //   var str = m.group(0);
    //   txtContent.re
    //   listUrl.add(m.group(0));
    // }
  }

  islink(txtContent) {
    // var check_www = 'w{3}' + '[^\\s]*';
    // var check_http =
    //     '(https|http|ftp|rtsp|mms)://' + '[^(\\s|(\\u4E00-\\u9FFF)))]*';
    // var strRegex = check_http;
    var httpReg =
        new RegExp(r'(https|http|ftp|rtsp|mms)://[^(\s|(\u4E00-\u9FFF)))]*');
    var hasLink = httpReg.hasMatch(txtContent);
    var link = httpReg.allMatches(txtContent);
    List listUrl = [];
    for (Match m in link) {
      listUrl.add(m.group(0));
    }
    print(listUrl);
    print(link);
    print('+++++++++++++++');
    print(hasLink);
    return hasLink;
    // var formatTxtContent = txtContent.replace(httpReg, (httpText) {
    //   if (httpText.search('http') < 0 && httpText.search('HTTP') < 0) {
    //     return '<a class="link" href="' +
    //         'http://' +
    //         httpText +
    //         '" target="_blank">' +
    //         httpText +
    //         '</a>';
    //   } else {
    //     return '<a class="link" href="' +
    //         httpText +
    //         '" target="_blank">' +
    //         httpText +
    //         '</a>';
    //   }
    // });
    // return formatTxtContent;
  }

  var _reportController = TextEditingController();
  doWay(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
      new AnimatedPadding(
        padding: MediaQuery
            .of(context)
            .viewInsets, //边距（必要）
        duration: const Duration(milliseconds: 80), //时常 （必要）
        child: Container(
          height: ScreenUtil().setHeight(220),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  autofocus: true,
                  controller: _reportController,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.only(left: 10, top: 6, bottom: 4),
                    border: OutlineInputBorder(),
                    hintText: '请输入举报理由(可为空)',
                  ),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(0, 4, 10, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                  color: Colors.pink,
                  child: InkWell(
                    onTap: () {
                      toReport(context, _reportController.text, item['id'].toString());
                      // toUpReport(context, content, item);
                    },
                    child: Text(
                      '提交',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> toReport(BuildContext context, String reason, String id) async {
    var response = await HttpUtil().get(Api.upReport, parameters: {
      'contentType': 'comment',
      'reason': reason,
      'id': id
    });
    if (response['success']) {
      Fluttertoast.showToast(
        msg: '举报成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    }
    Navigator.of(context).pop();
  }

  doImgList2(lis) {
    var arr = [];
    lis.forEach((i) {
      arr.add(KSet.imgOrigin + i);
    });
    print('asd');
    print(lis);
    return arr;
  }
}
