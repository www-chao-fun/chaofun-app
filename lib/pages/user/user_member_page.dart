import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/chat_home_page.dart';
import 'package:flutter_chaofan/pages/chat_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class UserMemberPage extends StatefulWidget {
  var arguments;
  UserMemberPage({Key key, this.arguments}) : super(key: key);
  _UserMemberPageState createState() => _UserMemberPageState();
}

class _UserMemberPageState extends State<UserMemberPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  bool canload = true;

  Map memberInfo = {'focused': false, 'icon': '', 'userName': ''};

  var curSelected = 'publish';

  List<Map> pageData = [
    {'name': 'sort'},
    {'name': 'sort'},
  ];

  bool showZanData = false;

  List<Map> sortData = [
    {"name": '最新', "value": "new"},
    {"name": '最热', "value": "hot"},
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
    'userId': 'all',
    'order': 'new'
  };

  PageController _pageController;
  int _tabIndex = 0;
  String tabs = '0';

  var memberInfoFuture;
  HomeService homeService = HomeService();

  bool isChangeTop = false;
  bool isShowNav = false;
  EasyRefreshController _controller = EasyRefreshController();
  bool hasMore = true;
  List badges;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('widget.arguments');
    print(widget.arguments['userId']);
    params['userId'] = widget.arguments['userId'];
    memberInfoFuture = homeService
        .getMemberInfo({'userId': widget.arguments['userId']}, (response) async {
      // var data = response;
      // // setState(() {
      // setState(() {
      //   commentList = (data as List).cast();
      // });
      // var data = (response as List).cast();
      setState(() {
        memberInfo = response;
      });
      print(response);
    }, (message) {
      print('失败了');
    });

    getBadges();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('加载更多');
        _onLoading();
      }
      if (_scrollController.offset > 196) {
        setState(() {
          isShowNav = true;
        });
      } else {
        setState(() {
          isShowNav = false;
        });
      }
    });

    getDatas('');
  }

  Future<void> getBadges() async {
     var response = await HttpUtil().get(Api.listBadges, parameters: {"userId":  widget.arguments['userId']});
     if(response['success']) {
       setState(() {
         badges = response['data'];
       });
     } else {
       Fluttertoast.showToast(
         msg: response['errorMessage'],
         gravity: ToastGravity.CENTER,
         // textColor: Colors.grey,
       );
     }

  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _scrollController.dispose();
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

  _onRefresh() async {
    // monitor network fetch
    print('kiiii');
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
  }

  _onLoading() async {
    print('kiiii');
    // monitor network fetch
    print('88888888888888888888888888888888888888');
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
    if (canload) {
      setState(() {
        canload = false;
      });
      if (curSelected == 'publish') {
        getDatas('');
      } else if (curSelected == 'ups') {
        getDatas3('');
      } else {
        getDatas2('');
      }
    }
  }

  Widget _loadMoreWidget() {
    if (hasMore) {
      return new Padding(
        padding: const EdgeInsets.all(30.0),
        child: new Center(child: new CupertinoActivityIndicator()),
      );
    } else if (pageData.length > 2) {
      return new Padding(
        padding: const EdgeInsets.all(30.0),
        child: new Center(
            child: Text(
          '没有更多数据了-',
          style: TextStyle(color: Colors.grey),
        )),
      );
    } else {
      return new Padding(
        padding: const EdgeInsets.all(50.0),
        child: new Center(
          child: Container(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/_icon/nocontent.png',
                  width: ScreenUtil().setWidth(300),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('暂无更多数据~')
              ],
            ),
          ),
        ),
      );
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
          future: memberInfoFuture,
          builder: (context, AsyncSnapshot asyncSnapshot) {
            switch (asyncSnapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(254, 149, 0, 100)),
                  ),
                );
              default:
                print(asyncSnapshot.connectionState);
                print(asyncSnapshot.hasError);
                if (asyncSnapshot.hasError) {
                  return new Text('error');
                } else {
                  return Stack(
                    children: [
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 0),
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: <Widget>[
                            CupertinoSliverRefreshControl(
                              onRefresh: () async {
                                print('刷新了');
                              },
                            ),
                            SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((content, index) {
                                if (index == (pageData.length)) {
                                  return _loadMoreWidget();
                                } else if (index == 0) {
                                  return _userTopInfo();
                                } else if (index == 1) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        _badges(),
                                        _topNav(),
                                        curSelected != 'ups'
                                            ? sortCell()
                                            : Container(
                                                height: 0,
                                              ),
                                      ],
                                    ),
                                  );
                                } else {
                                  if (curSelected != 'comment') {
                                    return ItemIndex(
                                        item: pageData[index], type: 'forum');
                                  } else {
                                    return _itemComment(pageData[index]);
                                    // return Text('123');
                                  }
                                  // return _pages();
                                }
                              }, childCount: pageData.length + 1),
                            )
                          ],
                        ),
                      ),
                      isShowNav
                          ? Positioned(
                              child: _fixedTop(),
                              top: 0,
                              right: 0,
                              left: 0,
                            )
                          : Container(
                              height: 1,
                            ),
                    ],
                  );
                }
            }
          }),
    );
  }

  Widget _badges() {
    if (badges != null && badges.length > 0) {
      return
        Column(
            children: [
              Row(
                  children: [
                    Container(
                      alignment:
                      Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.star_sharp
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text('徽章',
                              style: TextStyle(fontSize: ScreenUtil().setSp(30), fontWeight: FontWeight.bold,),
                            ),
                          ]),
                      width: ScreenUtil().setWidth(140),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        // width: 100,
                        height: ScreenUtil().setWidth(80),
                        padding: EdgeInsets.only(
                            top: 3,
                            bottom: 5),
                        child: ListView.builder(
                            scrollDirection:
                            Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                height: ScreenUtil().setWidth(60),
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: InkWell(
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
                                              (badges[index]['badge']['id'] == null ? '' : badges[index]['badge']['id'].toString()) , //'https://chao.fun/webview/agreement',
                                          title: badges[index]['badge']['name'],
                                          showAction: false,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                      KSet.imgOrigin +
                                          badges[index]['badge']['icon']+
                                          '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                                    width: ScreenUtil().setWidth(60),
                                    height: ScreenUtil().setWidth(60),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            itemCount: badges.length
                        ),
                      ),
                    ),

                  ]),
              new Container(height: 0.5, color: Colors.black,)
            ]);
    } else {
      return Container();
    }


  }
  Widget _itemComment(item) {
    return Container(
      padding: EdgeInsets.all(
        ScreenUtil().setWidth(30),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 5,
            color: Color.fromRGBO(33, 29, 47, 0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  KSet.imgOrigin +
                      item['userInfo']['icon'] +
                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item['userInfo']['userName'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            // color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Utils.moments(item['gmtCreate']),
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
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(4),
            child: RichText(
              text: TextSpan(
                text: '评论说：',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: Colors.grey,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: item['text'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(53, 53, 53, 1),
                    ),
                  ),
                ],
              ),
            ),
            // child: Text(

            // ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/postdetail',
                arguments: {"postId": item['post']['postId'].toString(), "targetCommentId": item['id']},
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              color: Color.fromRGBO(33, 29, 47, 0.05),
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  text: item['post']['forum']['name'] + ' · ',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: Theme.of(context).hintColor,
                    // fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: item['post']['title'],
                      style: TextStyle(
                        color: Color.fromRGBO(33, 29, 47, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userTopInfo() {
    return Container(
      height: ScreenUtil().setWidth(500),
      width: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
          // image: AssetImage("assets/背景/bg1.jpg"),
          image: NetworkImage(
            KSet.imgOrigin +
                (memberInfo == null || memberInfo['icon'] == null ? '' : memberInfo['icon'] ) +
                '?x-oss-process=image/resize,h_414/format,webp/quality,q_75',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        // make sure we apply clip it properly
        child: BackdropFilter(
          //背景滤镜
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), //背景模糊化
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(30),
              ScreenUtil().setWidth(100),
              ScreenUtil().setWidth(30),
              ScreenUtil().setWidth(30),
            ),
            color: (Theme.of(context).hintColor).withOpacity(0.3),
            // child: Text(
            //   "CHOCOLATE", //前景文字
            //   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            // ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/icon/back.png',
                          width: ScreenUtil().setWidth(80),
                        ),
                        Row(
                          children: [
                            chatButton(context),
                            focusButton(context)
                          ]
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                print('12312');
                                Navigator.of(context).push(
                                  FadeRoute(
                                    page: JhPhotoAllScreenShow(
                                      imgDataArr: [
                                        KSet.imgOrigin + memberInfo['icon']
                                        // +'?x-oss-process=image/resize,h_1024/format,webp/quality,q_75',
                                        // 'https://i.chao.fun/biz/097049900ba1c8e6cc03e27138e82758.jpg?x-oss-process=image/resize,h_512/format,webp/quality,q_75'
                                      ],
                                      index: 0,
                                    ),
                                  ),
                                );
                              },
                              child:  ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  KSet.imgOrigin +
                                      memberInfo['icon'] +
                                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                                  width: ScreenUtil().setWidth(120),
                                  height: ScreenUtil().setWidth(120),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: ScreenUtil().setWidth(120),
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(0),
                                  bottom: ScreenUtil().setWidth(10),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            memberInfo['userName'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Image.asset(
                                          'assets/images/_icon/ttt.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: 2,
                                                bottom: 2,
                                                left: 4,
                                                right: 4),
                                            color:
                                                Theme.of(context).hintColor,
                                            child: Text(
                                              '获赞：' +
                                                  (memberInfo['ups'] != null
                                                          ? memberInfo['ups']
                                                          : 0)
                                                      .toString(),
                                              style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(24),
                                                color: Color.fromRGBO(
                                                    255, 147, 0, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/focus_user',
                                                  arguments: {'title': '粉丝', 'userId': memberInfo['userId'].toString()},
                                                );
                                              },
                                              child: RichText(
                                                  text: TextSpan(
                                                      text: memberInfo['followers'] != null
                                                          ? memberInfo['followers']
                                                          .toString()
                                                          : '',
                                                      style: TextStyle(
                                                        fontSize: ScreenUtil().setSp(34),
                                                        color: Colors.white,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(text: ' '),
                                                        TextSpan(
                                                          text: '粉丝',
                                                          style: TextStyle(
                                                            fontSize:
                                                            ScreenUtil().setSp(28),
                                                            color: Color.fromRGBO(
                                                                255, 255, 255, 0.8),
                                                          ),
                                                        )]
                                                  )
                                              )
                                          ),
                                          Text('    '),
                                          InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/focus_user',
                                                arguments: {'title': '关注', 'userId': memberInfo['userId'].toString()},
                                              );
                                            },
                                              child: RichText(
                                                  text: TextSpan(
                                                      text: memberInfo['focus'] != null
                                                          ? memberInfo['focus']
                                                          .toString()
                                                          : '',
                                                      style: TextStyle(
                                                        fontSize: ScreenUtil().setSp(34),
                                                        color: Colors.white,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(text: ' '),
                                                        TextSpan(
                                                          text: '关注',
                                                          style: TextStyle(
                                                            fontSize:
                                                            ScreenUtil().setSp(28),
                                                            color: Color.fromRGBO(
                                                                255, 255, 255, 0.8),
                                                          ),
                                                        )]
                                                  )
                                              )
                                          )
                                        ]
                                    ),
                                    Row(children:[
                                      Text(
                                          ' UID:' + ( memberInfo != null && memberInfo['userId'] != null ? memberInfo['userId'].toString() : ''),
                                          style: TextStyle(
                                            fontSize:ScreenUtil().setSp(14),
                                            color: Colors.white,
                                          )
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 44,
                  // color: Colors.black,
                  // width: ScreenUtil().setWidth(620),
                  padding: EdgeInsets.only(left: 30),
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(right: 0, top: 5, left: 0, bottom: 0),
                  child: Text(
                    memberInfo['desc'] == null ? '' : memberInfo['desc'],
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                        fontSize: ScreenUtil().setSp(28)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topNav() {
    return Container(
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.only(top: 0),
      height: 48,
      decoration: BoxDecoration(
        // color: Color.fromRGBO(95, 60, 94, 1),
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Color.fromRGBO(240, 240, 240, 1),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.0),
          topRight: Radius.circular(14.0),
        ),
        child: InkWell(
          onTap: () {},
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      curSelected = 'publish';
                      isShowNav = false;
                      hasMore = true;
                      // params['marker'] = '';
                    });
                    refreshData();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 5,
                          color: curSelected == 'publish'
                              ? Color.fromRGBO(255, 147, 0, 1)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      '发布',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: curSelected == 'publish'
                            ? Color.fromRGBO(0, 0, 0, 1)
                            : Color.fromRGBO(33, 29, 47, 0.7),
                        fontWeight: curSelected == 'publish'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      curSelected = 'comment';
                      isShowNav = false;
                      hasMore = true;
                      // params['marker'] = '';
                    });
                    refreshData();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 5,
                          color: curSelected == 'comment'
                              ? Color.fromRGBO(255, 147, 0, 1)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      '评论',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: curSelected == 'comment'
                            ? Color.fromRGBO(0, 0, 0, 1)
                            : Color.fromRGBO(33, 29, 47, 0.7),
                        fontWeight: curSelected == 'comment'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      curSelected = 'ups';
                      isShowNav = false;
                      hasMore = true;
                      // params['marker'] = '';
                    });
                    refreshData();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    padding: EdgeInsets.only(left: 4, right: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 5,
                          color: curSelected == 'ups'
                              ? Color.fromRGBO(255, 147, 0, 1)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      '点赞',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: curSelected == 'ups'
                            ? Color.fromRGBO(0, 0, 0, 1)
                            : Color.fromRGBO(33, 29, 47, 0.7),
                        fontWeight: curSelected == 'ups'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fixedTop() {
    return Container(
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setWidth(180),
            color: Color.fromRGBO(95, 60, 94, 1),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(
                    right: 8,
                    left: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      KSet.imgOrigin + memberInfo['icon'] + '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      textDirection: TextDirection.ltr,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            memberInfo['userName'],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(32),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '获赞：' +
                                (memberInfo['ups'] != null
                                        ? memberInfo['ups']
                                        : 0)
                                    .toString(),
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(24),
                              color: Color.fromRGBO(255, 255, 255, 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (!Provider.of<UserStateProvide>(context, listen: false).ISLOGIN
                    || memberInfo['userId'] == Provider.of<UserStateProvide>(context, listen: false).userInfo['userId'])
                    ? Text('')
                    : focusButton(context),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                _topNav(),
                curSelected != 'ups'
                    ? sortCell()
                    : Container(
                        height: 0,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getDatas(type) async {
    var data = await HttpUtil().get(Api.getMemberListPosts, parameters: params);
    // response = response['data'];

    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'},
        {'name': 'sort'}
      ];
    }
    List<Map> res = (data['data']['posts'] as List).cast();
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
      if (res.length < 20) {
        hasMore = false;
      }
    });
  }

  void getDatas2(type) async {
    var data = await HttpUtil().get(Api.getListComments, parameters: params);
    // response = response['data'];
    print(data);
    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'},
        {'name': 'sort'}
      ];
    }
    print('查看marker');
    print(params['marker']);
    List<Map> res = (data['data']['comments'] as List).cast();
    print('res.length');
    print(res.length);
    print(res);
    setState(() {
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      canload = true;
      if (data['data']['marker'] != null) {
        params['marker'] = data['data']['marker'];
        print('890');
        print(params['marker']);
      }

      if (data['data']['key'] != null) {
        params['key'] = data['data']['key'];
      }
      if (res.length < 20) {
        hasMore = false;
      }
    });
  }

  void getDatas3(type) async {
    var data =
        await HttpUtil().get(Api.getMemberListUpvotes, parameters: params);
    print(data);
    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'},
        {'name': 'sort'}
      ];
    }
    List<Map> res = (data['data']['posts'] as List).cast();
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
      if (res.length < 20) {
        hasMore = false;
      }
    });
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      params['key'] = '';
      // if (btnToTop) {
      pageData = [
        {'name': 'sort'},
        {'name': 'sort'},
      ];
      // btnToTop = false;
      // const timeout = const Duration(seconds: 1);
      // print('currentTime=' + DateTime.now().toString()); // 当前时间
      // Timer(timeout, () {
      //   //callback function
      //   print('afterTimer=' + DateTime.now().toString()); // 5s之后
      //   pageData = a;
      // });
      // }
      if (curSelected == 'publish') {
        getDatas('refresh');
      } else if (curSelected == 'ups') {
        getDatas3('refresh');
      } else {
        getDatas2('refresh');
      }
    });
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
                                // if (item['value'] == 'ups') {
                                //   setState(() {
                                //     showZanData = !showZanData;
                                //     params['order'] = item['value'];
                                //   });
                                // } else {
                                //   setState(() {
                                //     params['order'] = item['value'];
                                //   });
                                //   refreshData();
                                // }
                                setState(() {
                                  params['order'] = item['value'];
                                });
                                refreshData();
                              },
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  color: Color.fromRGBO(
                                      33,
                                      29,
                                      47,
                                      params['order'] == item['value']
                                          ? 1
                                          : 0.5),
                                  fontSize: ScreenUtil().setSp(26),
                                  fontWeight: params['order'] == item['value']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              )),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(30)),
                    child: Row(
                      children: [
                        Text(
                          '视图',
                          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            String str = Provider.of<UserStateProvide>(context,
                                            listen: false)
                                        .modelType ==
                                    'model1'
                                ? 'model2'
                                : 'model1';

                            Provider.of<UserStateProvide>(context,
                                    listen: false)
                                .setModelType(str);
                          },
                          child: Image.asset(
                            Provider.of<UserStateProvide>(context,
                                            listen: false)
                                        .modelType ==
                                    'model1'
                                ? 'assets/images/_icon/mode_1.png'
                                : 'assets/images/_icon/mode_2.png',
                            width: ScreenUtil().setWidth(44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatButton(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10, right: 10),
      width: ScreenUtil().setWidth(150),
      height: ScreenUtil().setWidth(60),
      // color: Colors.blue,
      child: MaterialButton(
        color: Color.fromRGBO(255, 147, 0, 1),
        textColor: Colors.white,
        child: new Text(
          "聊天",
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
        minWidth: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(20),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: Color.fromRGBO(255, 147, 0, 1),
          ),
        ),
        onPressed: () async {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            var response = await HttpUtil.instance.get(Api.startChat, parameters: {"targetUserId": memberInfo['userId']},alterFailed: true);
            if (response['success']) {
              routePush(context, new ChatPage(
                  id:  response['data']['id'],
                  title: response['data']['name'],
                  type: 2,
              ));
            }
          }
        },
      ),
    );
  }

  Widget focusButton(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10, right: 10),
      width: ScreenUtil().setWidth(150),
      height: ScreenUtil().setWidth(60),
      // color: Colors.blue,
      child: MaterialButton(
        color: memberInfo['focused'] != null && memberInfo['focused']
            ? Colors.white
            : Color.fromRGBO(255, 147, 0, 1),
        textColor: memberInfo['focused'] ? Colors.grey : Colors.white,
        child: new Text(
          memberInfo['focused'] ? '取消关注' : '+关注',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
        minWidth: ScreenUtil().setWidth(100),
        height: ScreenUtil().setWidth(20),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: memberInfo['focused']
                ? Colors.white
                : Color.fromRGBO(255, 147, 0, 1),
          ),
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30.0),
        //   side: BorderSide(color: Colors.pink),
        // ),
        onPressed: () async {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            var response = await HttpUtil().get(Api.toFocusUser,
                parameters: {'focusId': memberInfo['userId']});

            if (response['success']) {
              // FocusScope.of(context).requestFocus(_commentFocus);
              Fluttertoast.showToast(
                msg: memberInfo['focused'] ? '已取消关注' : '已关注',
                gravity: ToastGravity.CENTER,
                // textColor: Colors.grey,
              );
              if (memberInfo['focused']) {
                setState(() {
                  memberInfo['focused'] = false;
                });
                var response = await HttpUtil().get(Api.toUnFocusUser,
                    parameters: {'focusId': memberInfo['userId']});
              } else {
                setState(() {
                  memberInfo['focused'] = true;
                });

              }
            } else {
              Fluttertoast.showToast(
                msg: response['errorMessage'],
                gravity: ToastGravity.CENTER,
              );
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
