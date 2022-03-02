import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:provider/provider.dart';

class ForumListPage extends StatefulWidget {
  var callBack;
  ForumListPage({Key key, this.callBack}) : super(key: key);
  _ForumListPageState createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  List<Map> allForum;
  List<Map> beiData;

  TextEditingController _inputController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTag();
  }

  void getTag() async {
    var data =
        await HttpUtil().get(Api.ListForumsByTag, parameters: {'tagId': 0});
    setState(() {
      allForum = (data['data'] as List).cast();
      beiData = allForum;
    });
  }

  void filterData() async {
    var keyword = _inputController.text.trim();
    List<Map> a = [];
    beiData.forEach((element) {
      if (element['name'].contains(keyword)) {
        print('包含了$keyword');
        print(element);
        a.add(element);
      }
    });
    setState(() {
      // allForum.clear();
      // allForum.addAll(a);
      allForum = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserStateProvide>(context, listen: false)
        .getRemmenberForumList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(
              color: KColor.defaultGrayColor, //修改颜色
              size: 10),
          title: Text(
            '选择版块',
            style: TextStyle(
              color: Colors.black,
              fontSize: ScreenUtil().setSp(34),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        preferredSize: Size.fromHeight(60),
      ),
      // appBar: AppBar(
      //   brightness: Brightness.light,
      //   iconTheme: IconThemeData(
      //       // color: KColor.defaultGrayColor, //修改颜色
      //       size: 14),
      //   title: Text(
      //     '选择版块',
      //     style:
      //         TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(34)),
      //   ),
      //   backgroundColor: Colors.white,
      //   // bottomOpacity: 0,
      //   elevation: 0, //头部阴影区域高度rr
      // ),
      body: Stack(
        children: <Widget>[
          allForum != null
              ? Container(
                  height: double.infinity,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Stack(
                    children: [
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: allForum.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: ScreenUtil().setWidth(60),
                                  maxWidth: ScreenUtil().setWidth(750),
                                ),
                                child: TextField(
                                  // focusNode: _focusNode,
                                  controller: _inputController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 0, top: 0, right: 10, bottom: 0),
                                    fillColor: Color(0x30cccccc),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0x00FF0000)),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50))),
                                    hintText: '请输入搜索内容',
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      color: Color.fromRGBO(153, 153, 153, 1),
                                    ),
                                    prefixIcon: Icon(Icons.search),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0x00000000)),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50))),
                                  ),
                                  onChanged: (value) {
                                    print('onChanged:$value');
                                    if (value.trim().isEmpty) {
                                      setState(() {
                                        allForum = beiData;
                                      });
                                    } else {
                                      filterData();
                                    }

                                    // setState(() {
                                    //   inputValue = value;
                                    // });
                                  },
                                  onEditingComplete: () {
                                    print('onEditingComplete');
                                  },
                                  onTap: () {
                                    // FocusScope.of(context).requestFocus(_focusNode);
                                  },
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      // Provider.of<UserStateProvide>(context, listen: false)
                                      //     .addSearchHistory(inputValue.trim());
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   '/searchResultPage',
                                      //   arguments: {"keyword": inputValue.trim()},
                                      // );
                                    }
                                  },
                                ),
                              ),
                            );
                          } else if (index == 1) {
                            return _topSearch();
                          } else {
                            return InkWell(
                              onTap: () {
                                var str = allForum[index - 2]['id'].toString() +
                                    '|' +
                                    allForum[index - 2]['name'] +
                                    '|' +
                                    allForum[index - 2]['imageName'];
                                if (widget.callBack == null) {
                                  Navigator.of(context).pushReplacementNamed(
                                      '/submitpage',
                                      arguments: {'str': str});
                                  // Navigator.pushNamed(context, '/submitpage',
                                  //     arguments: {'str': str});
                                } else {
                                  widget.callBack(str);
                                }
                              },
                              child: _rightItem(allForum[index - 2], index - 2),
                            );
                          }
                        },
                      ),
                    ],
                  ), //传入一级分类下标
                )
              : Container(
                  height: 0,
                ),
        ],
      ),
    );
  }

  var d = [
    {
      "label": '全网热门',
      "icon": '',
      "id": '',
    },
    {
      "label": '全网热门',
      "icon": '',
      "id": '',
    },
    {
      "label": '全网热门全网',
      "icon": '',
      "id": '',
    },
    {
      "label": '无聊图',
      "icon": '',
      "id": '',
    },
    {
      "label": '全网热门',
      "icon": '',
      "id": '',
    },
    {
      "label": '风景',
      "icon": '',
      "id": '',
    },
  ];
  Widget _topSearch() {
    if ((_inputController.text.trim().isEmpty)) {
      return Consumer<UserStateProvide>(
        builder: (BuildContext context, UserStateProvide user, Widget child) {
          if (user.remmenberForumList.length > 0) {
            return Container(
              // color: Colors.blue,
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '最近发布版块',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(750),
                    // color: Colors.black,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 5,
                      spacing: 10,
                      children: user.remmenberForumList.map((f) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () {
                              var str = f['id'].toString() +
                                  '|' +
                                  f['name'] +
                                  '|' +
                                  f['imageName'];
                              if (widget.callBack == null) {
                                // Navigator.pop(context, str);
                                Navigator.of(context).pushReplacementNamed(
                                    '/submitpage',
                                    arguments: {'str': str});
                                // Navigator.pushNamed(context, '/submitpage',
                                //     arguments: {'str': str});
                              } else {
                                widget.callBack(str);
                              }
                            },
                            child: Container(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Row(
                                children: [
                                  Image.network(
                                    KSet.imgOrigin +
                                        f['imageName'] +
                                        '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(f['name']),
                                  Expanded(
                                    child: Text(''),
                                    flex: 1,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              height: 0,
              // color: Colors.blue,
            );
          }
        },
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _rightItem(item, index) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: CachedNetworkImage(
                imageUrl: KSet.imgOrigin +
                    item['imageName'] +
                    '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setWidth(60),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(20),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['name'],
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(30),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: item['desc'] != null
                      ? Text(
                          item['desc'] != null ? item['desc'] : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: KColor.defaultGrayColor,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  '选择',
                  style: TextStyle(color: Colors.grey),
                ),
                alignment: Alignment.center,
              )),
        ],
      ),
    );
  }
}
