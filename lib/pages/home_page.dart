import 'package:flutter_chaofan/pages/hometabs/all_tab_page.dart';
import 'package:flutter_chaofan/pages/hometabs/recommend_tab_page.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/hometop/topsearch_widget.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
// 刷新组件
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/provide/user.dart';

import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  var arguments;
  HomePage({Key key, this.arguments}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin
  // 防止刷新处理 保持状态

  bool showloading = false;

  // 火爆专区分页
  int page = 1;
  // 火爆专区数据
  List<Map> hotGoodsList = [];
  List<Map> navDataList = [
    {
      "title": '全站',
      "value": "",
    },
    {
      "title": '推荐',
      "value": "",
    },
    {
      "title": '关注',
      "value": "",
    },
  ];
  var params = {"pageSize": '30', "marker": '', "order": 'new'};

  String tabs = '0';
  List<Map> pageData = [];

  List<Map> sortData = [
    {
      "name": '最新',
      "value": "new",
    },
    {
      "name": '最热',
      "value": "hot",
    },
    {
      "name": '热评',
      "value": "comment",
    }
  ];
  var sort = 'new';
  var activitys = {'has': false, 'imgUrl': null, 'title': '', 'url': ''};
  var indexDialog = 'false';

  var homeFuture;
  HomeService homeService = HomeService();

  @override
  bool get wantKeepAlive => true;

  var platform = '';

  bool isLoading = false;

  PageController _pageController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (Platform.isIOS) {
      //ios相关代码
      platform = 'ios';
    } else if (Platform.isAndroid) {
      //android相关代码
      platform = 'android';
    }
    getActivity();
    homeFuture = homeService.getHomeList(params, (response) {
      var data = response;
      pageData = (data['posts'] as List).cast();
    }, (message) {});

    this._pageController =
        PageController(initialPage: this._tabIndex, keepPage: true)
          ..addListener(() {
            if (_tabIndex != _pageController.page.round()) {
              setState(() {
                _tabIndex = _pageController.page.round();
                if (_tabIndex == 0) {
                  tabs = '0';
                } else if (_tabIndex == 1) {
                  tabs = '1';
                } else if (_tabIndex == 2) {
                  tabs = '2';
                } else if (_tabIndex == 3) {
                  tabs = 'recommend';
                }
              });
            }
          });
  }

  getActivity() async {
    var data = await HttpUtil().get(Api.getActivity,
        parameters: {'version': '1.0.0', 'platform': platform});

    if (data['success'] && data['data'] != null) {
      setState(() {
        activitys['has'] = true;
        if (data['data']['imageName'] != null) {
          activitys['imgUrl'] = KSet.imgOrigin +
              data['data']['imageName'] +
              '?x-oss-process=image/resize,h_512/format,webp/quality,q_75';
        }

        activitys['title'] =
            data['data']['title'] != null ? data['data']['title'] : '';
        activitys['url'] = data['data']['url'];
        print(activitys);
      });
    }
  }

  // @override
  void dispose() {
    // 记得销毁对象
    _pageController.dispose();
    super.dispose();
  }

  void getUserInfo() async {
    var response = await HttpUtil().get(Api.getUserInfo);
    if (response['data'] != null) {
      Provider.of<UserStateProvide>(context, listen: false).changeState(true);
      Provider.of<UserStateProvide>(context, listen: false)
          .changeUserInfo(response['data']);
    }
  }

  void showLoading(isshow) {
    setState(() {
      showloading = isshow;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // resizeToAvoidBottomPadding: true,
        body: Stack(
          children: <Widget>[
            // Container(
            //   height: 150,
            //   alignment: Alignment.center,
            //   child: Text('开始'),
            // ),
            FutureBuilder(
              //防止刷新重绘
              future: homeFuture,
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
                    if (asyncSnapshot.hasError) {
                      return new Text('error');
                    } else {
                      if (Provider.of<UserStateProvide>(context, listen: false)
                          .ISLOGIN) {
                        Provider.of<UserStateProvide>(context, listen: false)
                            .getLooksList();
                        return PageAllTab(
                            sort: 'home', showLoading: showLoading);
                        // return Center(
                        //   child: Text('我是已登录首页'),
                        // );
                      } else {
                        Provider.of<UserStateProvide>(context, listen: false)
                            .getLooksList();
                        return PageAllTab(
                            sort: 'all', showLoading: showLoading);
                      }
                    }
                }
              },
            ),
            !isLoading
                ? Consumer<UserStateProvide>(builder: (BuildContext context,
                    UserStateProvide user, Widget child) {
                    if (user.ISLOGIN) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 38, // 搜索框60，导航80 + 边框20
                        // MediaQueryData.fromWindow(window).padding.top +
                        child: _navs(),
                      );
                    } else {
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 38, // 搜索框60，导航80 + 边框20
                        // MediaQueryData.fromWindow(window).padding.top +
                        child: _navs(),
                      );
                    }
                  })
                : Container(
                    height: 90,
                  ),
            Consumer<UserStateProvide>(
              builder:
                  (BuildContext context, UserStateProvide user, Widget child) {
                return showDialog()
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _activityWidget(context),
                      )
                    : Container(
                        height: 0,
                      );
              },
            ),
            showloading
                ? Positioned(
                    child: Container(
                      alignment: Alignment.center,
                      width: ScreenUtil().setWidth(750),
                      height: 35,
                      // color: Colors.white,
                      child: Container(
                        width: ScreenUtil().setWidth(30),
                        height: ScreenUtil().setWidth(30),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(254, 149, 0, 100)),
                        ),
                      ),
                    ),
                    top: 0,
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }

  _navs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(
        //   bottom: BorderSide(
        //     width: 0.1,
        //     color: KColor.defaultBorderColor,
        //   ),
        // ),
      ),
      padding: EdgeInsets.only(
        bottom: 0,
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: TopSearch(
              onChanged: (value) {
                if (activitys['has']) {
                  setState(() {
                    indexDialog = 'true';
                  });
                } else {
                  Fluttertoast.showToast(
                    msg: '还没有活动哦~',
                    gravity: ToastGravity.CENTER,
                    // textColor: Colors.grey,
                  );
                }
              },
              ishas: activitys['has'],
            ),
          ),
          // Container(
          //   // padding: EdgeInsets.only(right: 60),
          //   color: Colors.white,
          //   alignment: Alignment.centerLeft,
          //   width: ScreenUtil().setWidth(750),
          //   height: ScreenUtil().setHeight(210),
          //   padding: EdgeInsets.only(
          //     top: ScreenUtil().setHeight(10),
          //     bottom: ScreenUtil().setHeight(10),
          //     left: ScreenUtil().setHeight(10),
          //   ),
          //   child: ListView.builder(
          //     itemCount: 20,
          //     itemExtent: ScreenUtil().setHeight(180),
          //     scrollDirection: Axis.horizontal,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Container(
          //         margin: EdgeInsets.only(
          //             // right: ScreenUtil().setWidth(20),
          //             ),
          //         child: Column(
          //           children: [
          //             ClipRRect(
          //               borderRadius: BorderRadius.circular(10),
          //               child: Image.asset(
          //                 'assets/images/_icon/1.jpg',
          //                 width: ScreenUtil().setWidth(124),
          //                 height: ScreenUtil().setWidth(124),
          //               ),
          //             ),
          //             Text(
          //               '全站',
          //               style: TextStyle(
          //                 fontSize: ScreenUtil().setSp(24),
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  showDialog() {
    if (activitys['has'] && indexDialog == 'true') {
      return true;
    } else {
      return false;
    }
  }

  Widget _activityWidget(context) {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: Container(
        margin: EdgeInsets.only(
          top: ScreenUtil().setWidth(activitys['imgUrl'] != null ? 200 : 400),
        ),
        child: Center(
          child: Container(
            width: ScreenUtil().setWidth(550),
            child: Column(
              children: [
                Container(
                  width: ScreenUtil().setWidth(550),
                  height: activitys['imgUrl'] != null
                      ? ScreenUtil().setWidth(750)
                      : ScreenUtil().setWidth(300),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        indexDialog = 'false';
                      });
                      toNavigate(context, activitys['url'], activitys['title']);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ChaoFunWebView(
                      //         url: activitys['url'], title: activitys['title']),
                      //   ),
                      // );
                    },
                    child: activitys['imgUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: activitys['imgUrl'],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Text(
                              activitys['title'],
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(30)),
                            ),
                          ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        indexDialog = 'false';
                      });
                    },
                    child: Image.asset(
                      'assets/images/icon/close-btn.png',
                      width: ScreenUtil().setWidth(80),
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

  void toNavigate(context, url, String title) {
    String u = '';

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
      nativePush = true;
      print('打打');
      print(a);

      if (a.length >= 2 &&
          (a[0] == 'f' ||
              a[0] == 'p' ||
              a[0] == 'user' ||
              a[0] == 'predictions')) {
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
          case "predictions":
            u = '/predictionpage';
            arguments = {'forumId': end.toString()};
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
            cookie: true,
          ),
        ),
      );
    }
  }

  Widget _navItem(name, id, index) {
    return InkWell(
      onTap: () {
        setState(() {
          tabs = id;
          _tabIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Container(
        width: 50,
        height: 45,
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(18)),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          // color: Colors.black12,
          border: Border(
            bottom: BorderSide(
              width: 4,
              color: tabs == id ? KColor.primaryColor : Colors.white,
            ),
          ),
        ),
        child: Text(
          name,
          style: tabs == id ? KFont.homeNavActStyle : KFont.homeNavStyle,
        ),
      ),
    );
    // );
  }
}
