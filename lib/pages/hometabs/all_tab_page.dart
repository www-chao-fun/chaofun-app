import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/nonetwork_page.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/common/addForum_widget.dart';
import 'package:flutter_chaofan/widget/items/flow_index_widget.dart';

import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
// 刷新组件
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/provide/user.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../provide/current_index_provide.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/database.dart';

class PageAllTab extends StatefulWidget {
  var sort;
  final Function showLoading;
  PageAllTab({Key key, this.sort, this.showLoading}) : super(key: key);
  _PageAllTabState createState() => _PageAllTabState();
}

class _PageAllTabState extends State<PageAllTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isShowTop = true;
  double startPointer = 0;
  bool isStop = true;
  bool isEnd = true;
  ScrollController _scrollController = ScrollController();

  var homeFuture;
  HomeService homeService = HomeService();

  var btnToTop = false;
  bool isLoading = true;
  String sort;
  var db;
  var path;
  var batch;
  var dataFrom;
  bool canRefresh = true;
  List<Map> pageData = [
    {'name': 'nav'},
    {'name': 'sort'},
  ];
  List<Map> pageData1 = [];

  var params = {
    "pageSize": '16',
    "marker": '',
    "order": 'hot',
    "range": "1hour",
    'forumId': 'home',
    'onlyNew': false,
  };

  String tabs = 'home';
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
  var indexDialog = 'false';
  bool canload = true;
  bool showZanData = false;

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Map> navList = [];
  bool noNet = false;
  bool sqlHasData = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    params['forumId'] = widget.sort;
    print('请求异常1');
    doDatabase();

    // getDatas('');
  }

  getDBdata() async {
    List<Map> list2 = await db.rawQuery('SELECT * FROM All_page');
    List<Map> maps = List<Map>.from(list2);
    List<Map> lists = [];
    list2.forEach((element) {
      // get the first record
      Map oks = Map.from(element);
      oks['forum'] = jsonDecode(oks['forum']);
      oks['userInfo'] = jsonDecode(oks['userInfo']);
      oks['images'] = jsonDecode(oks['images']);
      oks['canDeleted'] = (oks['canDeleted'] == 1 ? true : false);
      oks['save'] = (oks['save'] == 1 ? true : false);
      oks['voteHasEnded'] = (oks['voteHasEnded'] == 1 ? true : false);
      lists.add(oks);
    });
    print('克隆内容');
    print(lists);

    setState(() {
      pageData.addAll(lists);
      // isLoading = false;
      // if (lists.length > 0) {
      //   sqlHasData = true;
      // }
    });
    // var c = jsonDecode(list2[0]['userInfo']);
    // print(list2[0]['userInfo']['userName']);
    // print(c['userName']);
    // print('获取数据库');
    // print(list2);
  }

  delays() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      isLoading = false;
    });
  }

  doDatabase() async {
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
    homeFuture = homeService.getHomeList(params, (response) {
      print('请求异常29');
      List<Map> res = (response['posts'] as List).cast();
      setState(() {
        pageData = [
          {'name': 'nav'},
          {'name': 'sort'},
        ];
      });
      if (res.length > 0) {
        List<Map> arr = [];
        if (res.length > 0) {
          res.forEach((v) {
            arr.addAll([v]);
          });
        }
        print(arr[4]);
        setState(() {
          pageData.addAll(arr);
          isLoading = false;
          params["marker"] = response['marker'];
          params['key'] = response['key'];
          delays();
        });
        initDB(res);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, (message) {
      setState(() {
        isLoading = false;
        noNet = true;
      });
      Fluttertoast.showToast(
        msg: '网络异常，请检查网络设置.',
        gravity: ToastGravity.CENTER,
      );
      print('请求异常99987');
    });

    var paths = await initDeleteDb('test_batch.db'); //initDeleteDb
    print('paths');
    print(paths);

    var dbs = await openDatabase(paths);
    print('dbs');
    print(dbs);
    // empty batch
    var batchs = dbs.batch();
    print('batchs');
    print(batchs);
    if (Platform.isAndroid) {
      setState(() {
        db = dbs;
      });
    }
//    db = dbs;
//    setState(() {
//      path = paths;
//      db = dbs;
//      batch = batchs;
//    });
    //判断表是否存在
    // print('判断表是否存在');
    // print(await isTableExits(db, 'db_All_page'));
    if (await isTableExits(db, 'All_page')) {
      print('表存在');
      // await batch.delete('All_page');
      // await batch.commit();
    } else {
      //创建表
      batch.execute(
          'CREATE TABLE All_page (id INTEGER PRIMARY KEY, article,articleType,canDeleted,chooseOption,circuseeCount,comments,cover,coverHeight,coverWidth,downs,forum,forumId,gmtCreate,gmtModified,height,hot,imageName,imageNums,images,link,optionSize,optionVoteCount,options,postId,save,sourcePost,sourcePostId,title,type,ups,userInfo,video,videoType,vote,voteHasEnded,voteTtl,width)');
      batch.execute(
          "create table table_addjoin(id integer primary key, addForum,focusUser)");
      batch.execute(
          "create table table_user(id integer primary key, userId,userName,icon,ups,followers,desc,phone,gmtCreate,gmtModified )");
      // batch.execute(
      //     'CREATE TABLE page_key (id INTEGER PRIMARY KEY, pageName,page_key,marker)');

      batch.execute("create table table_tag(id, name)");
      batch.execute(
          "create table table_forum(id,desc,followers,imageName,name,posts,tag,joined)");
      await batch.commit();
    }
    getDBdata();
  }

  initDB(res) async {
    if (db != null) {
      await db.delete('All_page');
    }
    insertDB(res);
  }

  insertDB(data) async {
    print('vvvvv');
    await db.transaction((txn) async {
      var batches = txn.batch();
      data.forEach((v) {
        // print('insP');
        // print(v);
        // print(ins);
        // batches.insert('All_page', {
        //   'article': v['title'],
        //   'articleType': v['articleType'],
        //   'canDeleted': {'ASD': 999}.toString()
        // });
        // batches.insert('All_page', v);
        batches.insert('All_page', {
          'article': v['article'],
          'articleType': v['articleType'],
          'canDeleted': v['canDeleted'],
          'chooseOption': v['chooseOption'],
          'circuseeCount': v['circuseeCount'],
          'comments': v['comments'],
          'cover': v['cover'],
          'coverHeight': v['coverHeight'],
          'coverWidth': v['coverWidth'],
          'downs': v['downs'],
          'forum': jsonEncode(v['forum']),
          'forumId': v['forumId'],
          'gmtCreate': v['gmtCreate'],
          'gmtModified': v['gmtModified'],
          'height': v['height'],
          'hot': v['hot'],
          'imageName': v['imageName'],
          'imageNums': v['imageNums'],
          'images': jsonEncode(v['images']),
          'link': v['link'],
          'optionSize': v['optionSize'],
          'optionVoteCount': v['optionVoteCount'],
          'options': v['options'],
          'postId': v['postId'],
          'save': v['save'],
          'sourcePost': v['sourcePost'],
          'sourcePostId': v['sourcePostId'],
          'title': v['title'],
          'type': v['type'],
          'ups': v['ups'],
          'userInfo': jsonEncode(v['userInfo']),
          'video': v['video'],
          'videoType': v['videoType'],
          'vote': v['vote'],
          'voteHasEnded': v['voteHasEnded'],
          'voteTtl': v['voteTtl'],
          'width': v['width'],
        });
      });
      // batches.rawQuery('SELECT * FROM page_key where page_key = ?', []);
      var results = await batches.commit(continueOnError: true);
    });
    List<Map> list2 = await db.rawQuery('SELECT * FROM All_page');

    // db.close();
  }

  void getDatas(type) async {
    print('params-------------------------------------------------');
    print(params);
    if (type == 'refresh') {
      widget.showLoading(true);
    }

    try {
      var data = await HttpUtil().get(Api.HomeListCombine, parameters: params);
      if (noNet) {
        setState(() {
          noNet = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => IndexPage()),
          (route) => route == null,
        );
        return;
      }
      if (type == 'refresh') {
        setState(() {
          pageData = [
            {'name': 'nav'},
            {'name': 'sort'}
          ];
        });
        Future.delayed(Duration(milliseconds: 2000)).then((e) {
          setState(() {
            canRefresh = true;
          });
        });
      }
      List<Map> res = (data['data']['posts'] as List).cast();
      
      if (type == 'addForum' && (res == null || res.length == 0)) {
        Fluttertoast.showToast(
          msg: '暂无数据',
          gravity: ToastGravity.CENTER,
          // textColor: Colors.grey,
        );
      }

      setState(() {
        print('HOME pagedata的数据长度是: ${pageData.length}');
        pageData.addAll(res);
        params["marker"] = data['data']['marker'];
        params['key'] = data['data']['key'];
        isLoading = false;
        if (res.length == 0) {
          canload = false;
        } else {
          canload = true;
        }
      });

      widget.showLoading(false);
    } catch (e) {
      print('网络异常');
      widget.showLoading(false);
      Fluttertoast.showToast(
        msg: '网络异常，请检查网络设置..',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
      setState(() {
        isLoading = false;
        canload = true;
        // noNet = true;
      });
      // db.close();
    }
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

      if (modelType == 'model3') {
        params['media'] = true;
        params['pageSize'] = 30;
      } else {
        params['media'] = false;
        params['pageSize'] = 16;
      }

      if (btnToTop) {
        pageData = [
          {'name': 'nav'},
          {'name': 'sort'}
        ];
        btnToTop = false;
      }
      Provider.of<UserStateProvide>(context, listen: false)
          .setDisabledPostList();
      Provider.of<UserStateProvide>(context, listen: false)
          .setDisabledUserList();

      if (showZanData) showZanData = false;
      getDatas('refresh');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        backgroundColor: Theme.of(context).backgroundColor,
        // body: !noNet
        //     ?
        body: Stack(
          children: [
            Container(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  // print('滚动方向');
                  // print(notification.metrics.pixels);
                  if (notification.metrics.axisDirection.toString() ==
                      'AxisDirection.down') {
                    if (notification.metrics.pixels > 100) {
                      if (notification is ScrollStartNotification) {
                        if (isEnd) {
                          setState(() {
                            startPointer = notification.metrics.pixels;
                          });
                          // print('滚动开始');
                        }
                      }
                      if (notification is ScrollUpdateNotification) {
                        if (isEnd) {
                          if (notification.metrics.pixels > 0 &&
                              (notification.metrics.pixels - startPointer >
                                  0)) {
                            setState(() {
                              isShowTop = false;
                              isEnd = false;
                            });
                          } else if (notification.scrollDelta < -15) {
                            setState(() {
                              isShowTop = true;
                              isEnd = false;
                            });
                          }

                          // print('滚动中');
                        }
                      }
                      if (notification is ScrollEndNotification) {
                        setState(() {
                          isEnd = true;
                          if (notification.metrics.pixels < 100) {
                            isShowTop = false;
                          }
                        });
                        // print('停止滚动');
                      }
                    } else {
                      if (isShowTop) {
                        setState(() {
                          isShowTop = false;
                        });
                      }
                    }

                    if (notification is ScrollEndNotification) {
                      if (_scrollController.position.extentAfter < 300) {
                        print('滚动到底部');
                        if (canload) {
                          print('滚动到底部------------------开始加载');

                          setState(() {
                            canload = false;
                          });
                          getDatas('');
                        }
                      }
                    }
                  }

                  if (canRefresh) {
                    if (notification.metrics.pixels < -50) {
                      print('滚动到头部');
                      print(notification.metrics.axisDirection.toString());

                      setState(() {
                        canRefresh = false;
                      });
                      refreshData();
                    }
                  } else {
                    widget.showLoading(true);
                    Future.delayed(Duration(milliseconds: 1000)).then((e) {
                      widget.showLoading(false);
                    });
                  }

                  return true;
                },
                child: Consumer<UserStateProvide>(
                  builder: (context, user, child) {
                    if (user.doubleTap == true) {
                      Future.delayed(Duration(milliseconds: 200)).then((e) {
                        _scrollController.position.moveTo(0);
                        Provider.of<UserStateProvide>(context, listen: false)
                            .setDoubleTap(false);
                      });
                    }

                    return ListView.builder(
                      primary: false,
                      cacheExtent: 1000,
                      controller: _scrollController,
                      itemBuilder: (c, i) {
                        if (i == 0) {
                          return Container(
                            // color: Colors.red,
                            height: ScreenUtil().setWidth(124),
                            margin: EdgeInsets.only(
                              top: 43,
                              left: 5,
                              right: 5,
                              bottom: 5,
                            ),
                            child: Consumer<UserStateProvide>(
                              builder: (
                                BuildContext context,
                                UserStateProvide user,
                                Widget child,
                              ) {
                                return ListView.builder(
                                  itemCount: user.looksList.length,
                                  itemExtent: ScreenUtil().setWidth(118),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      child: InkWell(
                                        onTap: () {
                                          if (user.looksList[index]['value'] != 'all' &&
                                              user.looksList[index]['value'] != 'recommend' &&
                                              user.looksList[index]['value'] != 'focused') {
                                            Navigator.pushNamed(
                                              context, '/forumpage',
                                              arguments: {
                                                "forumId": user.looksList[index]
                                                        ['value']
                                                    .toString()
                                              },
                                            );
                                          } else if (user.looksList[index]['value'] == 'all') {
                                            Navigator.pushNamed(context, '/allpage',);
                                          } else if (user.looksList[index]['value'] == 'recommend') {
                                            Navigator.pushNamed(context, '/recommendpage',);
                                          } else if (user.looksList[index]['value'] == 'focused') {
                                            Navigator.pushNamed(
                                              context,
                                              '/focusedpage',
                                            );
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: user.looksList[index]['value'] == 'all' || user.looksList[index]['value'] == 'recommend' || user.looksList[index]['value'] == 'focused'
                                                  ? Image.asset(
                                                      user.looksList[index]['icon'],
                                                      width: ScreenUtil().setWidth(80),
                                                      height: ScreenUtil().setWidth(80),
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: user.looksList[index]['icon'],
                                                      width: ScreenUtil().setWidth(80),
                                                      height: ScreenUtil().setWidth(80),
                                                    ),
                                            ),
                                            Text(
                                              user.looksList[index]['label'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: ScreenUtil().setSp(26),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        } else if (i == 1) {
                          var hasNetWork = Provider.of<UserStateProvide>(context, listen: false).hasNetWork;
                          return Column(
                            children: [
                              sortCell(),
                              isLoading && hasNetWork
                                  ? Container(
                                      height: ScreenUtil().setHeight(900),
                                      // child: LoadingWidget(),
                                      child: Text(
                                        'LOADING...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      alignment: Alignment.center,
                                    )
                                  : (hasNetWork &&
                                          !isLoading &&
                                          pageData.length == 2
                                      // ? nodataCell()
                                      ? Container(
                                          height: ScreenUtil().setWidth(900),
                                          alignment: Alignment.center,
                                          // color: Colors.grey,
                                          child: AddForumWidget(callBack: () {
                                            setState(() {
                                              params['key'] = '';
                                              params['marker'] = '';
                                            });
                                            getDatas('addForum');
                                          }),
                                        )
                                      : Container(
                                          height: 0,
                                        )),
                            ],
                          );
                        } else {
                          String modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
                          if (modelType == 'model3') {
                            // 瀑布流模式
                            if (i % 2 == 1) {
                              return Container(height: 2,);
                            } else {
                              return FlowIndexWidget(
                                item1: pageData[i],
                                item2: i == pageData.length - 1? null : pageData[i+1],
                                type: 'forum',
                                isComment: params['order'] == 'comment',
                              );
                            }
                          } else {
                            return ItemIndex(
                              item: pageData[i],
                              type: 'forum',
                              isComment: params['order'] == 'comment',
                            );
                          }
                        }
                      },
                      // itemExtent: 100.0,
                      itemCount: pageData.length,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 38,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).backgroundColor,
                height: isShowTop ? ScreenUtil().setWidth(138) : 1,
                padding: EdgeInsets.only(
                  top: ScreenUtil().setWidth(10),
                  left: 5,
                  right: 5,
                  bottom: ScreenUtil().setWidth(10),
                ),
                child: Consumer<UserStateProvide>(
                  builder: (BuildContext context, UserStateProvide user,
                      Widget child) {
                    return ListView.builder(
                      itemCount: user.looksList.length,
                      itemExtent: ScreenUtil().setWidth(118),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return AnimatedOpacity(
                          // 使用一个AnimatedOpacity Widget
                          opacity: isShowTop ? 1 : 0,
                          duration: new Duration(milliseconds: 500), //过渡时间：1
                          child: Container(
                            child: InkWell(
                              onTap: () {
                                print('[[[[[[[[[[[[[[[[[[[[[');
                                print(user.looksList[index]['value']);
                                if (user.looksList[index]['value'] != 'all' &&
                                    user.looksList[index]['value'] !=
                                        'recommend' &&
                                    user.looksList[index]['value'] !=
                                        'focused') {
                                  Navigator.pushNamed(
                                    context,
                                    '/forumpage',
                                    arguments: {
                                      "forumId": user.looksList[index]['value']
                                          .toString()
                                    },
                                  );
                                } else if (user.looksList[index]['value'] ==
                                    'all') {
                                  Navigator.pushNamed(
                                    context,
                                    '/allpage',
                                  );
                                } else if (user.looksList[index]['value'] ==
                                    'recommend') {
                                  Navigator.pushNamed(
                                    context,
                                    '/recommendpage',
                                  );
                                } else if (user.looksList[index]['value'] ==
                                    'focused') {
                                  Navigator.pushNamed(
                                    context,
                                    '/focusedpage',
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: user.looksList[index]['value'] ==
                                                'all' ||
                                            user.looksList[index]['value'] ==
                                                'recommend' ||
                                            user.looksList[index]['value'] ==
                                                'focused'
                                        ? Image.asset(
                                            user.looksList[index]['icon'],
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setWidth(80),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: user.looksList[index]
                                                ['icon'],
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setWidth(80),
                                          ),
                                  ),
                                  Text(
                                    user.looksList[index]['label'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(26),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        )
        // : NoNetWorkPage(
        //     callBack: (context) {
        //       setState(() {
        //         isLoading = true;
        //         // noNet = false;
        //       });
        //       _onRefresh();
        //     },
        //   ),
        );
  }

  _createGridViewItem(Color color) {
    return Container(
      height: 80,
      color: color,
    );
  }

  Widget nodataCell() {
    return Container(
      padding: EdgeInsets.only(top: 0),
      alignment: Alignment.center,
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('你还没有加入版块\n或暂时没有数据哦~\n加入后需等待2-3分钟数据处理'),
          SizedBox(
            width: 10,
          ),
          MaterialButton(
            elevation: 0,
            color: Colors.white,
            textColor: Colors.black,
            child: new Text('去添加'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: KColor.defaultBorderColor),
            ),
            onPressed: () async {
              Provider.of<CurrentIndexProvide>(context, listen: false)
                  .currentIndex = 1;
            },
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
                                  isLoading = true;
                                  showZanData = false;
                                  pageData = [
                                    {'name': 'nav'},
                                    {'name': 'sort'},
                                  ];
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
                              isLoading = true;
                              pageData = [
                                {'name': 'nav'},
                                {'name': 'sort'},
                              ];
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

  sortname() {
    if (params['order'] == 'new') {
      return '最新';
    } else if (params['order'] == 'hot') {
      return '最热';
    } else if (params['order'] == 'comment') {
      return '新评';
    }
  }
}

Widget getModel(BuildContext context) {

  String modelType = Provider.of<UserStateProvide>(context, listen: false).modelType;
  if (modelType == 'model1') {
   return Image.asset('assets/images/_icon/mode_1.png',
        width: ScreenUtil().setWidth(44),
    );
  } else if (modelType == 'model2') {
    return Image.asset('assets/images/_icon/mode_2.png',
      width: ScreenUtil().setWidth(44),);
  } else {
    return Image.asset('assets/images/_icon/mode_3.png',width: ScreenUtil().setWidth(44),);
  }
}
