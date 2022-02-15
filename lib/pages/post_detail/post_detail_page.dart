import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/user/at_user_list.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/items/MoreWidget.dart';
import 'package:flutter_chaofan/widget/items/bottom_widget.dart';
import 'package:flutter_chaofan/widget/items/commentItem_widget.dart';
import 'package:flutter_chaofan/widget/items/comment_widget.dart';
import 'package:flutter_chaofan/widget/items/predict_widget.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_chaofan/widget/items/vote_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:flutter_umeng_plugin/flutter_umeng_plugin.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/widget/items/link_widget.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

// arguments
class PostDetailPage extends StatefulWidget {
  final Map arguments;
  PostDetailPage({Key key, this.arguments}) : super(key: key);
  _PostDetailPageState createState() => _PostDetailPageState();
}

typedef OnSuccessList<T>(List<T> banners);

typedef OnFail(String message);

typedef OnSuccess<T>(T data);

class _PostDetailPageState extends State<PostDetailPage> {
  List<Map> commentList = [];
  String postId;
  Map postInfo;
  Map forumInfo;
  Map toWho;
  TextEditingController _inputController = TextEditingController();
  FocusNode _commentFocus = FocusNode();
  var comParams = {
    "postId": "",
    "pageNum": '1',
    "pageSize": "100",
    "order": 'hot'
  };

  var commentFuture;
  //96 93 99 96 120 设备金币
  HomeService homeService = HomeService();

  Future _gerData() async {
    var response =
        await HttpUtil().get(Api.listComments, parameters: comParams);
    return response;
  }

  var swiperIndex = 0;

  List imageList = [];
  List imagesUrl = [];
  List asd = [];

  var str;
  var atIndex;
  List atUserMap;

  var isLoading = false;
  var isUploadingImage = false;
  bool showImgs = false;

