import 'dart:convert';

import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chaofan/database/addjoinhelper.dart';

class AddJoinPage extends StatefulWidget {
  _AddJoinPageState createState() => _AddJoinPageState();
  // State<StatefulWidget> createState() => _DiscoverPageState();
}

class _AddJoinPageState extends State<AddJoinPage> {
  // @override
  // bool get wantKeepAlive => true;
  List pageData = [
    {'label': '已加入的版块', 'value': 1, 'expended': true, 'children': []},
    {'label': '已关注的用户', 'value': 1, 'expended': true, 'children': []},
  ];
  var db = AddJoinHelper();
  getDatas() async {
    var response = await HttpUtil().get(Api.listJoinedForums);
    response = response['data'];

    // setState(() {
    //   pageData[0]['children'] = response;
    // });
    // response.forEach((item) {
    //   List<Map> newGoodsList = (item['menues'] as List).cast();
    //   setState(() {
    //     navDataList.addAll(newGoodsList);
    //   });
    // });
  }

  var homeFuture;
  List A;
  List B;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDB();
    homeFuture = HomeService().listFocusForum({}, (response) {
      var data = response;
      setState(() {
        // pageData[0]['children'] = (data[0] as List).cast();
        // pageData[1]['children'] = (data[1] as List).cast();
        A = (data[0] as List).cast();
        B = (data[1] as List).cast();
      });
      _saveDB();
      // try {//jsonDecode(response.data)
      //   pageData = (data['posts'] as List).cast();
      // } catch (e) {}
    }, (message) {
      print(message);
    });
    // getDatas();
  }

  _saveDB() async {
    await db.clear();
    await db.saveItem(jsonEncode(A), jsonEncode(B));
  }

  _getDB() async {
    var a = await db.getTotalList();
    print('获取用户db');
    print(a);
    if (a != null && a.length != 0) {
      setState(() {
        A = jsonDecode(a[0]['addForum']);
        B = jsonDecode(a[0]['focusUser']);
      });
    }
  }

  // ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      // controller: _scrollController,
      child: FutureBuilder(
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
                return SingleChildScrollView(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      children: [
                        _title(pageData[0], 0),
                        pageData[0]['expended']
                            ? forumList()
                            : Container(height: 0),
                        _title(pageData[1], 1),
                        pageData[1]['expended']
                            ? userList()
                            : Container(height: 0),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget _title(item, index) {
    return InkWell(
      onTap: () {
        setState(() {
          // if (index == 0) {
          pageData[index]['expended'] = !item['expended'];
          // }else{}
        });
      },
      child: Container(
        color: Color.fromRGBO(244, 244, 244, 1),
        height: 40,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            // Icon(Icons.arrow_drop_down_rounded),
            item['expended']
                ? Icon(Icons.arrow_drop_down_rounded)
                : Icon(Icons.arrow_right_rounded),
            Text(
              item['label'],
              style: TextStyle(
                color: Color.fromRGBO(33, 29, 47, 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forumList() {
    if (A.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: A.map((e) {
            return Container(
              height: ScreenUtil().setWidth(110),
              alignment: Alignment.centerLeft,
              // margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/forumpage',
                        arguments: {"forumId": e['id'].toString()},
                      );
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(64),
                      height: ScreenUtil().setWidth(64),
                      margin: EdgeInsets.only(
                        right: 8,
                        left: 10,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: KSet.imgOrigin +
                              e['imageName'] +
                              '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Image.asset("assets/images/img/place.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/forumpage',
                          arguments: {"forumId": e['id'].toString()},
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                e['name'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '帖子数量: ' + _doPostCount(e['posts']),
                                style: TextStyle(
                                  color: KColor.defaultPlaceColor,
                                  fontSize: ScreenUtil().setSp(26),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   width: ScreenUtil().setWidth(80),
                  //   alignment: Alignment.center,
                  //   child: InkWell(
                  //     onTap: () {},
                  //     child: Image.asset(
                  //       'assets/images/_icon/push_forum_icon.png',
                  //       width: ScreenUtil().setWidth(50),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return _nothing('还没有加入任何版块哦~');
    }
  }

  String _doPostCount(v) {
    if (v > 10000 || v == 10000) {
      return (v / 10000).toStringAsFixed(2).toString() + 'w';
    } else {
      return v.toString();
    }
  }

  Widget userList() {
    if (B.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: B.map((e) {
            return Container(
              height: 54,
              alignment: Alignment.centerLeft,
              // margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/userMemberPage',
                    arguments: {"userId": e['userId'].toString()},
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(
                        right: 8,
                        left: 10,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: KSet.imgOrigin +
                              e['icon'] +
                              '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Image.asset("assets/images/img/place.png"),
                          ),
                        ),
                        // child: Image.network(
                        //   KSet.imgOrigin +
                        //       e['icon'] +
                        //       '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                        //   width: 30,
                        //   height: 30,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                e['userName'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(30),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '获赞:' + e['ups'].toString(),
                                style: TextStyle(
                                  color: KColor.defaultPlaceColor,
                                  fontSize: ScreenUtil().setSp(24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return _nothing('还没有关注感兴趣的人哦~');
    }
  }


  Widget _nothing(text) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: KColor.defaultPlaceColor,
        ),
      ),
    );
  }
}
