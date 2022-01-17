import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/forum/forum_apply_page.dart';
import 'package:flutter_chaofan/pages/forum/mod_apply_page.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchResultPage extends StatefulWidget {
  var arguments;
  SearchResultPage({Key key, this.arguments}) : super(key: key);
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  TextEditingController _inputController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  bool showPickUp = false;
  bool showSearch = false;
  bool canload = true;
  bool isLoading = true;
  String inputValue = '';
  int curTab = 0;
  ScrollController _scrollController;
  List<Map> _recordList = [
    {"label": "百度一下", "value": "123"},
    {"label": "京东购物", "value": "123"},
    {"label": "百度一下", "value": "123"},
    {"label": "京东购物", "value": "123"},
    {"label": "百度一下", "value": "123"},
  ];
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

  List<Map> navData = [
    {'label': '帖子', 'value': 0},
    {'label': '版块', 'value': 1},
    // {'label': '帖子', 'value': 0},
    {'label': '用户', 'value': 2},
  ];

  var params = {"pageNum": 1, "keyword": '', "order": 'hot', "range": "1hour"};
  List<Map> pageData = [];
  @override
  void initState() {
    params['keyword'] = widget.arguments['keyword'];
    if (widget.arguments['forumId'] != null) {
      params['forumId'] = widget.arguments['forumId'];
    }
    getDatas('');
    super.initState();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    print('88888888888888888888888888888888888888');
    await Future.delayed(Duration(milliseconds: 1000));
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
    _refreshController.loadComplete();
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      params['key'] = '';
      // if (btnToTop) {
      pageData = [
        {'name': 'sort'}
      ];
      getDatas('refresh');
    });
  }

  void getDatas(type) async {
    // if (canload) {
    var data;
    if (curTab == 0) {
      data = await HttpUtil().get(Api.searchPost, parameters: params);
    } else if (curTab == 1) {
      data = await HttpUtil().get(Api.searchForum, parameters: params);
    } else if (curTab == 2) {
      data = await HttpUtil().get(Api.searchUser, parameters: params);
      data = data['data'];
    }

    // response = response['data'];
    print('9876');
    print(data);
    List<Map> res;
    res = (data['data'] as List).cast();

    int num = params['pageNum'];
    setState(() {
      isLoading = false;
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      showSearch = false;
      if (res.length == 0) {
        canload = false;
      } else {
        canload = true;
        params['pageNum'] = num + 1;
      }
    });
    // }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (!showPickUp) {
        //   setState(() {
        //     showPickUp = false;
        //   });
        //   _focusNode.unfocus();
        // }
      },
      child: Scaffold(
        //MediaQueryData.fromWindow(window).padding.top
        body: Stack(
          children: [
            !(isLoading && pageData.length == 0)
                ? SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: true,
                    header: WaterDropHeader(
                      complete: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        child: Text(
                          "加载完成",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      refresh: Container(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setWidth(100)),
                        child: CupertinoActivityIndicator(
                          //CupertinoActivityIndicator
                          radius: 10,
                        ),
                      ),
                    ),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Container(
                            // padding: EdgeInsets.only(
                            //   top: MediaQuery.of(context).padding.top,
                            // ),
                            child: Text(
                              "加载完成",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        } else if (mode == LoadStatus.loading) {
                          body = BallSpinFadeLoaderIndicator(
                              //BallSpinFadeLoaderIndicator
                              ballColor: Colors.grey,
                              radius: 10);
                        } else if (mode == LoadStatus.failed) {
                          body = Text("Load Failed!Click retry!");
                        } else if (mode == LoadStatus.canLoading) {
                          body = Text("release to load more");
                        } else {
                          body = Text("No more Data");
                        }
                        return Container(
                          height: 40.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading, //sortCell(),
                    child: pageData.length != 0
                        ? ListView.builder(
                            itemBuilder: (c, i) {
                              if (i == 0) {
                                return Container(
                                  color: Colors.white,
                                  height: widget.arguments['forumId'] == null
                                      ? ScreenUtil().setWidth(230)
                                      : ScreenUtil().setWidth(150),
                                  // margin: EdgeInsets.only(bottom: 5),
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(140)),
                                );
                              } else {
                                if (curTab == 0) {
                                  return ItemIndex(
                                      item: pageData[i - 1], type: 'forum');
                                } else if (curTab == 1) {
                                  return itemForum(pageData[i - 1]);
                                } else {
                                  return _itemUser(pageData[i - 1]);
                                }
                              }
                            },
                            itemCount: pageData.length + 1,
                          )
                        : ListView(
                            children: [
                              Container(
                                color: Colors.white,
                                height: widget.arguments['forumId'] == null
                                    ? ScreenUtil().setWidth(224)
                                    : ScreenUtil().setWidth(144),
                                margin: EdgeInsets.only(bottom: 5),
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setWidth(140)),
                                // child: _tabNav(),
                              ),
                              Container(
                                height: ScreenUtil().setHeight(450),
                                alignment: Alignment.bottomCenter,
                                child: Image.asset(
                                  'assets/images/_icon/nocontent.png',
                                  width: 150,
                                ),
                              ),
                              Container(
                                height: ScreenUtil().setWidth(120),
                                alignment: Alignment.center,
                                child: Text(
                                  '搜索结果为空~',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              curTab == 1 ?  MaterialButton(
                                // color: Color.fromRGBO(255, 147, 0, 1),
                                // textColor: Colors.white,
                                child: new Text(
                                  '暂无该版块，点击新建',
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
                                        return new ForumApplyPage(forumName: params['keyword'],);
                                      })).then((String result) {
                                  });
                                },) : Text("")
                            ],
                          ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(254, 149, 0, 100)),
                    ),
                  ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: ScreenUtil().setWidth(750),
                color: Colors.white,
                height: widget.arguments['forumId'] == null
                    ? ScreenUtil().setWidth(228)
                    : ScreenUtil().setWidth(140),
                padding: EdgeInsets.only(
                  top: MediaQueryData.fromWindow(window).padding.top + 5,
                  // bottom: ScreenUtil().setWidth(10),
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20),
                ),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                alignment: Alignment.centerLeft,
                                color: Color(0x30cccccc),
                                height: ScreenUtil().setWidth(60),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        params['keyword'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: ScreenUtil().setWidth(80),
                            alignment: Alignment.center,
                            child: Text(
                              '取消',
                              style: TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.arguments['forumId'] == null
                        ? Container(
                            color: Colors.white,
                            height: ScreenUtil().setWidth(90),
                            // margin: EdgeInsets.only(bottom: 5),
                            // padding: EdgeInsets.only(top: ScreenUtil().setWidth(140)),
                            child: _tabNav(),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            showPickUp
                ? Positioned(
                    right: 10,
                    bottom: 0,
                    child: MaterialButton(
                      color: Colors.white,
                      textColor: Colors.grey,
                      child: new Text('收起'),
                      minWidth: ScreenUtil().setWidth(100),
                      height: ScreenUtil().setWidth(50),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        // side: BorderSide(
                        //   color: forumData['joined']
                        //       ? Colors.white
                        //       : Color.fromRGBO(255, 147, 0, 1),
                        // ),
                      ),
                      onPressed: () async {
                        setState(() {
                          showPickUp = false;
                        });
                        _focusNode.unfocus();
                        // setState(() {
                        //   showPickUp = false;
                        // });
                      },
                    ),
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _tabNav() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              curTab = index;
              isLoading = true;
              pageData = [];
              params['pageNum'] = 1;
            });
            getDatas('');
          },
          child: Container(
            height: ScreenUtil().setWidth(80),
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(50),
              right: ScreenUtil().setWidth(50),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 6,
                  color: curTab == index
                      ? Color.fromRGBO(255, 147, 0, 1)
                      : Colors.transparent,
                ),
              ),
            ),
            child: Text(
              navData[index]['label'],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.bold,
                color: curTab == index
                    ? Color.fromRGBO(33, 29, 47, 1)
                    : Color.fromRGBO(33, 29, 47, 0.5),
              ),
            ),
          ),
        );
      },
      itemExtent: ScreenUtil().setWidth(240),
      itemCount: navData.length,
    );
  }

  Widget _itemUser(item) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/userMemberPage',
          arguments: {"userId": item['userId'].toString()},
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        height: 80,
        color: Colors.white,
        child: ListTile(
          leading: Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                KSet.imgOrigin +
                    item['icon'] +
                    '?x-oss-process=image/resize,h_80',
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Text(item['userName']),
          subtitle: Text(
              // item['desc'] != null ? item['desc'] : 'Ta有点懒，居然不设置个性签名~',
              '获赞：' + item['ups'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          isThreeLine: false,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: KColor.defaultBorderColor,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget itemForum(item) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/forumpage',
          arguments: {
            "forumId": item['id'].toString()
          },
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        height: 80,
        color: Colors.white,
        child: ListTile(
          leading: Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                KSet.imgOrigin +
                    item['imageName'] +
                    '?x-oss-process=image/resize,h_80',
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Text(item['name']),
          subtitle: Text(
            // item['desc'] != null ? item['desc'] : 'Ta有点懒，居然不设置个性签名~',
              '帖子数量：' + item['posts'].toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          isThreeLine: false,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: KColor.defaultBorderColor,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _hotPost() {
    return Container(
      margin: EdgeInsets.only(left: 15),
      padding: EdgeInsets.only(top: 15),
      child: ListView.builder(
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        itemBuilder: (c, i) {
          if (i == 0) {
            return Container(
              child: Text(
                '今日热门',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/_icon/search_icon.png',
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                      ),
                      SizedBox(width: 10),
                      Text('人人影视'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                    '本周网易云音乐与酷狗音乐之间的争论成为业界关注的焦点。 近日网易云音乐在官…'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
        itemCount: _recordList.length + 1,
      ),
    );
  }

  Widget _recordItem(item) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/_icon/record.png',
            width: ScreenUtil().setWidth(34),
            height: ScreenUtil().setWidth(34),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(item['label']),
            ),
          ),
          Icon(
            Icons.close,
            size: 20,
            color: Color.fromRGBO(153, 153, 153, 1),
          ),
        ],
      ),
    );
  }
}