  List collectData = [];
  Widget oks;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      postId = widget.arguments['postId'];
      comParams['postId'] = postId;
    });
    // initUMeng();
    // commentFuture = _gerData();
    commentFuture = homeService.getCommentFuture(comParams, (response) {
      var data = (response as List).cast();
      var arr = [];
      data.forEach((item) {
        if (item['parentId'] == null) {
          arr.add(item);
        } else if (item['parentId'] != null) {
          var parentId = item['parentId'];
          data.forEach((item2) {
            if (parentId == item2['id']) {
              item['to'] = item2;
            }
          });
        }
      });
      var da = transformTree(data);

      setState(() {
        commentList = (da as List).cast();
      });
    }, (message) {
      print('失败了');
    });
    getPostInfo();
  }

  Map queryChildren(parent, list) {
    var children = [];

    for (var i = 0, len = list.length; i < len; i++) {
      if (list[i]['parentId'] == parent['id']) {
        var item = this.queryChildren(list[i], list);

        children.add(item);
      }
    }

    if (children.length > 0) {
      parent['children'] = children;
    }

    return parent;
  }

  transformTree(list) {
    var tree = [];

    for (var i = 0, len = list.length; i < len; i++) {
      if (list[i]['parentId'] == null) {
        var item = queryChildren(list[i], list);

        tree.add(item);
      }
    }

    return tree;
  }

  getComment() async {
    var comParam = comParams;

    var response = await HttpUtil().get(Api.listComments, parameters: comParam);
    var data = response['data'];
    var arr = [];
    data.forEach((item) {
      if (item['parentId'] == null) {
        arr.add(item);
      } else if (item['parentId'] != null) {
        var parentId = item['parentId'];
        data.forEach((item2) {
          if (parentId == item2['id']) {
            item['to'] = item2;
          }
        });
      }
    });
    var da = transformTree(data);

    setState(() {
      commentList = (da as List).cast();
    });
  }

  getPostInfo() async {
    var response =
        await HttpUtil().get(Api.getPostInfo, parameters: {'postId': postId});

    if (response['data'] == null) {
      Fluttertoast.showToast(
        msg: '获取帖子信息失败或帖子已被删除',
        gravity: ToastGravity.CENTER,
      );
      await Future.delayed(Duration(milliseconds: 1000));
      Navigator.pop(context);
    } else {
      getForumInfo(response['data']['forum']['id']);
      setState(() {
        postInfo = response['data'];
        oks = _doItem(context, postInfo);
      });
      if (response['data']['collection'] != null) {
        getCollectDatas(response['data']['collection']['id']);
      }
    }
  }

  getForumInfo(forumId) async {
    var response = await HttpUtil()
        .get(Api.getForumInfo, parameters: {'forumId': forumId});
    // getComment('422219');
    setState(() {
      forumInfo = response['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      //Platform
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ); //Colors.black38
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ); //Colors.black38
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: commentFuture,
        builder: (context, AsyncSnapshot asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(254, 149, 0, 100)),
              ));
            default:
              if (asyncSnapshot.hasError) {
                return new Text('error');
              } else {
                return Stack(
                  children: <Widget>[
                    postInfo != null && forumInfo != null
                        ? SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        constraints: BoxConstraints(
                          minHeight: 100,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 40 +
                                  MediaQueryData.fromWindow(window)
                                      .padding
                                      .top,
                            ),
                            _tools(),
                            postInfo['type'] != 'link' &&
                                postInfo['type'] != 'video' && postInfo['title'] != null && postInfo['title'].toString().trim() != ''
                                ? _postTitle()
                                : Container(
                              height: 0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                                right: 0,
                              ),
                              child: oks,
                            ),
                            // _timeLine(),
                            Container(
                              color: Colors.white,
                              padding:
                              EdgeInsets.only(left: 10, right: 10),
                              child: BottomWidget(
                                  item: postInfo,
                                  type: '1',
                                  toDou: () {
                                    if (Provider.of<UserStateProvide>(
                                        context,
                                        listen: false)
                                        .ISLOGIN) {
                                      // FocusScope.of(context).requestFocus(_commentFocus);
                                      setState(() {
                                        toWho = null;
                                        showImgs = false;
                                      });
                                      doWay(context);
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/accoutlogin',
                                        arguments: {"from": 'from'},
                                      );
                                    }
                                  }),
                            ),
                            Container(
                              height: 4,
                              color: KColor.defaultPageBgColor,
                            ),
                            postInfo['collection'] != null
                                ? _collectionLine(context)
                                : Container(),
                            Container(
                              height: 4,
                              color: KColor.defaultPageBgColor,
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.centerLeft,
                              margin:
                              EdgeInsets.only(bottom: 10, top: 20),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/_icon/n_comment.png',
                                        width: 14,
                                      ),
                                      Text(
                                        ' 评论区',
                                        style: TextStyle(
                                            fontSize:
                                            ScreenUtil().setSp(30)),
                                      ),
                                    ],
                                  ),

                                  InkWell(
                                    onTap: () {
                                      if (comParams['order'] == 'hot') {
                                        setState(() {
                                          comParams['order'] = 'new';
                                        });
                                      } else if (comParams['order'] == 'new') {
                                        setState(() {
                                          comParams['order'] = 'old';
                                        });
                                      } else {
                                        setState(() {
                                          comParams['order'] = 'hot';
                                        });
                                      }
                                      getComment();
                                    },
                                    child: RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                          text: '',
                                          style: TextStyle(
                                            fontSize:
                                            ScreenUtil().setSp(26),
                                            color: Color.fromRGBO(
                                                53, 140, 255, 1),
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                              PlaceholderAlignment
                                                  .middle,
                                              child: Image.asset(
                                                'assets/images/_icon/exchange.png',
                                                width: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text: getOrder(comParams['order']),

                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    33, 29, 47, 0.7),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  // assets/images/_icon/exchange.png
                                ],
                              ),
                            ),
                            // _comItems(commentList),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 0,
                                  bottom: 130),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      width: 0.5,
                                      color: Color.fromRGBO(241, 241, 241, 1)),
                                  top: BorderSide(
                                      width: 0.5,
                                      color: Color.fromRGBO(241, 241, 241, 1)),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: commentList.length > 0
                                  ? MediaQuery.removePadding(
                                removeTop: true,
                                context: context,
                                child: ListView.builder(
                                  primary: true,
                                  shrinkWrap:
                                  true, //为true可以解决子控件必须设置高度的问题
                                  physics:
                                  NeverScrollableScrollPhysics(), //禁用滑动事件
                                  itemBuilder: (c, i) {
                                    return CommentWidget(
                                        item: commentList[i],
                                        callBack: (item) {
                                          setState(() {
                                            toWho = item;
                                            showImgs = false;
                                          });
                                          if (Provider.of<
                                              UserStateProvide>(
                                              context,
                                              listen: false)
                                              .ISLOGIN) {
                                            // FocusScope.of(context).requestFocus(_commentFocus);
                                            doWay(context);
                                          } else {
                                            Navigator.pushNamed(
                                              context,
                                              '/accoutlogin',
                                              arguments: {
                                                "from": 'from'
                                              },
                                            );
                                          }
                                        });
                                  },
                                  // itemExtent: 100.0,
                                  itemCount: commentList.length,
                                ),
                              )
                                  : Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  '还没有评论哦~，快来发表看法吧！',
                                  style:
                                  TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Container(
                      height: 0,
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: MediaQueryData.fromWindow(window).padding.top),
                        width: ScreenUtil().setWidth(750),
                        height:
                        40 + MediaQueryData.fromWindow(window).padding.top,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/images/_icon/circle_back.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Provider.of<CurrentIndexProvide>(context,
                                    listen: false)
                                    .setIndex(0);
                                // Navigator.popUntil(
                                //     context, ModalRoute.withName('/'));
                                Navigator.of(context).popUntil(
                                        (route) => route.settings.name == ('/'));
                              },
                              child: Image.asset(
                                'assets/images/_icon/012.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            // Image.asset(
                            //   'assets/images/_icon/action.png',
                            //   width: 24,
                            //   height: 24,
                            // )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      child: _bottomLine(context),
                      left: 0,
                      bottom: 0,
                      right: 0,
                    ),
                    Positioned(
                        right: 15,
                        bottom: 80,
                        child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await this.getComment();
                                  Fluttertoast.showToast(
                                    msg: '刷新评论成功',
                                    gravity: ToastGravity.BOTTOM,
                                    // textColor: Colors.grey,
                                  );
                                  // Navigator.pushNamed(context, '/search',
                                  // arguments: {'forumData': forumData});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ]))

                  ],
                );
              }
          }
        },
      ),
    );
  }

  void getCollectDatas(id) async {
    var data = await HttpUtil()
        .get(Api.collectionlistPosts, parameters: {'collectionId': id});
    // response = response['data'];

    List<Map> res = (data['data'] as List).cast();
    // if (res.length > 9) {
    //   res = res.sublist(0, 9);
    // } else {}
    setState(() {
      // print('pagedata的数据长度是: ${pageData.length}');
      collectData.addAll(res);
    });
  }

  Widget _postType(item) {
    switch (item['type']) {
      case 'image':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.image_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.play_circle_outline_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
        break;
      case 'link':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.link_rounded,
            color: Colors.white,
            size: 20,
          ),
        );
        break;
      case 'vote':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.assessment,
            color: Colors.white,
            size: 20,
          ),
        );
        break;
      case 'article':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.article,
            color: Colors.white,
            size: 20,
          ),
        );
        break;
      default:
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.language,
            color: Colors.white,
            size: 20,
          ),
        );
    }
  }

  getOrder(text) {
    if (comParams['order'] == 'old') {
      return '时间';
    } else if (comParams['order'] == 'new') {
      return '最新';
    } else {
      return '最热';
    }
  }

  _collectionLine(context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      // color: Color.fromRGBO(241, 241, 241, 1),
      color: KColor.defaultPageBgColor,
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(80),
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Image.asset(
                'assets/images/_icon/heji.png',
                width: 14,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '合集·' + postInfo['collection']['name'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  color: Color.fromRGBO(108, 108, 108, 1),
                ),
              ),
            ]),
          ),
          Container(
            height: 120,
            width: ScreenUtil().setWidth(750),
            child: ListView.builder(
              itemCount: collectData.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/postdetail',
                      arguments: {
                        "postId": collectData[index]['postId'].toString()
                      },
                    );
                  },
                  child: Container(
                    width: 100,
                    color: Colors.white,
                    // height: 80,
                    margin: EdgeInsets.only(right: 6),
                    padding: EdgeInsets.all(2),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              child: _getImageUrl(collectData[index]),
                            ),
                            Container(
                              child: Text(
                                collectData[index]['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(26),
                                  color: KColor.defaultGray666,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          child:
                              postInfo['postId'] == collectData[index]['postId']
                                  ? ((collectData[index]['type'] == 'gif' ||
                                          collectData[index]['type'] ==
                                              'inner_video')
                                      ? Container(
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                              'assets/images/_icon/wave.gif'),
                                        )
                                      : Container(
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            'assets/images/_icon/eye.png',
                                            width: 14,
                                          ),
                                        ))
                                  : _postType(collectData[index]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _getImageUrl(item) {
    switch (item['type']) {
      case 'image':
        return Container(
          child: CachedNetworkImage(
            imageUrl: KSet.imgOrigin +
                item['imageName'] +
                '?x-oss-process=image/resize,w_200',
            fit: BoxFit.cover,
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          child: CachedNetworkImage(
            imageUrl: (KSet.imgOrigin +
                    (item['type'] == 'inner_video'
                        ? item['video']
                        : item['imageName'])) +
                '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,w_200',
            fit: BoxFit.cover,
          ),
        );
        break;
      case 'link':
        return Container(
          child: item['cover'] != null
              ? CachedNetworkImage(
                  imageUrl: (KSet.imgOrigin +
                      item['cover'] +
                      '?x-oss-process=image/resize,w_200'),
                  fit: BoxFit.cover,
                )
              : Image.asset('assets/images/_icon/link.png'),
        );
        break;
      case 'article':
        return item['imageName'] != null
            ? CachedNetworkImage(
                imageUrl: (KSet.imgOrigin +
                    item['imageName'] +
                    '?x-oss-process=image/resize,w_450'),
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl:
                    'https://i.chao.fun/biz/9563cdd828d2b674c424b79761ccb4c0.png',
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
        break;
      default:
        return Container(
          child: Text('不支持的类型'),
        );
    }
  }

  Offset _initialSwipeOffset;
  Offset _finalSwipeOffset;

  void _onHorizontalDragStart(DragStartDetails details) {
    _initialSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _finalSwipeOffset = details.globalPosition;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_initialSwipeOffset != null) {
      final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
      final direction = offsetDifference > 0 ? print('left') : print('right');
      if (offsetDifference > 0) {
        if (swiperIndex == postInfo['imageNums'] - 1) {
          setState(() {
            swiperIndex = 0;
            oks = _doItem(this.context, postInfo);
          });
        } else {
          setState(() {
            swiperIndex += 1;
            oks = _doItem(context, postInfo);
          });
        }
      } else {
        if (swiperIndex == 0) {
          setState(() {
            swiperIndex = postInfo['imageNums'] - 1;
            oks = _doItem(context, postInfo);
          });
        } else {
          setState(() {
            swiperIndex -= 1;
            oks = _doItem(context, postInfo);
          });
        }
      }
    }
  }

  SwiperController swipercontroller;

  Widget _manyImg(context, data) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: () {
              Navigator.of(context).push(
                FadeRoute(
                  page: JhPhotoAllScreenShow(
                    imgDataArr: asd,
                    index: swiperIndex,
                  ),
                ),
              );
            },
            child: Container(
              // height: 350,
              width: ScreenUtil().setWidth(750),
              child: Container(
                height: ScreenUtil().setWidth(750),
                child: CachedNetworkImage(
                  imageUrl: asd[swiperIndex] + '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: 5,
          // ),
          Container(
            color: Color.fromRGBO(95, 60, 94, 1),
            padding: EdgeInsets.only(top: 4),
            height: ScreenUtil().setWidth((asd.length > 5 ? 320 : 180)),
            constraints: BoxConstraints(
                // minHeight: ScreenUtil().setWidth(140),
                ),
            child: GridView.builder(
              padding: EdgeInsets.all(5),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: ScreenUtil().setWidth(8),
                crossAxisSpacing: ScreenUtil().setWidth(8),
                // childAspectRatio: 1.5,
              ),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Opacity(
                    opacity: index == swiperIndex ? 1 : 0.7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          swiperIndex = index;
                          oks = _doItem(context, postInfo);
                        });
                      },
                      child: Container(
                        // height: ScreenUtil().setWidth(100),
                        margin: const EdgeInsets.only(bottom: 0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          // image: DecorationImage(
                          //     image: NetworkImage(asd[index] +
                          //         '?x-oss-process=image/resize,h_225'),
                          //     fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(
                            Radius.circular(2),
                          ),
                          border: Border.all(
                            width: 1,
                            color: index == swiperIndex
                                ? Color.fromRGBO(255, 255, 0, 1)
                                : Colors.transparent,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              asd[index] + '?x-oss-process=image/resize,w_225',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: asd.length,
            ),
          ),
          // Container(
          //   color: Colors.black,
          //   padding: const EdgeInsets.only(top: 10),
          //   height: ScreenUtil().setHeight((asd.length == 3 ? 210 : 180)), // 高度
          //   child: Swiper(
          //     scrollDirection: Axis.horizontal, // 横向
          //     itemCount: asd.length, // 数量
          //     autoplay: false, // 自动翻页
          //     autoplayDelay: 5000,
          //     duration: 1000,
          //     // index: swiperIndex,
          //     loop: true,
          //     controller: swipercontroller,
          //     onIndexChanged: (index) {
          //       setState(() {
          //         this.swiperIndex = index;
          //       });
          //     },
          //     itemBuilder: (BuildContext context, int index) {
          //       // 构建
          //       return Container(
          //         margin: const EdgeInsets.only(bottom: 30),
          //         decoration: BoxDecoration(
          //           image: DecorationImage(
          //               image: NetworkImage(
          //                   asd[index] + '?x-oss-process=image/resize,h_225'),
          //               fit: BoxFit.cover),
          //           borderRadius: BorderRadius.all(
          //             Radius.circular(4),
          //           ),
          //         ),
          //       );
          //     },
          //     // itemWidth: MediaQuery.of(context).size.width, // 条目宽度
          //     // itemHeight: MediaQuery.of(context).size.height, // 条目高度
          //     onTap: (index) {
          //       print('点击了第${index}');
          //       setState(() {
          //         swiperIndex = index;
          //       });
          //       // swipercontroller.index = index;
          //     }, // 点击事件 onTap
          //     pagination: SwiperPagination(
          //         // 分页指示器
          //         alignment:
          //             Alignment.bottomCenter, // 位置 Alignment.bottomCenter 底部中间
          //         margin: const EdgeInsets.fromLTRB(0, 0, 0, 5), // 距离调整
          //         builder: DotSwiperPaginationBuilder(
          //           activeColor: Colors.yellow,
          //           color: Colors.white,
          //           size: ScreenUtil().setWidth(15),
          //           activeSize: ScreenUtil().setWidth(15),
          //           space: ScreenUtil().setWidth(10),
          //         )),
          //     viewportFraction: asd.length == 3
          //         ? 0.33
          //         : (asd.length == 4
          //             ? 0.3
          //             : 0.2), // 当前视窗展示比例 小于1可见上一个和下一个视窗 0.2
          //     scale: 0.9, // 两张图片之间的间隔
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _doItem(context, data) {
    if (data['type'] == 'image') {
      if (data['imageNums'] == 1) {
        // return _manyImg();
        return _doImage(data);
      } else if (data['imageNums'] == 2 || data['imageNums'] == 4) {
        // return _manyImg();
        if (data['imageNums'] == 4) {
          if (asd.length == 0) {
            this.asd = doImgList(data);
          }
          return _manyImg(context, data);
        } else {
          return getTwo(context, data);
        }
      } else {
        if (asd.length == 0) {
          this.asd = doImgList(data);
        }
        // return getThree(context, data);
        return _manyImg(context, data);
      }
    } else if (data['type'] == 'article') {
      return PostItemWidget(
        data: data,
      );
      // return Container(
      //   padding: EdgeInsets.only(
      //     left: ScreenUtil().setWidth(10),
      //     right: ScreenUtil().setWidth(10),
      //   ),
      //   child: (data['article'].startsWith('<p') ||
      //           data['article'].startsWith('<ol') ||
      //           data['article'].startsWith('<ul') ||
      //           data['article'].startsWith('<div') ||
      //           data['article'].startsWith('<h'))
      //       ? Html(
      //           data: data['article'],
      //           style: {
      //             'p': Style(
      //               fontSize: FontSize.large,
      //               lineHeight: LineHeight(1.5),
      //             ),
      //           },
      //           onImageTap: (src, _, __, ___) {
      //             Navigator.of(context).push(
      //               FadeRoute(
      //                 page: JhPhotoAllScreenShow(
      //                   imgDataArr: [src],
      //                   index: 0,
      //                 ),
      //               ),
      //             );
      //             print(src);
      //           },
      //           onLinkTap: (src, _, __, ___) {
      //             toNavigate(src, context);
      //             print(src);
      //           },
      //         )
      //       : Container(
      //           alignment: Alignment.centerLeft,
      //           padding: EdgeInsets.only(left: 5),
      //           child: Text(
      //             data['article'],
      //             style: TextStyle(
      //               height: 1.6,
      //               fontSize: ScreenUtil().setSp(32),
      //             ),
      //           ),
      //         ),
      // );
    } else if (data['type'] == 'gif') {
      return VideoWidget(
        item: data,
        height: 100,
        detail: true,
      );
    } else if (data['type'] == 'inner_video') {
      return VideoWidget(item: data, height: 320.0, detail: true, video: true);
    } else if (data['type'] == 'link' || data['type'] == 'video') {
      return LinkWidget(item: data);
    } else if (data['type'] == 'vote') {
      return VoteWidget(item: data);
    } else if (data['type'] == 'forward') {
      return _forwardWidget(context, data);
    } else if (data['type'] == 'prediction') {
      return Column(
        children: [
          PredictWidget(item: postInfo),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 5),
            height: ScreenUtil().setHeight(90),
            padding: EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              color: Color.fromRGBO(227, 237, 247, 1),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  postInfo['predictionsTournament']['name'],
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: Color.fromRGBO(83, 83, 83, 1),
                  ),
                ),
                MaterialButton(
                  color: Color.fromRGBO(255, 147, 0, 0.7),
                  child: new Text(
                    '点击查看',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                    ),
                  ),
                  elevation: 0,
                  minWidth: ScreenUtil().setWidth(180),
                  height: ScreenUtil().setWidth(60),
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/predictionpage', arguments: {
                      'forumId': data['forum']['id'],
                      'forumName': data['forum']['name'],
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
      // return PredictWidget(item: postInfo);
    } else {
      return _default();
    }
  }

  void toNavigate(url, context) {
    String u = '';

    // String url = 'https://chao.fun';
    String title = '炒饭 - 分享奇趣、发现世界';

    // if (args.containsKey("url")) {
    //   url = args['url'].toString();
    // } else {
    //   return;
    // }

    // if (args.containsKey("title")) {
    //   title = args['title'].toString();
    // }

    // var arguments = {};

    var nativePush = false;
    var arguments;

    if (url.startsWith("https://chao.fun/") ||
        url.startsWith("https://www.chao.fun") ||
        url.startsWith("http://chao.fun") ||
        url.startsWith("http://www.chao.fun") ||
        url.startsWith("https://chao.fun")) {
      var newUrl = url
          .replaceAll("https://chao.fun/", "")
          .replaceAll("https://www.chao.fun/", "")
          .replaceAll("http://chao.fun", "")
          .replaceAll("http://www.chao.fun", "");

      var a = newUrl.split('/');
      print('不一样');
      print(a);
      nativePush = true;
      if (a.length >= 2 && (a[0] == 'f' || a[0] == 'p' || a[0] == 'user')) {
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
//        Future.delayed(Duration(seconds: 1), () {
        if (u != '') {
          print('u');
          print(u);
          Navigator.pushNamed(context, u, arguments: arguments);
        } else {}

//        });
      } else {
        print('跳转首页');
        if (url == 'https://www.chao.fun' ||
            url == 'http://www.chao.fun' ||
            url == 'https://chao.fun' ||
            url == 'http://chao.fun' ||
            url == 'https://www.chao.fun/' ||
            url == 'http://www.chao.fun/' ||
            url == 'https://chao.fun/' ||
            url == 'http://chao.fun/') {
          Provider.of<CurrentIndexProvide>(context, listen: false)
              .currentIndex = 0;
          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => IndexPage()),
            (route) => route == null,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChaoFunWebView(
                url: url,
                title: title,
                showHeader: true,
                cookie: true,
              ),
            ),
          );
        }
      }
    }

    if (!nativePush) {
      title = '外部链接';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaoFunWebView(
            url: url,
            title: title,
            showHeader: true,
            cookie: false,
          ),
        ),
      );
    }
  }

  Widget _forwardWidget(context, item) {
    return Container(
      color: Color.fromRGBO(245, 245, 245, 1),
      padding: EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/postdetail',
                arguments: {"postId": item['sourcePost']['postId'].toString()},
              );
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item['sourcePost']['forum']['name'] +
                    ' · ' +
                    item['sourcePost']['title'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          _doItem(context, item['sourcePost']),
        ],
      ),
    );
  }

  Widget _default() {
    return Container(
      height: ScreenUtil().setWidth(150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
        width: 0.5,
        color: Color.fromRGBO(235, 235, 235, 1),
      )),
      child: Text(
        '当前版本不支持的类型，请尝试升级版本查看',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _btnPush(context, isJoin) {
    return Container(
      margin: EdgeInsets.only(bottom: 14, top: 14, right: 0),
      // width: ScreenUtil().setWidth(120),
      height: ScreenUtil().setWidth(44),
      alignment: Alignment.center,
      // color: ,
      child: MaterialButton(
        color: isJoin == 1 ? Colors.white : Colors.pink,
        textColor: isJoin == 1 ? Colors.grey : Colors.white,
        child: new Text(
          isJoin == 1 ? '已加入' : '加入',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
          ),
        ),
        minWidth: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(48),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: isJoin == 1 ? Colors.white : Colors.pink),
        ),
        onPressed: () async {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            // FocusScope.of(context).requestFocus(_commentFocus);
            Fluttertoast.showToast(
              msg: forumInfo['joined'] ? '已退出' : '已加入',
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
            if (isJoin == 1) {
              setState(() {
                forumInfo['joined'] = false;
              });
              var response = await HttpUtil().get(Api.leaveForum,
                  parameters: {'forumId': forumInfo['id']});
            } else {
              setState(() {
                forumInfo['joined'] = true;
              });
              var response = await HttpUtil()
                  .get(Api.joinForum, parameters: {'forumId': forumInfo['id']});
            }
          } else {
            Navigator.pushNamed(
              context,
              '/accoutlogin',
              arguments: {"from": 'from'},
            );
          }
        },
      ),
    );
  }

  callBackAt(v) {
    print('返回内容');
    print(v);
  }

  _bottomLine(context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(width: 0.5, color: Color.fromRGBO(241, 241, 241, 1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  if (Provider.of<UserStateProvide>(context, listen: false)
                      .ISLOGIN) {
                    // FocusScope.of(context).requestFocus(_commentFocus);
                    setState(() {
                      toWho = null;
                      showImgs = false;
                    });
                    doWay(context);
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/accoutlogin',
                      arguments: {"from": 'from'},
                    );
                  }
                },
                child: Container(
                  color: KColor.defaultPageBgColor,
                  height: ScreenUtil().setHeight(60),
                  padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '评论千万条，文明第一条',
                    style: TextStyle(color: KColor.defaultGrayColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  doWay(context) {
    showModalBottomSheet(
      isScrollControlled: true, // !important
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (c, setDialogState) {
          return AnimatedPadding(
            // padding: MediaQuery.of(context).viewInsets, //边距（必要）
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: ScreenUtil().setWidth(10),
              left: ScreenUtil().setWidth(10),
              right: ScreenUtil().setWidth(10),
            ),
            duration: const Duration(milliseconds: 100), //时常 （必要）
            child: Container(
              height: showImgs
                  ? ScreenUtil().setWidth(540)
                  : ScreenUtil().setWidth(240), //200
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10, top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: toWho == null ? '正在评论 · ' : '正在回复 · ',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(26),
                                color: Color.fromRGBO(33, 29, 47, 0.5),
                                // fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: toWho == null
                                      ? postInfo['title']
                                      : toWho['userInfo']['userName'] +
                                          '的评论-' +
                                          toWho['text'],
                                  style: TextStyle(
                                    color: Color.fromRGBO(33, 29, 47, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(120),
                          height: ScreenUtil().setWidth(60),
                          child: MaterialButton(
                            color: Color.fromRGBO(255, 147, 0, 0.8),
                            textColor: Colors.white,
                            minWidth: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setWidth(50),
                            elevation: 0,
                            child: Container(
                              // width: 30,
                              // height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                '评论',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(25),
                                ),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 0),
                            onPressed: () async {
                              print(imagesUrl);
                              var content = _inputController.text;
                              if (content.trim().isNotEmpty || imagesUrl.length != 0) {
                                // print('举报内容值为：${content}');
                                // toUpReport(context, content, item);
                                if (!isLoading) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var params = {
                                    'postId': postId,
                                    'comment': content,
                                    'imageNames': '',
                                    'ats': '',
                                  };
                                  if (atUserMap != null &&
                                      atUserMap.length > 0) {
                                    List finalAt = [];
                                    for (var i = 0; i < atUserMap.length; i++) {
                                      if (content.contains(
                                          '@' + atUserMap[i]['userName'])) {
                                        finalAt.add(atUserMap[i]['userId']);
                                      }
                                    }
                                    if (finalAt.length > 0) {
                                      params['ats'] = finalAt.join(',');
                                    }
                                  }

                                  if (imagesUrl.length > 0) {
                                    params['imageNames'] =
                                        imagesUrl.take(9).join(',');
                                  }
                                  if (toWho != null) {
                                    params['parentId'] = toWho['id'].toString();
                                  }
                                  print(params);
                                  var response = await HttpUtil().get(
                                      Api.userToComment,
                                      parameters: params);
                                  if (response['success']) {
                                    setState(() {
                                      isLoading = false;
                                      showImgs = false;
                                      imageList = [];
                                      imagesUrl = [];
                                    });
                                    _inputController.text = '';
                                    Fluttertoast.showToast(
                                      msg: '评论成功',
                                      gravity: ToastGravity.CENTER,
                                      // textColor: Colors.grey,
                                    );
                                    getComment();
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });

                                      Fluttertoast.showToast(
                                        msg: response['errorMessage'],
                                        gravity: ToastGravity.CENTER,
                                      );

                                  }
                                }
                              } else {
                                // print('举报内容值为空的');
                                Fluttertoast.showToast(
                                  msg: '评论不能为空哦~',
                                  gravity: ToastGravity.CENTER,
                                  // textColor: Colors.grey,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            // focusNode: _commentFocus,

                            autofocus: true,
                            controller: _inputController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 14, top: 6, right: 14, bottom: 6),
                              fillColor: Color(0x30cccccc),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0x00FF0000)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              hintText: '评论千万条，文明第一条',
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0x00000000)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                            ),

                            textInputAction: TextInputAction.send,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              // fontWeight: FontWeight.bold,
                            ),
                            onChanged: (val) {
                              print('旧值');
                              print(str);
                              print('输入的内容$val');
                              var lastStr;
                              var lastMap;
                              if (str != null &&
                                  val != null &&
                                  val.length > str.length) {
                                lastMap = findDiff(val, str);
                                lastStr = findDiff(val, str)['tt'];
                              }
                              if (val == '@' || lastStr == '@') {
                                var lastIndex;
                                if (val == '@') {
                                  lastIndex = 0;
                                } else {
                                  lastIndex = lastMap['index'];
                                }
                                setState(() {
                                  atIndex = lastIndex;
                                });
                                print('str$str');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AtUserListPage(callBackAt: callBackAt),
                                  ),
                                ).then((value) {
                                  print(value);
                                  if (value != null) {
                                    var cur = _inputController.text;
                                    var atStr = '';
                                    value.forEach((ele) {
                                      atStr += (' @' + ele['userName']);
                                    });
                                    print('at数据$atStr');
                                    cur = (cur.substring(0, atIndex) +
                                        atStr +
                                        ' ' +
                                        cur.substring(atIndex + 1, cur.length));
                                    print('最终数据$cur');
                                    setState(() {
                                      str = cur;
                                    });
                                    _inputController.value =
                                        _inputController.value.copyWith(
                                      text: cur,
                                      composing: TextRange.empty,
                                    );
                                    outRepeat(value);
                                  }
                                  print(str);
                                });
                              }
                              setState(() {
                                str = val;
                              });
                            },

                            onSubmitted: (term) async {
                              print(term);
                              var content = term;
                              if (content.trim().isNotEmpty || imagesUrl.length != 0) {
                                // print('举报内容值为：${content}');
                                // toUpReport(context, content, item);
                                if (!isLoading) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var params = {
                                    'postId': postId,
                                    'comment': content,
                                    'imageNames': '',
                                    'ats': '',
                                  };
                                  if (atUserMap != null &&
                                      atUserMap.length > 0) {
                                    List finalAt = [];
                                    for (var i = 0; i < atUserMap.length; i++) {
                                      if (content.contains(
                                          '@' + atUserMap[i]['userName'])) {
                                        finalAt.add(atUserMap[i]['userId']);
                                      }
                                    }
                                    if (finalAt.length > 0) {
                                      params['ats'] = finalAt.join(',');
                                    }
                                  }

                                  if (imagesUrl.length > 0) {
                                    params['imageNames'] =
                                        imagesUrl.take(9).join(',');
                                  }
                                  if (toWho != null) {
                                    params['parentId'] = toWho['id'].toString();
                                  }
                                  print(params);
                                  var response = await HttpUtil().get(
                                      Api.userToComment,
                                      parameters: params);
                                  if (response['success']) {
                                    setState(() {
                                      isLoading = false;
                                      showImgs = false;
                                      imageList = [];
                                      imagesUrl = [];
                                    });
                                    _inputController.text = '';
                                    Fluttertoast.showToast(
                                      msg: '评论成功',
                                      gravity: ToastGravity.CENTER,
                                      // textColor: Colors.grey,
                                    );
                                    getComment();
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: response['errorMessage'],
                                      gravity: ToastGravity.CENTER,
                                    );
                                  }
                                }
                              } else {
                                // print('举报内容值为空的');
                                Fluttertoast.showToast(
                                  msg: '评论不能为空哦~',
                                  gravity: ToastGravity.CENTER,
                                  // textColor: Colors.grey,
                                );
                              }
                              // 这里进行事件处理
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            print('点击了');
                            setDialogState(() {
                              showImgs = !showImgs;
                            });
                          },
                          child: Container(
                            child: Icon(
                              Icons.add_circle_outline_rounded,
                              size: ScreenUtil().setWidth(60),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  showImgs ?
                       Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            top: ScreenUtil().setWidth(10),
                            right: ScreenUtil().setWidth(20),
                          ),
                          color: Colors.white30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              isUploadingImage ? Text("上传中") : InkWell(
                                onTap: () {
                                  if (imagesUrl.length < 9) {
                                    getImage(false);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: '最多上传9张图片',
                                      gravity: ToastGravity.CENTER,
                                      // textColor: Colors.grey,
                                    );
                                  }
                                },
                                child: Icon(
                                  Icons.photo_library,
                                  color: Color.fromRGBO(153, 153, 153, 1),
                                  size: ScreenUtil().setWidth(56),
                                ),
                              ),
                            ],
                          ),

                  ): Container(),
                  showImgs
                      ? Container(
                          height: ScreenUtil().setWidth(220),
                          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: ScreenUtil().setWidth(180),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: ScreenUtil().setWidth(180),
                                        width: ScreenUtil().setWidth(180),
                                        child: Image.file(
                                          File(imageList[index].path),
                                          height: ScreenUtil().setWidth(180),
                                          width: ScreenUtil().setWidth(180),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 20,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            setDialogState(() {
                                              imageList.removeAt(index);
                                              imagesUrl.removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.delete_forever,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: imageList.length,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  outRepeat(arr) {
    // var repeat = ['aa', 'bb', 'cc', 'aa', 'bb'];
    var brr = [];
    var crr = [];
    arr.forEach((it) {
      if (!crr.contains(it['userId'])) {
        crr.add(it['userId']);
        brr.add({
          'userId': it['userId'],
          'userName': it['userName'],
        });
      }
    });
    setState(() {
      atUserMap = brr;
    });
    // var dedu = new Set(); //用set进行去重
    // dedu.addAll(brr); //把数组塞进set里
    // print(dedu); // 打印出{aa, bb, cc}
    // print(dedu.toList()); //在转换为数组
    // return dedu.toList();
  }

  Map findDiff(newdata, olddata) {
    var tt;
    var index;
    for (var i = 0; i < olddata.length; i++) {
      if (newdata[i] != olddata[i]) {
        tt = newdata[i];
        index = i;
        print('当前输入的值是TTTTTTTTTTT');
        print(newdata[i]);
        break;
      }
    }
    if (tt == null) {
      tt = newdata[newdata.length - 1];
      index = newdata.length - 1;
      print('当前输入的值是$tt');
    }
    return {"index": index, "tt": tt};
  }

  Future getImage(isTakePhoto) async {
    // Navigator.pop(context);
    // var image = await ImagePicker.pickImage(
    //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
    List res = await ImagesPicker.pick(
      count: 9 - imagesUrl.length,
      pickType: PickType.image,
      maxSize: 20480,
      quality: 0.8,
      // cropOpt: CropOption(aspectRatio: CropAspectRatio.wh16x9),
      cropOpt: CropOption(
        aspectRatio: CropAspectRatio.custom,
        cropType: CropType.rect,
      ),
    );
    if (res != null) {
      print(res);
      setState(() {
        imageList.addAll(res.map((e) {
          return File(e.path);
        }).toList());
        imagesUrl.addAll(new List(res.length));
      });

      setState(() {
        isLoading = true;
        isUploadingImage = true;
      });
      // Navigator.pop(context);
      // doWay(context);
      for (var i = (imageList.length - res.length); i < imageList.length; i++) {
        _upLoadImage(imageList[i], i);
      }
    }
  }

  //上传图片
  //上传图片
  _upLoadImage(File image, int i) async {
    print(imagesUrl.toString());
    print(isUploadingImage);
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });
    Dio dio = new Dio();
    var response =
        await dio.post("https://chao.fun/api/upload_image", data: formdata);
    print('上传结束');
    print(response);
    print(response.data['data']);
    if (response.data['success']) {
      setState(() {
        imagesUrl[i] = response.data['data'];
      });

    } else {
      setState(() {
        isLoading = false;
        isUploadingImage = false;
        imageList.removeAt(i);
        imagesUrl.removeAt(i);
      });
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
    int count = 0;
    for (int i = 0 ; i < imageList.length; i++) {
      if (imagesUrl[i] == null) {
        count ++;
      }
    }
    if (count == 0) {
      setState(() {
        isLoading = false;
        isUploadingImage = false;
      });
      Navigator.pop(context);
      doWay(context);
    }
  }

  _postTitle() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
      color: Colors.white,
      child: InkWell(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: postInfo['title']));
          Fluttertoast.showToast(
            msg: '已复制标题',
            gravity: ToastGravity.BOTTOM,
            // textColor: Colors.grey,
          );
        },
        child: RichText(
          text: TextSpan(
            text: (postInfo['tags'] != null && postInfo['tags'].length > 0
                ? ('[' + postInfo['tags'][0]['name'] + '] ')
                : ''),
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              // color: Color.fromRGBO(255, 147, 0, 1),
              color: (postInfo['tags'] != null &&
                      postInfo['tags'].length > 0 &&
                      postInfo['tags'][0]['backgroundColor'] != null &&
                      postInfo['tags'][0]['backgroundColor'] != null)
                  ? fromHex(postInfo['tags'][0]['backgroundColor'])
                  : Color.fromRGBO(255, 147, 0, 1),
              // fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text: postInfo['title'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  color: KColor.defaultTitleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // child: Text(
        //   postInfo['title'],
        //   style: TextStyle(
        //     fontSize: ScreenUtil().setSp(34),
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ),
    );
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  _tools() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 4, left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/forumpage',
                        arguments: {
                          "forumId": postInfo['forum']['id'].toString()
                        },
                      );
                    },
                    child: Container(
                      child: Image.network(
                        KSet.imgOrigin +
                            postInfo['forum']['imageName'] +
                            '?x-oss-process=image/resize,h_80',
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // padding: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/forumpage',
                                arguments: {
                                  "forumId": postInfo['forum']['id'].toString()
                                },
                              );
                            },
                            child: Container(
                              child: Text(
                                postInfo['forum']['name'],
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(32)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/userMemberPage',
                                arguments: {
                                  "userId":
                                      postInfo['userInfo']['userId'].toString()
                                },
                              );
                            },
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  text: postInfo['userInfo']['userName'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(26),
                                    color: Color.fromRGBO(53, 140, 255, 1),
                                    // fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    postInfo['userInfo']['userTag'] != null
                                        ? WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 2,
                                                  right: 2,
                                                  top: 2,
                                                  bottom: 2),
                                              color: Color.fromRGBO(
                                                  221, 221, 221, 0.5),
                                              child: Text(
                                                postInfo['userInfo']['userTag']
                                                    ['data'],
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(24),
                                                  color: Color.fromRGBO(
                                                      33, 29, 47, 0.5),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              padding: EdgeInsets.only(
                                                  left: 4, right: 4),
                                            ),
                                          )
                                        : TextSpan(
                                            text: '',
                                          ),
                                    TextSpan(
                                      text: ' · ' +
                                          Utils.moments(postInfo['gmtCreate']),
                                      style: TextStyle(
                                        color: Color.fromRGBO(33, 29, 47, 0.3),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      MoreWidget(item: postInfo).show(context);
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(80),
                      padding: EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/icon/more.png',
                        width: ScreenUtil().setWidth(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // _updown(),
          // _attention(context),
        ],
      ),
    );
  }

  // 点赞
  Widget _updown() {
    return Container(
      height: ScreenUtil().setHeight(40),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () async {
              if (postInfo['vote'] == 1) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] - 1;
                  postInfo['vote'] = 0;
                });
              } else if (postInfo['vote'] == 0) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] + 1;
                  postInfo['vote'] = 1;
                });
              } else if (postInfo['vote'] == -1) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] + 2;
                  postInfo['vote'] = 1;
                });
              }
              var response = await HttpUtil().get(Api.upvotePost,
                  parameters: {'postId': postInfo['postId']});
            },
            child: Image.asset(
              postInfo['vote'] == 1
                  ? 'assets/images/_icon/up_active.png'
                  : 'assets/images/_icon/zan.png',
              width: 16,
              // height: ScreenUtil().setHeight(60),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text((postInfo['ups'] - postInfo['downs']).toString(),
                style: KFont.descFontStyle),
          ),
          InkWell(
            onTap: () async {
              if (postInfo['vote'] == 1) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] - 2;
                  postInfo['vote'] = -1;
                });
              } else if (postInfo['vote'] == 0) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] - 1;
                  postInfo['vote'] = -1;
                });
              } else if (postInfo['vote'] == -1) {
                setState(() {
                  postInfo['ups'] = postInfo['ups'] + 1;
                  postInfo['vote'] = 0;
                });
              }
              var response = await HttpUtil().get(Api.downvotePost,
                  parameters: {'postId': postInfo['postId']});
            },
            child: Image.asset(
              postInfo['vote'] == -1
                  ? 'assets/images/_icon/down_active.png'
                  : 'assets/images/_icon/cai.png',
              width: 16,
              // height: ScreenUtil().setHeight(60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomForum(context) {
    if (forumInfo != null) {
      return ClipRRect(
        // borderRadius: BorderRadius.circular(10),
        child: Container(
          // color: KColor.defaultPageBgColor,
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: KColor.defaultBorderColor,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: ClipOval(
                  child: Image.network(
                    KSet.imgOrigin +
                        postInfo['userInfo']['icon'] +
                        '?x-oss-process=image/resize,h_80',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          postInfo['userInfo']['userName'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          postInfo['userInfo']['desc'] != null
                              ? postInfo['userInfo']['desc']
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              postInfo['userInfo']['focused']
                  ? Container(
                      child: MaterialButton(
                        color: Colors.white,
                        textColor: Colors.grey,
                        child: new Text(
                          '已关注',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                        minWidth: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setWidth(44),
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (Provider.of<UserStateProvide>(context,
                                  listen: false)
                              .ISLOGIN) {
                            // FocusScope.of(context).requestFocus(_commentFocus);
                            setState(() {
                              postInfo['userInfo']['focused'] =
                                  !postInfo['userInfo']['focused'];
                            });
                            Fluttertoast.showToast(
                              msg: postInfo['userInfo']['focused']
                                  ? '关注成功'
                                  : '已取消关注',
                              gravity: ToastGravity.CENTER,
                              // textColor: Colors.grey,
                            );
                            var response = await HttpUtil().get(Api.unfocus,
                                parameters: {'postId': postInfo['postId']});
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/accoutlogin',
                              arguments: {"from": 'from'},
                            );
                          }
                        },
                      ),
                    )
                  : Container(
                      child: MaterialButton(
                        color: Colors.pink,
                        textColor: Colors.white,
                        child: new Text(
                          '关注',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                        minWidth: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setWidth(44),
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.pink),
                        ),
                        onPressed: () async {
                          if (Provider.of<UserStateProvide>(context,
                                  listen: false)
                              .ISLOGIN) {
                            // FocusScope.of(context).requestFocus(_commentFocus);
                            setState(() {
                              postInfo['userInfo']['focused'] =
                                  !postInfo['userInfo']['focused'];
                            });
                            Fluttertoast.showToast(
                              msg: postInfo['userInfo']['focused']
                                  ? '关注成功'
                                  : '已取消关注',
                              gravity: ToastGravity.CENTER,
                              // textColor: Colors.grey,
                            );
                            var response = await HttpUtil().get(Api.focus,
                                parameters: {'postId': postInfo['postId']});
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/accoutlogin',
                              arguments: {"from": 'from'},
                            );
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
        child: Text(''),
      );
    }
  }

  Widget _tx(src) {
    return ClipOval(
      child: Image.network(
        src,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _doImage(data) {
    var hight = (data['width'] == null || data['height'] == null)
        ? 710
        : (double.parse(data['height'].toString()) / data['width']) * 710;
    return Container(
      width: ScreenUtil().setWidth(710),
      height: ScreenUtil().setWidth(hight),
      padding: EdgeInsets.only(top: 0, bottom: 0),
      margin: EdgeInsets.only(bottom: 8),
      color: Color.fromRGBO(245, 245, 245, 1),
      alignment: Alignment.centerLeft,
      // 设置盒子最大或最小高度宽度
      constraints: BoxConstraints(
        maxWidth: ScreenUtil().setWidth(710),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            FadeRoute(
              page: JhPhotoAllScreenShow(
                imgDataArr: [
                  KSet.imgOrigin + data['imageName']
                  // +'?x-oss-process=image/resize,h_1024',
                  // 'https://i.chao.fun/biz/097049900ba1c8e6cc03e27138e82758.jpg?x-oss-process=image/resize,h_512'
                ],
                imgHeight: data['height'],
                imgWidth: data['width'],
                index: 0,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            KSet.imgOrigin +
                data['imageName'],
            width: ScreenUtil().setWidth(690),
            // fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

  List<Widget> _listViewByUser2(context, data) {
    List asd = doImgList(data);
    List<Widget> b = [];
    asd.forEach((element) {});
    for (var key = 0; key < asd.length; key++) {
      var c = Container(
        width: ScreenUtil().setWidth(340),
        height: ScreenUtil().setWidth((data['height'] / data['width']) * 340),
        color: Colors.white,
        margin: EdgeInsets.only(top: 0, bottom: 2),
        child: InkWell(
          onTap: () {
            print('点击图片');
            // JhPhotoAllScreenShow
            Navigator.of(context).push(
              FadeRoute(
                page: JhPhotoAllScreenShow(
                  imgDataArr: doImgList(data),
                  index: key,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: CachedNetworkImage(
              imageUrl: asd[key] + '?x-oss-process=image/resize,h_614',
              width: ScreenUtil().setWidth(340),
              fit: data['height'] < data['width']
                  ? BoxFit.fitWidth
                  : BoxFit.fitHeight,
              height:
                  ScreenUtil().setWidth((data['height'] / data['width']) * 340),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      );
      b.add(c);
    }
    return b;
  }

  Widget getTwo(context, data) {
    return Container(
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 2.5,
        children: _listViewByUser2(context, data),
      ),
    );
  }

  List<Widget> _listViewByUser(context, data) {
    // var hight = (data['width'] == null || data['height'] == null)
    //     ? 270
    //     : min((double.parse(data['height'].toString()) / data['width']) * 225,
    //         270);
    var hight = 225;
    List asd = doImgList(data);
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
            print(doImgList(data));
            // JhPhotoAllScreenShow
            Navigator.of(context).push(
              FadeRoute(
                page: JhPhotoAllScreenShow(
                  imgDataArr: doImgList(data), //[imgurl],
                  index: key,
                  heroTag:
                      'https://i.chao.fun/biz/7101be096e69b69ab4e296a9f92bea76.jpg',
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: CachedNetworkImage(
              imageUrl: asd[key] + '?x-oss-process=image/resize,h_408',
              width: ScreenUtil().setWidth(225),
              // fit: data['height'] < data['width']
              //     ? BoxFit.fitWidth
              //     : BoxFit.fitHeight,
              fit: BoxFit.cover,
              height: ScreenUtil().setWidth(hight),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      );
      b.add(c);
    }
    return b;
  }

  doImgList(lis) {
    var arr = [];
    lis['images'].forEach((i) {
      arr.add(KSet.imgOrigin + i);
    });
    print('asd');
    print(lis);
    return arr;
  }

  Widget getThree(context, data) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 2.5,
        children: _listViewByUser(context, data),
      ),
    );
  }
}
