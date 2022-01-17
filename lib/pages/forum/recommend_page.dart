import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecommendPage extends StatefulWidget {
  _RecommendPageState createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  bool canload = true;
  Map forumData = {
    "imageName": "assets/images/_icon/tuijian.png",
    "name": "推荐",
    "desc": "炒饭为您个人推荐的优质内容，希望您能喜欢"
  };
  List<Map> pageData = [];

  @override
  bool get wantKeepAlive => true;

  var params = {
    "pageSize": '20',
    "marker": '',
    "order": 'new',
    'forumId': 'recommend',
    'key': ''
  };
  EasyRefreshController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getForumData();
    getDatas('');
  }

  @override
  void dispose() {
    super.dispose();
    if (Platform.isAndroid) {
      //Platform
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ); //Colors.black38
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarBrightness: Brightness.light,
      ); //Colors.black38
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
    // setState(() {
    //   _controller.finishRefresh();
    // });
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
    if (mounted) {
      if (canload) {
        setState(() {
          canload = false;
        });
        getDatas('');
      }
    }
    // _controller.finishLoad();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // statusBarIconBrightness: Brightness.dark,
    ); //Colors.black38
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    if (Provider.of<UserStateProvide>(context, listen: true).changeTag !=
        null) {
      var ps = Provider.of<UserStateProvide>(context, listen: false).changeTag;
      pageData.forEach((element) {
        if (ps['postId'] == element['postId']) {
          element['tags'] = [ps['tags']];
          print('ccccccccccccccc');
          print(element);
        }
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          //防止刷新重绘
          future: forumFuture({'forumId': '5'}),
          builder: (context, AsyncSnapshot asyncSnapshot) {
            return Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: 0),
              child: EasyRefresh.custom(
                enableControlFinishRefresh: false,
                enableControlFinishLoad: false,
                controller: _controller,
                scrollController: _scrollController,
                header: ClassicalHeader(
                  showInfo: false,
                  refreshReadyText: KSet.refreshReadyText,
                  refreshingText: KSet.refreshingText,
                  refreshText: KSet.refreshText,
                  refreshedText: KSet.refreshedText,
                  textColor: KSet.textRefreshColor,
                  refreshFailedText: '加载失败',
                ),
                footer: ClassicalFooter(
                  enableHapticFeedback: false,
                  showInfo: false,
                  loadingText: KSet.loadingText,
                  loadedText: KSet.loadedText,
                  textColor: KSet.textRefreshColor,
                  loadFailedText: '加载失败',
                ),
                onRefresh: _onRefresh,
                onLoad: _onLoading,
                slivers: <Widget>[
                  SliverAppBar(
                    // iconTheme: IconTheme(
                    //   data: IconThemeData(color: Colors.green, opacity: 100),
                    // ),
                    iconTheme: IconThemeData(color: Colors.white, opacity: 100),
                    pinned: true,
                    expandedHeight: 180.0,
                    brightness: Brightness.light,
                    actions: [
                      // CupertinoButton(
                      //   borderRadius: BorderRadius.circular(40),
                      //   child: Text('加入'),
                      //   color: Colors.blue,
                      //   pressedOpacity: .5,
                      // )
                      // Container(
                      //   height: 0,
                      //   width: 70,
                      //   padding: EdgeInsets.only(top: 6, bottom: 6),
                      //   child: _btnPush(context),
                      // ),
                    ],
                    flexibleSpace: GestureDetector(
                      onDoubleTap: () {
                        Future.delayed(Duration(milliseconds: 10)).then((e) {
                          _scrollController.position.moveTo(0);
                        });
                      },
                      child: FlexibleSpaceBar(
                        titlePadding: EdgeInsets.only(bottom: 10, left: 0),
                        title: Container(
                          height: 110,
                          color: Colors.transparent,
                          margin: EdgeInsets.only(
                            left: 30,
                            bottom: 0,
                            top: MediaQuery.of(context).padding.top + 6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: EdgeInsets.only(
                                  right: 8,
                                  left: 10,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/_icon/tuijian.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 40,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    textDirection: TextDirection.ltr,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          forumData['name'],
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(28),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   alignment: Alignment.centerLeft,
                                      //   child: Text(
                                      //     '帖子数量' +
                                      //         forumData['posts'].toString(),
                                      //     style: TextStyle(
                                      //       fontSize: ScreenUtil().setSp(20),
                                      //       color: Color.fromRGBO(
                                      //           255, 255, 255, 0.5),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Container(),
                              // ),
                            ],
                          ),
                          // color: Colors.white,
                        ),
                        background: Stack(
                          children: [
                            Container(
                              height: 180,
                              width: ScreenUtil().setWidth(750),
                              child: Image.asset(
                                // 'http://img.haote.com/upload/20180918/2018091815372344164.jpg',
                                'assets/images/img/bg@3x.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            // Positioned(
                            //   child: Container(
                            //     color: Color.fromRGBO(33, 29, 47, 0.5),
                            //     height: 260,
                            //   ),
                            // ),
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 30, sigmaY: 30), //可以看源码
                                child: Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: (Color.fromRGBO(33, 29, 47, 0.5))
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              child: Container(
                                height: 44,
                                width: ScreenUtil().setWidth(530),
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(
                                    right: 10, top: 30, left: 60, bottom: 5),
                                child: Text(
                                  forumData['desc'] == null
                                      ? ''
                                      : forumData['desc'],
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.7),
                                    fontSize: ScreenUtil().setSp(28),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // child: Row(
                              //   children: [
                              //     Container(
                              //       width: 50,
                              //       height: 50,
                              //       margin:
                              //           EdgeInsets.only(right: 10, left: 50),
                              //       child: Text(
                              //         '复仇者联盟',
                              //         style: TextStyle(color: Colors.white),
                              //       ),
                              //     ),
                              //     // Text('复仇者联盟'),
                              //   ],
                              // ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    backgroundColor: Color.fromRGBO(95, 60, 94, 1),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, int index) {
                        Container postPiece;
                        return ItemIndex(item: pageData[index], type: 'forum');

                        // if (index == 0) {
                        //   postPiece = Container(
                        //     child: Text(
                        //       '$index , aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                        //       style: TextStyle(color: Colors.grey),
                        //     ),
                        //   );
                        // } else {
                        //   postPiece = Container(
                        //     child: Text(
                        //       '$index, bbbbbbbbbbbbb',
                        //       style: TextStyle(color: Colors.black),
                        //     ),
                        //   );
                        // }
                        // return postPiece;
                      },
                      childCount: pageData.length,
                    ),
                  ),
                  // SliverFixedExtentList(
                  //   // itemExtent: 80.0,
                  //   delegate: SliverChildBuilderDelegate(
                  //     (BuildContext context, int index) {
                  //       return Card(
                  //         child: Container(
                  //           alignment: Alignment.center,
                  //           color: Colors.primaries[(index % 18)],
                  //           child: Text(''),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            );
            // return SafeArea(
            //   child: Stack(children: <Widget>[
            //     // Container(
            //     //   height: ScreenUtil().setHeight(110),
            //     // ),
            //     Container(
            //       padding: EdgeInsets.only(top: ScreenUtil().setHeight(110)),
            //       child: SmartRefresher(
            //         enablePullDown: true,
            //         enablePullUp: true,
            //         header: WaterDropHeader(
            //           complete: Text('刷新完成'),
            //         ),
            //         footer: CustomFooter(
            //           builder: (BuildContext context, LoadStatus mode) {
            //             Widget body;
            //             if (mode == LoadStatus.idle) {
            //               body = Text(
            //                 "加载完成",
            //                 style: TextStyle(color: Colors.grey),
            //               );
            //               // body = BallSpinFadeLoaderIndicator(
            //               //     ballColor: Colors.grey, radius: 10);
            //             } else if (mode == LoadStatus.loading) {
            //               // body = CupertinoActivityIndicator();
            //               body = BallSpinFadeLoaderIndicator(
            //                   ballColor: Colors.grey, radius: 10);
            //             } else if (mode == LoadStatus.failed) {
            //               body = Text("Load Failed!Click retry!");
            //             } else if (mode == LoadStatus.canLoading) {
            //               body = Text("release to load more");
            //             } else {
            //               body = Text("No more Data");
            //             }
            //             return Container(
            //               height: 40.0,
            //               child: Center(child: body),
            //             );
            //           },
            //         ),
            //         controller: _refreshController,
            //         onRefresh: _onRefresh,
            //         onLoading: _onLoading, //sortCell(),
            //         child: ListView.builder(
            //           primary: true,
            //           cacheExtent: 1000,
            //           itemBuilder: (c, i) =>
            //               ItemIndex(item: pageData[i], type: 'forum'),

            //           // ContentWidget(pageData: pageData),
            //           // itemExtent: 100.0,
            //           itemCount: pageData.length,
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       top: 0,
            //       left: 0,
            //       right: 0,
            //       child: _topForumInfo(context),
            //     ),
            //   ]),
            // );
          }),
    );
  }

  Future forumFuture(Map<String, dynamic> parameters) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.getForumInfo, parameters: parameters);
      if (response['success']) {
        // CategoryTitleEntity categoryTitleEntity =
        //     CategoryTitleEntity.fromJson(response["data"]);
        // print(response["data"]);
        // onSuccess(response["data"]);
      } else {
        // onFail(response['errorMessage']);
      }
    } catch (e) {
      // onFail(Strings.SERVER_EXCEPTION);
    }
  }

  getForumData() async {
    var response =
        await HttpUtil().get(Api.HomeListCombine, parameters: params);
    setState(() {
      forumData = response['data'];
    });
    Provider.of<UserStateProvide>(context, listen: false).setLooksList({
      "icon": KSet.imgOrigin +
          forumData['imageName'] +
          '?x-oss-process=image/resize,h_80',
      "label": forumData['name'],
      "value": forumData['id'],
    });
  }

  void getDatas(type) async {
    var data = await HttpUtil().get(Api.HomeListCombine, parameters: params);
    // response = response['data'];
    print(data);
    if (type == 'refresh') {
      pageData = [];
    }
    List<Map> res = (data['data']['posts'] as List).cast();

    // List<Map> arr = [];
    // if (res.length > 0) {
    //   res.forEach((v) {
    //     if (v['type'] == 'image' ||
    //         v['type'] == 'link' ||
    //         v['type'] == 'article' ||
    //         v['type'] == 'gif' ||
    //         v['type'] == 'video') {
    //       arr.addAll([v]);
    //     }
    //   });
    // }
    // print(arr.length);
    // if (arr.length > 80) {
    //   arr = arr.sublist(arr.length - 80);
    // }
    setState(() {
      setState(() {
        canload = true;
      });
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      if (data['data']['marker'] != null) {
        params['marker'] = data['data']['marker'];
      }

      if (data['data']['key'] != null) {
        params['key'] = data['data']['key'];
      }
    });
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      params['key'] = '';
      // if (btnToTop) {
      pageData = [];
      // btnToTop = false;
      // const timeout = const Duration(seconds: 1);
      // print('currentTime=' + DateTime.now().toString()); // 当前时间
      // Timer(timeout, () {
      //   //callback function
      //   print('afterTimer=' + DateTime.now().toString()); // 5s之后
      //   pageData = a;
      // });
      // }
      getDatas('refresh');
    });
  }

  _topForumInfo(context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            margin: EdgeInsets.only(right: 10, left: 10),
            child: ClipOval(
              child: Image.asset(
                forumData['imageName'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            // child: Image.network(
            //   KSet.imgOrigin,
            //   width: 70,
            //   height: 70,
            //   fit: BoxFit.cover,
            // ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    forumData['name'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    forumData['desc'] != null ? forumData['desc'] : '~~~~~',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: KColor.defaultGrayColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnPush(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10, right: 0),
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(44),
      child: MaterialButton(
        color: forumData['joined'] ? Colors.white : Colors.pink,
        textColor: forumData['joined'] ? Colors.grey : Colors.white,
        child: new Text(
          forumData['joined'] ? '已加入' : '加入',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        minWidth: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(44),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
              color: forumData['joined'] ? Colors.white : Colors.pink),
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30.0),
        //   side: BorderSide(color: Colors.pink),
        // ),
        onPressed: () async {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            // FocusScope.of(context).requestFocus(_commentFocus);
            Fluttertoast.showToast(
              msg: forumData['joined'] ? '已退出' : '已加入',
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
            if (forumData['joined']) {
              setState(() {
                forumData['joined'] = false;
              });
              var response = await HttpUtil().get(Api.leaveForum,
                  parameters: {'forumId': forumData['id']});
            } else {
              setState(() {
                forumData['joined'] = true;
              });
              var response = await HttpUtil()
                  .get(Api.joinForum, parameters: {'forumId': forumData['id']});
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
}
