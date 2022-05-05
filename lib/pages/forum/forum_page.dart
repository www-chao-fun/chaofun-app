import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/main.dart';
import 'package:flutter_chaofan/pages/hometabs/all_tab_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/widget/im/ui.dart';
import 'package:flutter_chaofan/widget/items/flow_index_widget.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/widget/hometop/topsearch_widget.dart';


import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../chat_page.dart';
import '../chat_home_page.dart';
import 'mod_apply_page.dart';

class ForumPage extends StatefulWidget {
  final Map arguments;
  ForumPage({Key key, this.arguments}) : super(key: key);
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with RouteAware {
  String forumId;
  Map forumData;
  bool canload = true;
  List<Map> pageData = [
    {'name': 'sort'},
  ];
  bool showZanData = false;
  ScrollController _scrollController = ScrollController();

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
    "pageSize": '16',
    "marker": '',
    "order": 'hot',
    "range": "1hour",
    "tagId": "",
    'onlyNew': false,
  };
  var tabTitle = [
    '页面1',
    '页面2',
    '页面3',
  ];
  List tagList = [];
  List tableList = [];
  bool showTag = false;
  bool showTopPost = false;
  bool showNav = true;
  String navStr = 'post';
  List columData = [];
  List rowData = [];
  List mods = [];
  List rules = [];
  List badges = [];
  List pins = [];
  var tableItem;
  var tableData;
  bool hasPrediction = false;
  bool hasDonate = false;
  var url =
      'http://www.pptbz.com/pptpic/UploadFiles_6909/201203/2012031220134655.jpg';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      forumId = widget.arguments['forumId'];
    });
    initTag();
    initTopPost();
    getForumData();
  }

  @override
  void dispose() {
    super.dispose();
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
  }

  @override
  void didChangeDependencies() {
    debugPrint("------> didChangeDependencies");
    routeObserver.subscribe(this, ModalRoute.of(context)); //订阅routeObserver

    super.didChangeDependencies();
  }

  @override
  void didPush() {
    if (Platform.isAndroid) {
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
    debugPrint("------> didPush");
    super.didPush();
  }

  @override
  void didPop() {
    debugPrint("------> didPop");
    if (Platform.isAndroid) {
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
    super.didPop();
  }

  @override
  void didPopNext() {
    // debugPrint("------> didPopNext");
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
    super.didPopNext();
  }

  @override
  void didPushNext() {
    debugPrint("------> didPushNext");
    super.didPushNext();
  }

  initTopPost() async {
    var res = await HttpUtil()
        .get(Api.listPins, parameters: {'forumId': forumId.toString()});
    print(res);
    if (res['data'] != null && res['data'].length > 0) {
      setState(() {
        showTopPost = true;
        pins = res['data'];
      });
    } else {
      showTopPost = false;
    }

  }
  initTag() async {
    var res = await HttpUtil()
        .get(Api.listTag, parameters: {'forumId': forumId.toString()});
    print(res);
    if (res['data'].length > 0) {
      setState(() {
        tagList = [
          {'name': '全部', 'id': ''}
        ];
        tagList.addAll(res['data']);
        // showZanData = false;
        showTag = true;
      });
    }
  }

  EasyRefreshController _controller;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
    if (mounted) {
      if (canload && navStr == 'post') {
        setState(() {
          canload = false;
        });
        getDatas('');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
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
      //TODO: 夜间模式支持
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          FutureBuilder(
            //防止刷新重绘
            future: forumFuture({'forumId': forumId}),
            builder: (context, AsyncSnapshot asyncSnapshot) {
              return forumData != null
                  ? Container(
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
                            iconTheme: IconThemeData(
                                color: Colors.white, opacity: 100),
                            pinned: true,
                            expandedHeight: 180.0,
                            brightness: Brightness.light,
                            actions: [
                              Container(
                                height: 0,
                                width: 70,
                                padding: EdgeInsets.only(top: 6, bottom: 6),
                                child: _btnPush(context, null, null, null, null),
                              ),
                              forumData['admin']
                                  ? Container(
                                      height: 0,
                                      width: 70,
                                      padding: EdgeInsets.only(top: 6, bottom: 6),
                                      child: _btnPush(context, '管理', Color.fromRGBO(255, 147, 0, 1), Colors.white, null),
                                    )
                                  : Container(
                                      width: 0,
                                    ),
                              forumData['hasChatChannel']
                                  ? Container(
                                      height: 0,
                                      width: 70,
                                      padding: EdgeInsets.only(top: 6, bottom: 6),
                                      child: _btnPush(context, '版聊', Color.fromRGBO(255, 147, 0, 1),
                                          Colors.white,
                                          () async {
                                              var response =  await HttpUtil.instance.get(Api.joinChatChannel, parameters: {"channelId": forumData['chatChannelId']});
                                              print('join success');
                                                    if (response['success']) {
                                                      response =  await HttpUtil.instance.get(Api.getChatChannelInfo, parameters: {"channelId": forumData['chatChannelId']});
                                                      routePush(context, new ChatPage(
                                                          id:  response['data']['id'],
                                                          title: response['data']['name'],
                                                          type: 2));
                                                    }
                                              }),
                                    )
                                  : Container(
                                      width: 0,
                                    ),
                            ],
                            flexibleSpace: GestureDetector(
                                onDoubleTap: () {
                                  if (_scrollController.hasClients) {
                                    Future.delayed(Duration(milliseconds: 10))
                                        .then((e) {
                                      _scrollController.position.moveTo(0);
                                    });
                                  }
                                },
                                child: FlexibleSpaceBar(
                                  titlePadding:
                                      EdgeInsets.only(bottom: 10, left: 0),
                                  title: Container(
                                    height: 110,
                                    color: Colors.transparent,
                                    margin: EdgeInsets.only(
                                      left: 30,
                                      bottom: 0,
                                      top: MediaQuery.of(context).padding.top +
                                          6,
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              KSet.imgOrigin +
                                                  forumData['imageName'] +
                                                  '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    forumData['name'],
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(28),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Row( children:
                                                    [
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/followers_user',
                                                            arguments: {'title': '已加入用户', 'forumId': forumId},
                                                          );
                                                        },
                                                        // alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          '用户' +
                                                              forumData['followers']
                                                                  .toString(),
                                                          style: TextStyle(
                                                            fontSize: ScreenUtil()
                                                                .setSp(20),
                                                            color: Color.fromRGBO(
                                                                255, 255, 255, 0.5),
                                                          ),
                                                        ),
                                                      ),
                                                      Space(width: 5),
                                                      Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '帖子' +
                                                        forumData['posts']
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(20),
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 0.5),
                                                    ),
                                                  ),
                                                ),]),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   child: Text('123123'),
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
                                        child: Image.network(
                                          // 'http://img.haote.com/upload/20180918/2018091815372344164.jpg',
                                          KSet.imgOrigin +
                                              forumData['imageName'] +
                                              '?x-oss-process=image/resize,h_750/format,webp/quality,q_75',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 30, sigmaY: 30), //可以看源码
                                          child: Container(
                                            height: 180,
                                            decoration: BoxDecoration(
                                              color: (Color.fromRGBO(
                                                      33, 29, 47, 0.5))
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(0),
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
                                              right: 10,
                                              top: 30,
                                              left: 60,
                                              bottom: 5),
                                          child: Text(
                                            forumData['desc'] == null
                                                ? ''
                                                : forumData['desc'],
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.7),
                                              fontSize: ScreenUtil().setSp(28),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            backgroundColor: Color.fromRGBO(95, 60, 94, 1),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, int index) {
                                Container postPiece;
                                if (index == 0) {
                                  return (showNav
                                      ? Container(
                                          height: ScreenUtil().setWidth(100),
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().setWidth(10)),
                                          // color: Colors.red,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 0.5,
                                                color: Color.fromRGBO(
                                                    221, 221, 221, 0.5),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    navStr = 'post';
                                                  });
                                                },
                                                child: Container(
                                                  width: ScreenUtil().setWidth(150),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '帖子',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: navStr == 'post'
                                                            ? KColor
                                                                .primaryColor
                                                            : Theme.of(context).hintColor),
                                                  ),
                                                ),
                                              ),
                                              tableList.length > 0
                                                  ? InkWell(
                                                      onTap: () async {
                                                        var response = await HttpUtil().get(Api.tableget, parameters: {'tableId': tableItem['id'],});
                                                        var data = response['data'];
                                                        var content = response['data']['data'];
                                                        var lines = content.split('\n');
                                                        var header = lines[0].split(',');
                                                        var output = [];
                                                        lines.skip(1).toList().forEach((line) {
                                                          var fields = line.split(','); // 3️
                                                          output.add(fields); // 4️
                                                        });
                                                        print('uuuuuuuuuuuuuuuuuuuu');
                                                        print(lines);
                                                        print(header);
                                                        print(output.toString());
                                                        setState(() {
                                                          columData = header;
                                                          rowData = output;
                                                          tableData = response['data'];
                                                          navStr = 'table';
                                                        });
                                                      },
                                                      child: Container(
                                                        width: ScreenUtil()
                                                            .setWidth(150),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          (tableList[0]['name'] == null || tableList[0]['name'] == '' ?  '表格' : tableList[0]['name']),
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: navStr == 'table' ? KColor.primaryColor
                                                                  : Theme.of(context).hintColor),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(''),
                                              hasPrediction
                                                  ? InkWell(
                                                      onTap: () async {
                                                        var response =
                                                            await HttpUtil().get(
                                                                Api.predictionsGet,
                                                                parameters: {
                                                              'forumId':
                                                                  forumData[
                                                                      'id'],
                                                            });
                                                        print(
                                                            'ttttttttttttttttt');
                                                        print(response);
                                                        if (response['data'] !=
                                                            null) {
                                                          Navigator.pushNamed(context, '/predictionpage',
                                                              arguments: {
                                                                'forumId': forumData['id'],
                                                                'forumName': forumData['name'],
                                                              });
                                                        } else {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg: '该版块暂无竞猜活动',
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            // textColor: Colors.grey,
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        width: ScreenUtil()
                                                            .setWidth(150),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/_icon/guess.png',
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          40),
                                                            ),
                                                            Text(
                                                              '竞猜',
                                                            )
                                                          ],
                                                        ),
                                                        // child: Text('竞猜'),
                                                      ),
                                                    )
                                                  : Text(''),

                                              InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      navStr = 'more';
                                                    });
                                                  },
                                                  child: Container(
                                                    width: ScreenUtil()
                                                        .setWidth(150),
                                                    alignment:
                                                    Alignment.center,
                                                    child: Text(
                                                      '更多',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: navStr == 'more' ? KColor.primaryColor
                                                              : Theme.of(context).hintColor),
                                                    ),
                                                  )
                                              ),
                                              Visibility(
                                                  visible: hasDonate,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ChaoFunWebView(
                                                            url:
                                                            'https://chao.fun/webview/donate?forumId=' + this.forumId.toString(),
                                                            title: "版块众筹",
                                                            showHeader: true,
                                                            cookie: true,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                        width: ScreenUtil()
                                                            .setWidth(150),
                                                        alignment:
                                                        Alignment.center,
                                                        child: Text(
                                                          '众筹',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Theme.of(context).hintColor),
                                                        )
                                                    ),
                                                  )
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 0,
                                        ));
                                } else if (index == 1) {
                                  if (navStr == 'post') {
                                    return Container(
                                      child: Column(
                                        children: [
                                          showTopPost ? _buildPins() : Container(height:0) ,
                                          showTag
                                              ? Container(
                                                  // color: Colors.white,
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(0),
                                                    top: ScreenUtil().setWidth(10),
                                                    bottom: ScreenUtil().setWidth(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset('assets/images/_icon/tag.png', width: 16,),
                                                              SizedBox(
                                                                width: 2,
                                                              ),
                                                              Text('标签',
                                                                style: TextStyle(
                                                                  fontSize: ScreenUtil().setSp(30),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ]),
                                                        width: ScreenUtil()
                                                            .setWidth(120),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          // width: 100,
                                                          height: ScreenUtil().setWidth(80),
                                                          padding:
                                                              EdgeInsets.only(top: 3, bottom: 5),
                                                          child:
                                                              ListView.builder(scrollDirection:
                                                                Axis.horizontal,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(30.0),
                                                                  color: params['tagId'] == tagList[index]['id'].toString()
                                                                      ? Color.fromRGBO(255, 147, 0, 0.5)
                                                                      : Colors.white,
                                                                ),
                                                                height:
                                                                    ScreenUtil().setWidth(40),
                                                                alignment: Alignment.center,
                                                                padding: EdgeInsets.only(
                                                                        left: 10,
                                                                        right: 10),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      params['tagId'] = tagList[index]['id'].toString();
                                                                    });
                                                                    refreshData();
                                                                  },
                                                                  child: Text(
                                                                    '# ' + tagList[index]['name'],
                                                                    style: TextStyle(
                                                                      fontSize: ScreenUtil().setSp(28),
                                                                      color: Color.fromRGBO(33, 29, 47, 1),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            itemCount:
                                                                tagList.length,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    // children: tagList.map((item) {
                                                    //   return
                                                    // }).toList(),
                                                  ),
                                                )
                                              : Container(),
                                          sortCell(),
                                        ],
                                      ),
                                    );
                                  } else if (navStr == 'table') {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(750),
                                          height: ScreenUtil().setWidth(80),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                tableData['name'],
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(32),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          tableData['desc'],
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(26),
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              ScreenUtil().setWidth(20),
                                              ScreenUtil().setWidth(20),
                                              ScreenUtil().setWidth(20),
                                              ScreenUtil().setWidth(20)),
                                          width: ScreenUtil().setWidth(700),
                                          child: DataTable(
                                              columns: columData
                                                  .map((data) => DataColumn(
                                                          label: Text(
                                                        data,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(28),
                                                        ),
                                                      )))
                                                  .toList(),
                                              rows: rowData
                                                  .map(
                                                    (data) => DataRow(
                                                      cells: _getCells(
                                                          columData,
                                                          data,
                                                          rowData),
                                                    ),
                                                  )
                                                  .toList()),
                                        )
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        Text("发帖规范", style: TextStyle(
                                            fontSize: ScreenUtil().setSp(32))
                                        ),
                                        ruleList(),
                                        new Container(height: 10),
                                        Text("版主", style: TextStyle(
                                            fontSize: ScreenUtil().setSp(32))
                                        ),
                                        userList(context),
                                        Text("徽章", style: TextStyle(
                                            fontSize: ScreenUtil().setSp(32))
                                        ),
                                        badgeList(context),
                                      ],
                                    );
                                  }
                                } else {
                                  String modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
                                  if (modelType == 'model3') {
                                    // 瀑布流模式
                                    if (index % 2 == 1) {
                                      return Container(height: 2,);
                                    } else {
                                      return FlowIndexWidget(
                                        item1: pageData[index-1],
                                        item2: index - 1  == pageData.length - 1 ? null : pageData[index],
                                        isForum: true,
                                        isTag: !(params['tagId'] == null || params['tagId'] == ''),
                                        type: 'forum',
                                        isComment: params['order'] == 'comment',
                                      );
                                    }
                                  } else {
                                    return ItemIndex(
                                      key: Key(pageData[index-1]['postId'].toString()),
                                      item: pageData[index-1],
                                      type: 'forum_page',
                                      isComment: params['order'] == 'comment',
                                    );
                                  }
                                }
                              },
                              childCount:
                                  navStr == 'post' ? pageData.length + 1 : 2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 0,
                    );
            },
          ),
          Positioned(
            right: 15,
            bottom: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/message',
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child:
                        Stack(
                          children: [
                            Visibility(
                              visible:  Provider.of<UserStateProvide>(context, listen: false).hasNewMessage,
                                child:
                            Positioned(
                              right: 0,
                                top: 2,
                                child:
                              Container(
                                height: 8, width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red
                                ),
                              ))
                            ),
                            Icon(Icons.mail_outline_rounded, color: Colors.white,)
                          ]
                        ),

                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/search',
                        arguments: {'forumData': forumData});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                    ),
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    print('点击发布');
                    if (Provider.of<UserStateProvide>(context, listen: false)
                        .ISLOGIN) {
                      var str = forumData['id'].toString() +
                          '|' +
                          forumData['name'] +
                          '|' +
                          forumData['imageName'];
                      Navigator.pushNamed(context, '/submitpage',
                          arguments: {'str': str});
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/accoutlogin',
                      );
                    }
                    // _pickImage(context);
                  },
                  child:
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Image.asset(
                      'assets/images/_icon/push.png',
                      width: 24,
                      height: 24,
                    ),
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget badgeList(BuildContext context) {
    if (badges.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: badges.map((e) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => WebViewExample(
                      //     url: 'https://chao.fun/p/417588', title: '炒饭用户及隐私政策'),
                      builder: (context) => ChaoFunWebView(
                        // url: 'https://chao.fun/p/417588',
                        url:
                        'https://chao.fun/webview/badge?badgeId=' +
                            (e['id'] == null ? '' : e['id'].toString()) , //'https://chao.fun/webview/agreement',
                        title: e['name'],
                        showAction: false,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  // margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        width: 0.2,
                        color: Color.fromRGBO(240, 240, 240, 1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(
                          right: 8,
                          left: 8,
                        ),
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: KSet.imgOrigin +
                                e['icon'] + '?x-oss-process=image/resize,h_60/format,webp/quality,q_75',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                Center(
                                  child: Image.asset(
                                      "assets/images/img/place.png"),
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(e['name'] + "(人数："
                                    + (e['userNumber'] != null ? e['userNumber'].toString() : '') +  ", FBi："
                                    + (e['integral'] != null ? e['integral'].toString() : '') +  ")",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            );
          }).toList(),
        ),
      );
    } else {
      return Text('本版块暂无徽章～');
    }
  }

  Widget userList(BuildContext context) {
    if (mods.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: mods.map((e) {
            return Container(
              height: 40,
              alignment: Alignment.centerLeft,
              // margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/userMemberPage',
                    arguments: {"userId": e['userId'].toString()},
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(
                        right: 8,
                        left: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: KSet.imgOrigin +
                              e['icon'] + '?x-oss-process=image/resize,h_60/format,webp/quality,q_75',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(
                                child: Image.asset(
                                    "assets/images/img/place.png"),
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(e['userName'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return MaterialButton(
          // color: Color.fromRGBO(255, 147, 0, 1),
          // textColor: Colors.white,
          child: new Text(
            '暂无，点击申请版主',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(40),
            ),
          ),
          minWidth: ScreenUtil().setWidth(200),
          height: ScreenUtil().setWidth(40),
          padding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(
              // color: Color.fromRGBO(255, 147, 0, 1),
            ),
          ),
          onPressed: () async {
            Navigator.push<String>(context,
                new MaterialPageRoute(builder: (BuildContext context) {
                  return new ModApplyPage(forumId: forumId,);
                })).then((String result) {
            });
          },);
    }
  }

  showAlertDialog(BuildContext context) {

    // Widget continueButton = FlatButton(
    //   child: Text("确定"),
    //   onPressed: () {},
    // );
    //
    //
    // //显示对话框
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return alert;
    //   },
    // );
  }

  _buildPins() {
    List<Widget> pinWidgets = [];
    for (int i = 0; i < pins.length; i++) {
      pinWidgets.add(
          InkWell(onTap: () {
            Navigator.pushNamed(
              context,
              '/postdetail',
              arguments: {
                "postId": pins[i]['postId'].toString()
              },
            );
          }, child:
          Container(
            // color: Colors.,
              padding: EdgeInsets.only(left: 4, bottom: 4),
              // decoration: BoxDecoration(
              //   // color: Color.fromRGBO(211, 211, 211, 1),
              //   border:  Border(
              //       bottom: new BorderSide(color: Theme.of(context).hintColor, width:0.2)),
              //   // color: Colors.blue,
              // ),
              child: Row( children:[
                // Container(color: Colors.orangeAccent, child: Icon(Icons.push_pin_outlined, color: Colors.white, size: ScreenUtil().setWidth(30),)),
                Container(padding: EdgeInsets.only(left: 2, right: 2), color: Colors.orangeAccent, child: Text('置顶', style: TextStyle(color:Colors.white, fontSize:  ScreenUtil().setWidth(24)))),
                Container(width: 2,),
                Text(pins[i]['title'], maxLines: 1,                  softWrap: true,
                  textAlign: TextAlign.left,

                  style: TextStyle(color:Theme.of(context).textTheme.titleLarge.color, overflow: TextOverflow.ellipsis,fontSize:  ScreenUtil().setWidth(30)),)
              ]
              )
          )
          )
      );
    }
    return Column(children: pinWidgets,);
  }
  ruleList() {
    if (rules.length > 0) {
      for (int i = 0; i < rules.length; i++) {
        rules[i]['index'] = (i +1).toString() ;
      }
      return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: Column(
              children: rules.map((e) {
                return Column( children:[
                  // Container(color: Colors.black, height: 1),
                  Container( child:
                  Text(e['rule'] != null ? e['index'] + '. ' + e['rule'] : '',
                  style: TextStyle(fontSize: 16),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3),
                )]);
              }).toList())
    );
    } else {
      return Text('本版块暂无发帖规范~');
    }
  }

  List<DataCell> _getCells(List<String> keyList, data, contextList) {
    List<DataCell> cells = [];

    // cells.add(DataCell(
    //     Text(
    //         '${Provide.value<TableProvide>(context).openState[data]['symbol']}'),
    //     onTap: () {
    //   Provide.value<TableProvide>(context).openNum = data;
    //   Provide.value<TableProvide>(context).changeOpenState();
    // }));
    for (var i = 0; i < keyList.length; i++) {
      cells.add(DataCell(
        Text(
          '${data[i]}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ));
    }
    // keyList.forEach((key) {
    //   cells.add(DataCell(
    //     Text('${contextList[data][key]}'),
    //   ));
    // });

    return cells;
  }

  _pickImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setHeight(384),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: KSet.pubList.map((item) {
                  return _pushItem(context, item);
                }).toList(),
              ),
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(700),
                    height: ScreenUtil().setWidth(70),
                    // color: Colors.blue,
                    child: Image.asset(
                      'assets/images/_icon/close.png',
                      width: ScreenUtil().setWidth(80),
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

  Widget _pushItem(context, item) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            var str = forumData['id'].toString() +
                '|' +
                forumData['name'] +
                '|' +
                forumData['imageName'];
            Navigator.pushNamed(context, '/submitpage',
                arguments: {'str': str});
            // if (item['type'] == 'link') {
            //   Navigator.of(context).pop();
            //   Navigator.pushNamed(context, '/linkpublish',
            //       arguments: {'str': str});
            // } else if (item['type'] == 'image') {
            //   Navigator.of(context).pop();
            //   Navigator.pushNamed(context, '/imagepublish',
            //       arguments: {'str': str});
            // } else if (item['type'] == 'textarea') {
            //   Navigator.of(context).pop();
            //   Navigator.pushNamed(context, '/articlepublish',
            //       arguments: {'str': str});
            // } else if (item['type'] == 'vote') {
            //   Navigator.of(context).pop();
            //   Navigator.pushNamed(context, '/votepublish',
            //       arguments: {'str': str});
            // }
          } else {
            Navigator.pushNamed(
              context,
              '/accoutlogin',
            );
          }
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                  // color: Colors.blue,
                ),
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
                child: Image.asset(
                  item['icon'],
                  width: ScreenUtil().setWidth(92),
                  height: ScreenUtil().setWidth(92),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                item['label'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future forumFuture(Map<String, dynamic> parameters) async {
    try {
      var response =
          await HttpUtil.instance.get(Api.getForumInfo, parameters: parameters);
      if (response['success']) {
      } else {}
    } catch (e) {}
  }

  getForumData() async {
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
        params['pageSize'] = 16;
      }
    });
    getDatas('');
    var response = await HttpUtil()
        .get(Api.getForumInfo, parameters: {'forumId': forumId});
    setState(() {
      forumData = response['data'];
    });
    Provider.of<UserStateProvide>(context, listen: false).setLooksList({
      "icon": KSet.imgOrigin +
          forumData['imageName'] +
          '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
      "label": forumData['name'],
      "value": forumData['id'],
    });
    var response1 = await HttpUtil().get(Api.predictionsGet, parameters: {
      'forumId': forumData['id'],
    });

    var donateIsOpenResponse = await HttpUtil().get(Api.donateIsOpen, parameters: {
      'forumId': forumData['id'],
    });
    var response2 = await HttpUtil().get(Api.tablelist, parameters: {
      'forumId': forumData['id'],
    });

    getMods();
    getRules();
    getBadges();

    if (response1['data'] != null || response2['data'].length > 0) {
      setState(() {
        showNav = true;
        tableList = response2['data'];
        if (response1['data'] != null) {
          hasPrediction = true;
        }
        if (response2['data'].length > 0) {
          tableItem = response2['data'][0];
        }
      });
    }

    if (donateIsOpenResponse != null) {
      setState(() {
        hasDonate = donateIsOpenResponse['data'];
      });
    }
  }

  getMods() async {
    var response3 = await HttpUtil().get(Api.modList, parameters: {
      'forumId': forumData['id'],
    });
    if (response3['data'] != null) {
      mods = response3['data'];
    }
  }

  getRules() async {
    var response3 = await HttpUtil().get(Api.ruleList, parameters: {
      'forumId': forumData['id'],
    });
    if (response3['data'] != null) {
      rules = response3['data'];
    }
  }

  getBadges() async {
    var response3 = await HttpUtil().get(Api.badgeList, parameters: {
      'forumId': forumData['id'],
    });
    if (response3['data'] != null) {
      badges = response3['data'];
    }
  }


  void getDatas(type) async {
    params['forumId'] = forumId;
    var data = await HttpUtil().get(Api.forumPostList, parameters: params);
    // response = response['data'];
    print('oooooooooooooooooooooo');
    print(data);
    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'},
      ];
    }
    List<Map> res = (data['data']['posts'] as List).cast();

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
    print('刷新key');
    print(params);
  }

  void refreshData() async {
    var os =
        await Provider.of<UserStateProvide>(context, listen: false).getOrder();
    var modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
    setState(() {
      params['marker'] = '';
      params['key'] = '';
      params['forumId'] = forumId;
      // params['order'] = os['order'];
      params['onlyNew'] = os['onlyNew'];

      if (modelType == 'model3') {
        params['media'] = true;
        params['pageSize'] = 30;
      } else {
        params['media'] = false;
        params['pageSize'] = 16;
      }

      // if (btnToTop) {
      pageData = [
        {'name': 'sort'}
      ]; // btnToTop = false;
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
              child: Image.network(
                KSet.imgOrigin +
                    forumData['imageName'] +
                    '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
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
          Container(
            // width: ScreenUtil().setWidth(130),
            child: _btnPush(context, null, null, null, null),
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
                            onTap: () async {
                              if (item['value'] == 'ups') {
                                setState(() {
                                  showZanData = !showZanData;
                                  params['order'] = item['value'];
                                });
                              } else {
                                setState(() {
                                  params['order'] = item['value'];
                                  showZanData = false;
                                });
                                refreshData();
                                Provider.of<UserStateProvide>(context,
                                        listen: false)
                                    .setOrder(item['value']);
                              }
                            },
                            child: (item['value'] != 'ups')
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
                                              (params['order'] == item['value'])
                                                  ? 1
                                                  : 0.5),
                                          fontSize: ScreenUtil().setSp(28),
                                          fontWeight:
                                              (params['order'] == item['value'])
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
                        // Consumer<UserStateProvide>(
                        //     builder: (context, user, child) {
                        //   // user.getOnlyNew();
                        //   if (user.onlyNew) {
                        //     return InkWell(
                        //       onTap: () {
                        //         user.setOnlyNew(false);
                        //         setState(() {
                        //           params['onlyNew'] = false;
                        //         });
                        //         refreshData();
                        //       },
                        //       child: Container(
                        //         child: Text(
                        //           '没看过',
                        //           style: TextStyle(
                        //             fontSize: ScreenUtil().setSp(26),
                        //             color: Colors.white,
                        //           ),
                        //         ),
                        //         width: ScreenUtil().setWidth(120),
                        //         height: ScreenUtil().setWidth(54),
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //           color: Color.fromRGBO(22, 103, 159, 1),
                        //           border: Border.all(
                        //             width: 1,
                        //             color: KColor.defaultBorderColor,
                        //           ),
                        //           borderRadius: BorderRadius.circular(20),
                        //         ),
                        //       ),
                        //     );
                        //   } else {
                        //     return InkWell(
                        //       onTap: () {
                        //         user.setOnlyNew(true);
                        //         setState(() {
                        //           params['onlyNew'] = true;
                        //         });
                        //         refreshData();
                        //       },
                        //       child: Container(
                        //         child: Text(
                        //           '没看过',
                        //           style: TextStyle(
                        //             fontSize: ScreenUtil().setSp(26),
                        //             color: Color.fromRGBO(122, 120, 131, 1),
                        //           ),
                        //         ),
                        //         width: ScreenUtil().setWidth(120),
                        //         height: ScreenUtil().setWidth(54),
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //           border: Border.all(
                        //             width: 1,
                        //             color: KColor.defaultBorderColor,
                        //           ),
                        //           borderRadius: BorderRadius.circular(20),
                        //         ),
                        //       ),
                        //     );
                        //   }
                        // }),
                        SizedBox(
                          width: ScreenUtil().setWidth(20),
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
                : Container(height: 0), //tagList

            (showZanData)
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

  Widget _btnPush(context, text, color, textColor, callBack) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10, right: 10),
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setWidth(20),
      // color: Colors.blue,
      child: MaterialButton(
        color: color == null
            ? (forumData['joined']
                ? Colors.white
                : Color.fromRGBO(255, 147, 0, 1))
            : color,
        textColor: textColor == null
            ? (forumData['joined'] ? Colors.grey : Colors.white)
            : textColor,
        child: new Text(
          text == null ? (forumData['joined'] ? '已加入' : '加入') : text,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        minWidth: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(20),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          // side: BorderSide(
          //   color: forumData['joined']
          //       ? Colors.white
          //       : Color.fromRGBO(255, 147, 0, 1),
          // ),
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30.0),
        //   side: BorderSide(color: Colors.pink),
        // ),
        onPressed: () async {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            if (callBack == null) {
              if (text != '管理') {
                if (forumData['joined']) {
                  showCupertinoDialog(
                    //showCupertinoDialog
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text('提示'),
                          content: Text('你确定退出该版块吗？'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop('cancel');
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('确定'),
                              onPressed: () async {
                                Navigator.of(context).pop('ok');
                                var response = await HttpUtil().get(Api.leaveForum,
                                    parameters: {'forumId': forumData['id']});
                                setState(() {
                                  forumData['joined'] = false;
                                });
                                Fluttertoast.showToast(
                                  msg:  '已退出',
                                  gravity: ToastGravity.CENTER,
                                  // textColor: Colors.grey,
                                );
                              },
                            ),
                          ],
                        );
                      });

                } else {
                  setState(() {
                    forumData['joined'] = true;
                  });
                  var response = await HttpUtil().get(Api.joinForum,
                      parameters: {'forumId': forumData['id']});
                  Fluttertoast.showToast(
                    msg:  '已加入',
                    gravity: ToastGravity.CENTER,
                    // textColor: Colors.grey,
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChaoFunWebView(
                      url: 'https://chao.fun/webview/forum/seting?forumId=' +
                          forumData['id'].toString(),
                      // url: 'http://192.168.8.208:8099/f/3/setting',
                      title: '版块设置',
                      showAction: 0,
                      cookie: true,
                    ),
                  ),
                );
              }
            } else {
              callBack();
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
