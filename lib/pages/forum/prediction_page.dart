import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/post_detail_page.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PredictionPage extends StatefulWidget {
  var arguments;
  PredictionPage({Key key, this.arguments}) : super(key: key);
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  var gameData;
  List pageData;
  var userData;
  var gameServer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gameServer = forumFuture({}, (response) {
      var data = response;
      print('--------------------------------11');
      print(data);
      print(data['name']);
      inits(data);
      getUserData(data);
      setState(() {
        gameData = data;
      });
    }, (message) {});
    // setState(() {
    //   forumId = widget.arguments['forumId'];
    // });
  }

  inits(data) async {
    // var res = await HttpUtil().get(Api.predictlistPosts,
    //       parameters: {'predictionsTournamentId': response['data']['id']});
    var res = await HttpUtil().get(Api.predictlistPosts,
        parameters: {'predictionsTournamentId': data['id']});
    setState(() {
      pageData = res['data'];
    });
    print(res);
  }

  getUserData(data) async {
    var res1 = await HttpUtil().get(Api.checkJoin,
        parameters: {'predictionsTournamentId': data['id']});
    if (res1['data'] == null) {
    } else {
      setState(() {
        userData = res1['data'];
      });
    }
  }

  Future forumFuture(Map<String, dynamic> parameters, OnSuccess onSuccess,
      OnFail onFail) async {
    try {
      print('123321');
      print(widget.arguments);
      var response = await HttpUtil().get(Api.predictionsGet,
          parameters: {'forumId': widget.arguments['forumId']});
      print(response);
      if (response['success']) {
        onSuccess(response["data"]);
      } else {
        onFail(response['errorMessage']);
      }
      return response;
    } catch (e) {
      print(e);
      onFail('fail');
    }
  }

  getDatas(v) async {
    var response = await HttpUtil().get(Api.predictionsGet,
        parameters: {'forumId': widget.arguments['forumId']});
    var res = await HttpUtil().get(Api.predictlistPosts,
        parameters: {'predictionsTournamentId': response['data']['id']});
    if (response['success']) {
      setState(() {
        pageData = res['data'];
        gameData = response['data'];
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0.5,
          // bottom: Border(),
          title: Text(
            (widget.arguments['forumName'] == null
                    ? ''
                    : (widget.arguments['forumName'] + '-')) +
                "竞猜活动",
            style: TextStyle(
                color: Colors.black, fontSize: ScreenUtil().setSp(36)),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(
              color: Color.fromRGBO(153, 153, 153, 1),
              //透明度
              opacity: 100,
              size: 10),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChaoFunWebView(
                      url: 'https://chao.fun/webview/prediction/rank?id=' +
                          (gameData == null ? '0' : gameData['id'].toString()),
                      title: '积分排行榜',
                      showAction: 0,
                      cookie: true,
                    ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "排行榜",
                  style: TextStyle(
                      color: KColor.primaryColor,
                      fontSize: ScreenUtil().setSp(30)),
                ),
              ),
            )
          ],
        ),
        body: FutureBuilder(
            //防止刷新重绘
            future: gameServer,
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
                  break;
                default:
                  if (asyncSnapshot.hasError) {
                    return new Text('error');
                  } else {
                    if (pageData != null) {
                      return CustomScrollView(
                        // controller: _scrollController,
                        slivers: <Widget>[
                          //CupertinoSliverRefreshControl
                          CupertinoSliverRefreshControl(
                            //CupertinoSliverRefreshControl
                            onRefresh: () async {
                              print('刷新了');
                              // await Future.delayed(Duration(milliseconds: 1000));
                              getDatas('refresh');
                              await Future.delayed(Duration(seconds: 1), () {});
                              //结束刷新
                              return Future.value(true);
                            },
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (content, index) {
                                if (index == 0) {
                                  //https://i.chao.fun/biz/0dd39345f731e512a2308a9cf20b8926.png
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          image: new DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                'https://i.chao.fun/biz/0dd39345f731e512a2308a9cf20b8926.png'),
                                            //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
                                            centerSlice: new Rect.fromLTRB(
                                                270.0, 180.0, 1360.0, 730.0),
                                          ),
                                        ),
                                        height: ScreenUtil().setWidth(450),
                                        width: ScreenUtil().setWidth(750),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height:
                                                  ScreenUtil().setWidth(120),
                                              // width: 180,
                                              alignment: Alignment.center,
                                              // color: Colors.blue,
                                              child: Text(
                                                gameData['name'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        ScreenUtil().setSp(48)),
                                              ),
                                            ),
                                            Container(
                                              height: ScreenUtil().setWidth(60),
                                              // width: 180,
                                              alignment: Alignment.center,
                                              // color: Colors.blue,
                                              child: Text(
                                                gameData['desc'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        ScreenUtil().setSp(32)),
                                              ),
                                            ),
                                            userData != null
                                                ? Container(
                                                    child: Text(
                                                      '我的积分：' +
                                                          userData['restTokens']
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 0,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return ItemIndex(
                                    item: pageData[index - 1],
                                    type: 'user',
                                    cate: 'prediction',
                                  );
                                }
                              },
                              childCount: pageData.length + 1,
                            ),
                          )
                        ],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(254, 149, 0, 100)),
                        ),
                      );
                    }
                  }
              }
            }),
      ),
    );
  }
}
