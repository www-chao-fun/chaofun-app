import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
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

class SaveDetailPage extends StatefulWidget {
  final Map arguments;
  SaveDetailPage({Key key, this.arguments}) : super(key: key);
  _SaveDetailPageState createState() => _SaveDetailPageState();
}

class _SaveDetailPageState extends State<SaveDetailPage>
    with AutomaticKeepAliveClientMixin {
  String folderId;
  Map forumData;
  bool canload = true;
  List<Map> pageData = [];
  ScrollController _scrollController = ScrollController();



  @override
  bool get wantKeepAlive => true;

  var params = {
    "pageNum": 1,
    "pageSize": '20',
    "marker": '',
    "order": 'hot',
    "range": "1hour",
    "tagId": "",
  };
  var tabTitle = [
    '页面1',
    '页面2',
    '页面3',
  ];
  List tagList = [];
  bool showTag = false;
  var url =
      'http://www.pptbz.com/pptpic/UploadFiles_6909/201203/2012031220134655.jpg';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      folderId = widget.arguments['id'].toString();
    });
    // initTag();
    // getForumData();
    getDatas('');
  }

  @override
  void dispose() {
    super.dispose();
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
      if (canload) {
        setState(() {
          canload = false;
        });
        getDatas('load');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ); //Colors.black38
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: AppBar(
            elevation: 0,
            titleSpacing: 0.0,
            leading: Container(
              color: Colors.transparent,
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
            title: Container(
              // color: Colors.red,
              height: 60,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '收藏夹：' + widget.arguments['name'],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(34)),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   child: Text(
                        //     '数量：100',
                        //     style: TextStyle(
                        //         color: Colors.black,
                        //         fontSize: ScreenUtil().setSp(26)),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white
            // backgroundColor: Color.fromRGBO(95, 60, 94, 1),
            ),
        preferredSize: Size.fromHeight(60),
      ),
      body: Container(
        color: Colors.white,
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
            // Container(
            //   height: 40,
            //   color: Colors.blue,
            // ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, int index) {
                  Container postPiece;

                  return ItemIndex(item: pageData[index], type: 'user');
                },
                childCount: pageData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void getDatas(type) async {
    params['folderId'] = folderId.toString();
    var data = await HttpUtil().get(Api.saveFolderlistPosts,
        parameters: params);
    // response = response['data'];
    print('okoks');
    print(data['data']);
    if (type == 'refresh') {
      pageData = [];
    }
    List<Map> res = (data['data'] as List).cast();

    setState(() {
      setState(() {
        canload = true;
      });
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      if ( res != null && res.length != 0) {
        params['pageNum'] =  int.parse(params['pageNum'].toString())+ 1;
      }
      // if (data['data']['marker'] != null) {
      //   params['marker'] = data['data']['marker'];
      // }

      // if (data['data']['key'] != null) {
      //   params['key'] = data['data']['key'];
      // }
    });
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      params['key'] = '';
      params['folderId'] = folderId.toString();
      params['pageNum'] = 1;
      // if (btnToTop) {
      pageData = []; // btnToTop = false;
      getDatas('refresh');
    });
  }

}
