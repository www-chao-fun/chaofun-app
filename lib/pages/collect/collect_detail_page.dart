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

class CollectDetailPage extends StatefulWidget {
  final Map arguments;
  CollectDetailPage({Key key, this.arguments}) : super(key: key);
  _CollectDetailPageState createState() => _CollectDetailPageState();
}

class _CollectDetailPageState extends State<CollectDetailPage>
    with AutomaticKeepAliveClientMixin {
  String forumId;
  Map forumData;
  bool canload = true;
  List<Map> pageData = [];
  bool showZanData = false;
  ScrollController _scrollController = ScrollController();

  List<Map> sortData = [
    {"name": '最新', "value": "new"},
    {"name": '最热', "value": "hot"},
    {"name": '热评', "value": "comment"},
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
      forumId = widget.arguments['id'].toString();
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
        getDatas('');
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
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          print('点击发布');
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            // var str = forumData['id'].toString() +
            //     '|' +
            //     forumData['name'] +
            //     '|' +
            //     forumData['imageName'];
            Navigator.pushNamed(context, '/submitpage', arguments: {});
          } else {
            Navigator.pushNamed(
              context,
              '/accoutlogin',
            );
          }
          // _pickImage(context);
        },
        child: Image.asset(
          'assets/images/_icon/push.png',
          width: 24,
          height: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
                  Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(right: 10),
                    child: ClipOval(
                      child: InkWell(
                        onTap: () {
                          // getImage(false);
                        },
                        child: Provider.of<UserStateProvide>(context,
                                        listen: false)
                                    .userInfo['icon'] !=
                                null
                            ? CachedNetworkImage(
                                imageUrl: KSet.imgOrigin +
                                    Provider.of<UserStateProvide>(context,
                                            listen: false)
                                        .userInfo['icon'] +
                                    '?x-oss-process=image/resize,h_150/format,webp/quality,q_75',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Image.asset('assets/images/icon/default.jpg'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '合集：' + widget.arguments['name'],
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
            if (item['type'] == 'link') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/linkpublish',
                  arguments: {'str': str});
            } else if (item['type'] == 'image') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/imagepublish',
                  arguments: {'str': str});
            } else if (item['type'] == 'textarea') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/articlepublish',
                  arguments: {'str': str});
            } else if (item['type'] == 'vote') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/votepublish',
                  arguments: {'str': str});
            }
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

  void getDatas(type) async {
    params['forumId'] = forumId;
    var data = await HttpUtil().get(Api.collectionlistPosts,
        parameters: {'collectionId': forumId.toString()});
    // response = response['data'];
    print('okoks');
    print(data['data']);
    if (type == 'refresh') {
      pageData = [];
    }
    List<Map> res = (data['data'] as List).cast();

    setState(() {
      setState(() {
        canload = false;
      });
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
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
      params['forumId'] = forumId;
      // if (btnToTop) {
      pageData = []; // btnToTop = false;
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
      color: Theme.of(context).scaffoldBackgroundColor,
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
                                });
                                refreshData();
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
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(40)),
                    // child: InkWell(
                    //   child: Image.asset(
                    //     'assets/images/_icon/video_model.png',
                    //     width: 16,
                    //     height: 16,
                    //   ),
                    // ),
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
                  var response = await HttpUtil().get(Api.joinForum,
                      parameters: {'forumId': forumData['id']});
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
