import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/hometabs/all_tab_page.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/widget/items/flow_index_widget.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllPage extends StatefulWidget {
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  bool canload = true;
  Map forumData = {
    "imageName": "assets/images/_icon/quanzhan.png",
    "name": "全站",
    "desc": "聚集所有版块的最新，最热的帖子"
  };

  List<Map> pageData = [
    {'name': 'sort'}
  ];

  bool showZanData = false;

  List<Map> sortData = [
    {"name": '最新', "value": "new"},
    {"name": '最热', "value": "hot"},
    {"name": '新评', "value": "comment"},
    {"name": "最赞", "value": 'ups'},
  ];

  List<Map> sortZanData = [
    {"name": "当前最赞", "value": '1hour'},
    {"name": "日最赞", "value": '1day'},
    {"name": "周最赞", "value": '1week'},
    {"name": "月最赞", "value": '1month'},
    {"name": "年最赞", "value": '1year'},
    {"name": "总最赞", "value": 'all'},
  ];

  @override
  bool get wantKeepAlive => true;

  var params = {
    "pageSize": '20',
    "marker": '',
    "order": 'hot',
    "range": "1hour",
    'forumId': 'all',
    'key': '',
    'onlyNew': false,
    'media': false,
  };

  EasyRefreshController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getForumData();
    inits();
  }

  inits() async {
    var os =
        await Provider.of<UserStateProvide>(context, listen: false).getOrder();
    var modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;

    setState(() {
      params['order'] = os['order'];
      params['onlyNew'] = os['onlyNew'];

      if (modelType == 'model3') {
        params['media'] = true;
        params['pageSize'] = 30;
      } else {
        params['media'] = false;
        params['pageSize'] = 20;
      }
    });
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      if (canload) {
        setState(() {
          canload = false;
        });
        getDatas('');
      }
    }
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
                    iconTheme: IconThemeData(color: Colors.white, opacity: 100),
                    pinned: true,
                    expandedHeight: 180.0,
                    brightness: Brightness.light,
                    actions: [],
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
                                    'assets/images/_icon/quanzhan.png',
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
                                    ],
                                  ),
                                ),
                              ),
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
                        if (index == 0) {
                          return sortCell();
                        } else {
                          String modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
                          if (modelType == 'model3') {
                            // 瀑布流模式
                            if (index % 2 == 0) {
                              return Container(height: 2,);
                            } else {
                              return FlowIndexWidget(
                                item1: pageData[index],
                                item2: index == pageData.length - 1? null : pageData[index+1],
                                type: 'forum',
                                isComment: params['order'] == 'comment',
                              );
                            }
                          } else {
                            return ItemIndex(
                              item: pageData[index],
                              type: 'forum',
                              isComment: params['order'] == 'comment',
                            );
                          }
                        }
                      },
                      childCount: pageData.length,
                    ),
                  ),
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
            //           itemBuilder: (c, i) {
            //             if (i == 0) {
            //               return sortCell();
            //             } else {
            //               return ItemIndex(
            //                 item: pageData[i],
            //                 type: 'forum',
            //               );
            //             }
            //           },

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
    Provider.of<UserStateProvide>(context).setLooksList({
      "icon": KSet.imgOrigin +
          forumData['imageName'] +
          '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
      "label": forumData['name'],
      "value": forumData['id'],
    });
  }

  void getDatas(type) async {
    var data = await HttpUtil().get(Api.HomeListCombine, parameters: params);
    // response = response['data'];
    print(data);
    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'}
      ];
    }
    List<Map> res = (data['data']['posts'] as List).cast();
    // pageData.addAll(res);
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
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      canload = true;
      if (data['data']['marker'] != null) {
        params['marker'] = data['data']['marker'];
      }

      if (data['data']['key'] != null) {
        params['key'] = data['data']['key'];
      }
    });
  }

  void refreshData() async {
    var os =
        await Provider.of<UserStateProvide>(context, listen: false).getOrder();
    var modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;

    setState(() {
      params['marker'] = '';
      params['key'] = '';
      // params['order'] = os['order'];
      params['onlyNew'] = os['onlyNew'];
      // if (btnToTop) {
      pageData = [
        {'name': 'sort'}
      ];

      if (modelType == 'model3') {
        params['media'] = true;
      } else {
        params['media'] = false;
      }
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
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: <Widget>[
          Container(
            height: 0,
            margin: EdgeInsets.only(top: 0),
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

  Widget sortCell() {
    return Container(
      color: Color.fromRGBO(245, 245, 245, 1),
      // alignment: Alignment.centerRight,
      // color: Colors.white,
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 12,
                // left: 10,
                bottom: 12,
              ),
              // color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: sortData.map((item) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(40),
                              right: ScreenUtil().setWidth(10)),
                          child: InkWell(
                            onTap: () {
                              if (item['value'] == 'ups') {
                                setState(() {
                                  showZanData = !showZanData;
                                  params['order'] = item['value'];
                                });
                              } else {
                                setState(() {
                                  params['order'] = item['value'];
                                });
                                refreshData();
                                Provider.of<UserStateProvide>(context,
                                        listen: false)
                                    .setOrder(item['value']);
                              }
                            },
                            child: item['value'] != 'ups'
                                ? Text(
                                    item['name'],
                                    style: TextStyle(
                                      color: Color.fromRGBO(
                                          33,
                                          29,
                                          47,
                                          params['order'] == item['value']
                                              ? 1
                                              : 0.5),
                                      fontSize: ScreenUtil().setSp(28),
                                      fontWeight:
                                          params['order'] == item['value']
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              33,
                                              29,
                                              47,
                                              params['order'] == item['value']
                                                  ? 1
                                                  : 0.5),
                                          fontSize: ScreenUtil().setSp(28),
                                          fontWeight:
                                              params['order'] == item['value']
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Image.asset(
                                        'assets/images/_icon/arrow_down.png',
                                        width: 8,
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(30)),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (Provider.of<UserStateProvide>(context,
                                    listen: false)
                                .ISLOGIN) {
                              if (params['onlyNew']) {
                                Provider.of<UserStateProvide>(context,
                                        listen: false)
                                    .setOnlyNew(false);
                              } else {
                                Provider.of<UserStateProvide>(context,
                                        listen: false)
                                    .setOnlyNew(true);
                              }
                              refreshData();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/accoutlogin',
                              );
                            }
                          },
                          child: Container(
                            child: Text(
                              '没看过',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(26),
                                color: params['onlyNew']
                                    ? Colors.white
                                    : Color.fromRGBO(122, 120, 131, 1),
                              ),
                            ),
                            width: ScreenUtil().setWidth(120),
                            height: ScreenUtil().setWidth(54),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: params['onlyNew']
                                  ? Color.fromRGBO(22, 103, 159, 1)
                                  : Colors.transparent,
                              border: Border.all(
                                width: 1,
                                color: KColor.defaultBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            String modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
                            if ( modelType == 'model1')  {
                              modelType = 'model2';
                            } else if (modelType == 'model2') {
                              modelType = 'model3';
                            } else {
                              modelType = 'model1';
                            }
                            Provider.of<UserStateProvide>(context, listen: false).setModelType(modelType);
                            refreshData();
                          },
                          child: getModel(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            showZanData
                ? Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(40),
                      top: ScreenUtil().setWidth(20),
                      bottom: ScreenUtil().setWidth(20),
                    ),
                    child: Column(
                      children: sortZanData.map((item) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              params['range'] = item['value'];
                              sortData[3]['name'] = item['name'];
                              showZanData = false;
                            });
                            refreshData();
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                params['range'] == item['value']
                                    ? Image.asset(
                                        'assets/images/_icon/right.png',
                                        width: 16,
                                      )
                                    : Text(''),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    color: params['range'] == item['value']
                                        ? Color.fromRGBO(122, 120, 131, 1)
                                        : Color.fromRGBO(33, 29, 47, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : Container(height: 0),
            showZanData
                ? Container(
                    height: 5,
                    color: Color.fromRGBO(245, 245, 245, 1),
                  )
                : Container(height: 0),
          ],
        ),
      ),
    );
  }
}
