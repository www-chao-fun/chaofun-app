import 'package:flutter_chaofan/pages/discover/addJoin_page.dart';
import 'package:flutter_chaofan/pages/discover/allDisForum_page.dart';
import 'package:flutter_chaofan/pages/nonetwork_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/discover_service.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存

class DiscoverPage extends StatefulWidget {
  _DiscoverPageState createState() => _DiscoverPageState();
  // State<StatefulWidget> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin
  // 防止刷新处理 保持状态
  List<Map> allCates = [];
  List<Map> allForum = [];
  List<Map> speForum = [];
  bool ifAll = true;
  var params2 = {"tagId": 0};
  int page = 1;

  var params = {"pageSize": '20', "marker": '', "order": 'new'};
  List<Map> pageData = [];
  var homeFuture;
  HomeService homeService = HomeService();

  var cateFuture;
  DiscoverService discoverService = DiscoverService();

  // .getHomeList(params, (data) {}, (message) {})

  @override
  bool get wantKeepAlive => true;

  var _scrollController = ScrollController();
  var _showBackTop = false;
  var btnToTop = false;

  int tabs = 0;

  PageController _pageController;

  int _tabIndex = 0;

  List<Widget> _tabWidget = [
    AddJoinPage(),
    AllDiscoverPage(),

    // PageAllTab(),
    // PageFocusTab()
  ];
  var _rebuildLayoutController;

  List navData = [
    {'label': '加入&关注', 'value': 0},
    {'label': '全部版块', 'value': 1},
//    {'label': '更多', 'value': 2},
  ];

  Future getUserInfo() async {
    var response = await HttpUtil().get(Api.getUserInfo);
    return response;
  }
  // 记录是否更新

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: tabs);
  }

  @override
  void dispose() {
    // 记得销毁对象
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        print('还没有开始网络请求');
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        print('active');
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
      // print('waiting');
      // return Center(
      //   child: CircularProgressIndicator(),
      // );
      case ConnectionState.done:
        print('done');
        if (snapshot.hasError) return NoNetWorkPage(callBack: KSet.reLoad);
        return Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 45),
              // child: Provide<UserStateProvide>(builder:
              //     (BuildContext context, Widget child, UserStateProvide user) {
              child: Consumer<UserStateProvide>(
                  builder: (context, UserStateProvide user, Widget child) {
                if (!user.ISLOGIN) {
                  _tabWidget = [
                    AllDiscoverPage(),
                    ChaoFunWebView(
                      url: 'https://chao.fun/webview/activity/index',
                      title: '123',
                      cookie: true,
                      showHeader: false,
                    ),
                  ];
                } else {
                  _tabWidget = [
                    AddJoinPage(),
                    AllDiscoverPage(),
                    ChaoFunWebView(
                      url: 'https://chao.fun/webview/activity/index',
                      title: '222',
                      cookie: true,
                      showHeader: false,
                    ),
                  ];
                }
                return PageView(
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (int index) {
                    ///滑动PageView时，对应切换选择高亮的标签
                    setState(() {
                      _tabIndex = index;
                      tabs = index;
                    });

                    // Avoid error，maybe useless
                    if (_rebuildLayoutController != null) {
                      _rebuildLayoutController.notification();
                    }
                  },
                  children: _tabWidget,
                  controller: _pageController,
                );
              }),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 46,
              // height: ScreenUtil().setWidth(160), // 搜索框60，导航80 + 边框20
              // MediaQueryData.fromWindow(window).padding.top +
              child: Container(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(50),
                  right: ScreenUtil().setWidth(50),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: Color.fromRGBO(240, 240, 240, 1),
                    ),
                  ),
                ),
                child: Consumer<UserStateProvide>(
                  builder: (context, UserStateProvide user, Widget child) {
                    if (!user.ISLOGIN) {
                      navData = [
                        {'label': '全部版块', 'value': 0},
                        {'label': '更多', 'value': 1},
                      ];
                    } else {
                      navData = [
                        {'label': '加入&关注', 'value': 0},
                        {'label': '全部版块', 'value': 1},
                        {'label': '更多', 'value': 2},
                      ];
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: navData.map((item) {
                        return _navItem(item['label'], item['value']);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          builder: _buildFuture,
          future: getUserInfo(), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
        ),
      ),
    );
  }

  Widget _chooseForum() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _title('版块'),
          Container(
            child: InkWell(
              onTap: () {
                _pickImage(context);
              },
              child: Text(
                '请选择版块 >',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: KColor.defaultGrayColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// 选择版块
  _pickImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setHeight(300),
        child: Column(
          children: [
            Container(
              child: Text('选择版块'),
            ),
          ],
        ),
      ),
    );
  }

  // 标题输入框
  Widget _titleInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        maxLines: 3,
        // decoration: InputDecoration.collapsed(hintText: "请输入标题"),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入标题",
          contentPadding: EdgeInsets.fromLTRB(14, 8, 14, 8),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: KColor.defaultGrayColor, width: 1)),
        ),
      ),
    );
  }

  Widget _title(title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _navItem(name, id) {
    return InkWell(
      onTap: () {
        // if (id == 2) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => WebViewExample(
        //         // url: 'http://192.168.8.208:9010/uupieh5/#/test',
        //         // url: 'http://192.168.8.208:8099',
        //         url: 'http://192.168.8.208:8099/webview/forum/seting?forumId=3',
        //         // url: 'https://chao.fun',
        //         title: '反馈建议',
        //         showAction: 0,
        //         cookie: true,
        //       ),
        //     ),
        //   );
        // } else {
        FocusScope.of(this.context).requestFocus(FocusNode());
        setState(() {
          tabs = id;
          _tabIndex = id;
          _pageController.animateToPage(
            id,
            duration: Duration(milliseconds: 10),
            curve: Curves.fastOutSlowIn,
          );
        });
        // }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: ScreenUtil().setWidth(150),
        height: 45,
        padding: EdgeInsets.only(
          top: 5,
          // left: ScreenUtil().setHeight(30),
          // right: ScreenUtil().setHeight(30),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // color: Colors.black12,
            border: Border(
              bottom: BorderSide(
                width: 4,
                color:
                    tabs == id ? Color.fromRGBO(255, 147, 0, 1) : Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
          child: Text(
            name,
            style: tabs == id
                ? Theme.of(context).textTheme.bodyText1
                : Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ),
    );
  }
}
