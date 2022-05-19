import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  var arguments;
  SearchPage({Key key, this.arguments}) : super(key: key);
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _inputController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  // bool showPickUp = true;
  bool showSearch = true;
  bool canload = true;
  String inputValue = '';
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

  var params = {"pageNum": 1, "keyword": '', "order": 'hot', "range": "1hour"};
  List<Map> pageData = [];
  @override
  void initState() {
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
    await Future.delayed(Duration(milliseconds: 1000));
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
    params['keyword'] = inputValue;
    var data = await HttpUtil().get(Api.searchPost, parameters: params);
    // response = response['data'];
    print(data);
    List<Map> res = (data['data'] as List).cast();
    int num = params['pageNum'];
    setState(() {
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
        setState(() {
          // showPickUp = false;
          _focusNode.unfocus();
        });
      },
      child: Scaffold(
        //MediaQueryData.fromWindow(window).padding.top
        body: Stack(
          children: [
            (showSearch)
                ? Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(150)),
                    height: ScreenUtil().setHeight(1334),
                    child: ListView(
                      shrinkWrap: true,
                      controller: _scrollController,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Consumer<UserStateProvide>(builder:
                            (BuildContext context, UserStateProvide user,
                                Widget child) {
                          if (user.searchHistory.length > 0) {
                            return ListView(
                              controller: _scrollController,
                              shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
                              physics: NeverScrollableScrollPhysics(), //禁用滑动事件
                              children: user.searchHistory.map((e) {
                                return _recordItem(e);
                              }).toList(),
                            );
                          } else {
                            return Container(
                              height: 190,
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                '暂无搜索记录',
                                style: TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(28)),
                              ),
                            );
                          }
                        }),

                        SizedBox(height: 5),

                        Container(
                          height: 10,
                          color: Color.fromRGBO(250, 250, 250, 1),
                        ),
                        InkWell(
                          onTap: () {
                            Provider.of<UserStateProvide>(context,
                                    listen: false)
                                .removeSharedPreferences('searchHistory');
                            Provider.of<UserStateProvide>(context,
                                    listen: false)
                                .setSearchHistory();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: Text(
                              '清除全部记录',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil().setSp(26),
                              ),
                            ),
                          ),
                        ),
                        // _hotPost(),
                      ],
                    ),
                  )
                : SmartRefresher(
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
                    child: ListView.builder(
                      itemBuilder: (c, i) {
                        if (i == 0) {
                          return Container(height: ScreenUtil().setWidth(200));
                        } else {
                          return ItemIndex(
                              item: pageData[i - 1], type: 'forum');
                        }
                      },
                      itemCount: pageData.length + 1,
                    ),
                  ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: ScreenUtil().setWidth(750),
                color: Colors.white,
                height: ScreenUtil().setWidth(220),
                padding: EdgeInsets.only(
                  top: MediaQueryData.fromWindow(window).padding.top + 5,
                  bottom: ScreenUtil().setWidth(10),
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20),
                ),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    widget.arguments['forumData'] == null
                        ? Container(
                            // width: 60,
                            height: ScreenUtil().setWidth(60),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/_icon/logo.png',
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '全站',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            height: ScreenUtil().setWidth(60),
                            // width: 60,
                            child: Row(
                              children: [
                                Image.network(
                                  KSet.imgOrigin +
                                      widget.arguments['forumData']
                                          ['imageName'] +
                                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                                  width: 20,
                                  // height: 20,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  // width: 38,
                                  child: Text(
                                    widget.arguments['forumData']['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: ScreenUtil().setWidth(4),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: ScreenUtil().setWidth(60),
                              maxWidth: ScreenUtil().setWidth(650),
                            ),
                            child: TextField(
                              focusNode: _focusNode,
                              autofocus: true,
                              controller: _inputController,
                              decoration: InputDecoration(
                                isDense: false,
                                contentPadding: EdgeInsets.only(
                                    left: 0, top: 0, right: 10, bottom: 0),
                                fillColor: Color(0x30cccccc),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0x00FF0000)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                hintText: '请输入搜索内容',
                                hintStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  color: Color.fromRGBO(153, 153, 153, 1),
                                ),
                                prefixIcon: Icon(Icons.search),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0x00000000)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                              ),
                              onChanged: (value) {
                                print('onChanged:$value');
                                setState(() {
                                  inputValue = value;
                                });
                              },
                              onEditingComplete: () {
                                print('onEditingComplete');
                              },
                              onTap: () {
                                // FocusScope.of(context).requestFocus(_focusNode);
                                setState(() {
                                  showSearch = true;
                                  // showPickUp = true;
                                });
                                FocusScope.of(context).requestFocus(_focusNode);
                                print('onTap');
                              },
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  Provider.of<UserStateProvide>(context,
                                          listen: false)
                                      .addSearchHistory(inputValue.trim());
                                  Navigator.pushNamed(
                                    context,
                                    '/searchResultPage',
                                    arguments: {
                                      "keyword": inputValue.trim(),
                                      'forumId':
                                          (widget.arguments['forumData'] != null
                                              ? widget.arguments['forumData']
                                                  ['id']
                                              : null)
                                    },
                                  );
                                }
                              },
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
                  ],
                ),
              ),
            ),
            // showPickUp
            //     ? Positioned(
            //         right: 10,
            //         bottom: 0,
            //         child: MaterialButton(
            //           color: Colors.white,
            //           textColor: Colors.grey,
            //           child: new Text('收起'),
            //           minWidth: ScreenUtil().setWidth(100),
            //           height: ScreenUtil().setWidth(50),
            //           padding: EdgeInsets.all(0),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(30.0),
            //           ),
            //           onPressed: () async {
            //             setState(() {
            //               showPickUp = false;
            //               _focusNode.unfocus();
            //             });

            //             // setState(() {
            //             //   showPickUp = false;
            //             // });
            //           },
            //         ),
            //       )
            //     : Container(
            //         height: 0,
            //       ),
          ],
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
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
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
            child: InkWell(
              onTap: () {
                // setState(() {
                //   inputValue = item;
                // });
                Navigator.pushNamed(
                  context,
                  '/searchResultPage',
                  arguments: {
                    "keyword": item,
                    "forumId": (widget.arguments['forumData'] != null
                        ? widget.arguments['forumData']['id']
                        : null)
                  },
                );
              },
              child: Container(
                alignment: Alignment.centerLeft,
                height: ScreenUtil().setWidth(60),
                // color: Colors.green,
                child: Text(
                  item,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color.fromRGBO(33, 29, 47, 0.7),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Provider.of<UserStateProvide>(context, listen: false)
                  .delSearchHistory(item);
            },
            child: Container(
              width: ScreenUtil().setWidth(50),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 20,
                color: Color.fromRGBO(200, 200, 200, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
