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
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    item = widget.item;
    // islink('https://chao.fun我的炒饭https://chao.fun和https://www.baidu.com');
  }

  @override
  Widget build(BuildContext context) {
    if (item['children'] != null) {
      // a = (item['children'] as List).cast();
      a = item['children'];
    }
    return _comItem(widget.item);
  }

  Widget ddd(coms) {
    return Container(
      padding: EdgeInsets.only(top: 5, left: 10, bottom: 0),
      child: ListView.builder(
        primary: true,
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        itemBuilder: (c, i) {
          return _comItem(coms[i]);
        },
        // itemExtent: 100.0,
        itemCount: coms.length,
      ),
    );
  }

  Widget _comItem(item) {
    var a;
    if (item['children'] != null) {
      // a = (item['children'] as List).cast();
      a = item['children'];
    }
    return Container(
      padding: EdgeInsets.only(left: 10, top: 4, bottom: 0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 0.5, color: Color.fromRGBO(241, 241, 241, 1)),
          top: BorderSide(width: 0.5, color: Color.fromRGBO(241, 241, 241, 1)),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setWidth(50),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
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
                              width: 6,
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
                                  left: 2, right: 2, top: 2, bottom: 2),
                              color: Color.fromRGBO(221, 221, 221, 0.5),
                              child: Text(
                                item['userInfo']['userTag']['data'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                  color: Color.fromRGBO(33, 29, 47, 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              padding: EdgeInsets.only(left: 4, right: 4),
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
                            Expanded(
                              child: Text(''),
                              flex: 1,
                            ),
                            item['canDeleted']
                                ? InkWell(
                              onTap: () {
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
                              child: Image.asset(
                                'assets/images/_icon/dele_comment.png',
                                width: 20,
                                height: 20,
                              ),
                            )
                                : Text('')
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
                                                'https://i.chao.fun/biz/7101be096e69b69ab4e296a9f92bea76.jpg',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            // width: 30,
            height: ScreenUtil().setWidth(50),
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
                          style: KFont.descFontStyle),
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
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          '回复',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                    ),
                    item['forumAdmin'] == true ? InkWell(
                      onTap: () async {
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
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          item['forumAdminHighlight'] == true ? '取消高亮': '高亮',
//                           '高亮',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                    ): Text(''),
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
              toNavigate({'url': listUrl[i], 'title': '外部链接'});
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

  void toNavigate(Map args) {
    String u = '';

    String url = 'https://chao.fun';
    String title = '炒饭 - 分享奇趣、发现世界';

    if (args.containsKey("url")) {
      url = args['url'].toString();
    } else {
      return;
    }

    if (args.containsKey("title")) {
      title = args['title'].toString();
    }

    var arguments = {};

    var nativePush = false;

    if (url == 'https://chao.fun' ||
        url.startsWith("https://chao.fun/") ||
        url.startsWith("https://www.chao.fun/") ||
        url.startsWith("http://chao.fun") ||
        url.startsWith("http://www.chao.fun")) {
      var newUrl = url
          .replaceAll("https://chao.fun/", "")
          .replaceAll("https://www.chao.fun/", "")
          .replaceAll("http://chao.fun", "")
          .replaceAll("http://www.chao.fun", "");

      var a = newUrl.split('/');
      print('打印出来；$a');
      if (a.length >= 2 && (a[0] == 'f' || a[0] == 'p' || a[0] == 'user')) {
        nativePush = true;
        String start = a[0];
        String end = a[1];
        switch (start) {
          case "f":
            u = '/forumpage';
            arguments = {'forumId': end};
            break;
          case "user":
            u = '/userMemberPage';
            arguments = {'userId': end};
            break;
          case "p":
            u = '/postdetail';
            arguments = {'postId': end};
            break;
        }
        Navigator.pushNamed(context, u, arguments: arguments);
      } else if (a[0] == "route" && a[2] != null && a[2] == 'message') {
        nativePush = true;
        Provider.of<CurrentIndexProvide>(context, listen: false).setIndex(3);
      }
    }

    if (!nativePush) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaoFunWebView(
            url: url,
            title: title,
            showAction: 0,
            cookie: true,
          ),
        ),
      );
    }
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
