import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';

class UserSavePage extends StatefulWidget {
  final Map arguments;
  UserSavePage({Key key, this.arguments}) : super(key: key);
  _UserSavePageState createState() => _UserSavePageState();
}

class _UserSavePageState extends State<UserSavePage> {
  String forumId;
  Map forumData;
  List<Map> pageData = [];

  var params = {
    "pageNum": 1,
    "pageSize": '20',
    "marker": '',
  };
  EasyRefreshController _controller;
  var dataFuture;
  HomeService homeService = HomeService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDatas('refresh');
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    refreshData();
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      getDatas('');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
          elevation: 0,
          leading: Container(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: KColor.defaultGrayColor,
                size: 20,
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(bottom: 12, top: 12, right: 10),
              width: ScreenUtil().setWidth(140),
              height: ScreenUtil().setWidth(40),
              child: MaterialButton(
                color: Color.fromRGBO(255, 147, 0, 1),
                textColor: Colors.white,
                child: new Text(
                  '收藏夹',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                  ),
                ),
                minWidth: ScreenUtil().setWidth(120),
                height: ScreenUtil().setWidth(20),
                padding: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(
                    color: Color.fromRGBO(255, 147, 0, 1),
                  ),
                ),
                onPressed: () async {
                  Navigator.pushNamed(
                    context,
                    '/saveFolderList',
                    arguments: {},
                  );
                },
              ),
            ),
          ],
          brightness: Brightness.light,
          title: Text(
            '我收藏的',
            style: TextStyle(
                color: Colors.black, fontSize: ScreenUtil().setSp(34)),
          ),
          backgroundColor: Colors.white,
        ),
      body:
            SafeArea(
              child: Stack(children: <Widget>[
                EasyRefresh.custom(
                  enableControlFinishRefresh: false,
                  enableControlFinishLoad: false,
                  controller: _controller,
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ItemIndex(
                              item: pageData[index], type: 'forum');
                        },
                        childCount: pageData.length,
                      ),
                    ),
                  ],
                ),
              ]),
    )
    );
  }

  getForumData() async {
    var response = await HttpUtil()
        .get(Api.getForumInfo, parameters: {'forumId': forumId});
    setState(() {
      forumData = response['data'];
    });
  }

  void getDatas(type) async {
    params['forumId'] = forumId;
    var data = await HttpUtil().get(Api.myListSaved, parameters: params);
    // response = response['data'];
    if (type == 'refresh') {
      pageData = [];
      params["marker"] = null;

    }
    List<Map> res = (data['data']['posts'] as List).cast();
    // var asd = (data['posts'] as List).cast();
    List<Map> arr = [];
    if (res.length > 0) {
      // res.forEach((v) {
      //   if (v['type'] == 'image' ||
      //       v['type'] == 'link' ||
      //       v['type'] == 'article' ||
      //       v['type'] == 'gif' ||
      //       v['type'] == 'video') {
      //     arr.addAll([v]);
      //   }
      // });
      setState(() {
        pageData.addAll(res);
        print('HOME pagedata的数据长度是: ${pageData.length}');
        if (data['data']['marker'] != null) {
          params["marker"] = data['data']['marker'];
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: '没有更多了~',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    }
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      params['forumId'] = forumId;
      pageData = [];
      getDatas('refresh');
    });
  }
}
