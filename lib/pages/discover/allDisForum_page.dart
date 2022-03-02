import 'package:flutter_chaofan/database/model/forumDB.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/discover_service.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chaofan/database/allforumhelper.dart';

class AllDiscoverPage extends StatefulWidget {
  _AllDiscoverPageState createState() => _AllDiscoverPageState();
  // State<StatefulWidget> createState() => _AllDiscoverPageState();
}

class _AllDiscoverPageState extends State<AllDiscoverPage>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin
  // 防止刷新处理 保持状态
  List<Map> allCates = [];
  List<Map> allForum = [];
  List<Map> speForum = [];
  List<Map> allForumCopy = [];
  bool ifAll = true;
  var params2 = {"tagId": 0};
  int page = 1;

  var params = {"pageSize": '20', "marker": '', "order": 'new'};
  List<Map> pageData = [];
  var homeFuture;
  HomeService homeService = HomeService();

  var cateFuture;
  DiscoverService discoverService = DiscoverService();

  var db = AllForumHelper();

  TextEditingController _inputController = TextEditingController();

  @override
  bool get wantKeepAlive => true;
  var btnToTop = false;

  String tabs = 'forum';
  FocusNode _focusNode = FocusNode();

  // 记录是否更新

  @override
  void initState() {
    super.initState();

    _getTagDB();

    // _getForumDB();
    cateFuture = discoverService.getListTags({}, (response2) {
      _clears();
      var data2 = response2;
      var data = (data2 as List).cast();
      allCates = (data[0] as List).cast();
      allForum = (data[1] as List).cast();
      allForumCopy = allForum;
      allCates.forEach((element) {
        print("---$element");
        _saveTagItem(element);
      });
      Future.delayed(Duration(milliseconds: 2000)).then((e) {
        allForum.forEach((element) {
          _saveForumDB(element);
        });
      });
    }, (message) {});
  }

  _clears() async {
    await db.clear();
  }

  // @override
  void getTag() async {
    var a = await db.getForumListByTag(params2['tagId']);

    print(a);
    if (a.length > 0) {
      setState(() {
        if (params2['tagId'] == 0) {
          ifAll = true;
        } else {
          ifAll = false;
          speForum = a.map((e) => getMap(e)).toList();
        }
      });
    } else {
      getTagOK();
    }
  }
  
  Map getMap(Map e) {
    var map = {};
    e.forEach((key, value) => map[key] = value);
    return map;
  }

  void getTagOK() async {
    var data = await HttpUtil().get(Api.ListForumsByTag, parameters: params2);
    setState(() {
      if (params2['tagId'] == 0) {
        ifAll = true;
        allForum = (data['data'] as List).cast();
      } else {
        ifAll = false;
        speForum = (data['data'] as List).cast();
      }
    });
  }

  @override
  void getCates() async {
    var data = await HttpUtil().get(Api.ListTags);
    setState(() {
      allCates = (data['data'] as List).cast();
    });
  }

  _saveTagItem(item) async {
    await db.saveTagItem(item);
  }

  _saveForumDB(item) async {
    if (item['joined']) {
      item['joined'] = 1;
    } else {
      item['joined'] = 0;
    }
    await db.saveForumItem(forumDB.fromJson(item));
  }

  _getTagDB() async {
    var a = await db.getTagList();
    if (mounted) {
      setState(() {
        allCates = a;
      });
    }

    _getForumDB();
  }

  _getForumDB() async {
    try {
      var a = await db.getForumList();
      if (mounted) {
        setState(() {
          allForum = a;
          allForumCopy = a;
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    // 记得销毁对象
    // _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      //防止刷新重绘
      future: cateFuture,
      builder: (context, AsyncSnapshot asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(254, 149, 0, 100)),
                ),
              ),
            );
          default:
            if (asyncSnapshot.hasError) {
              return new Text('error');
            } else {
              return SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: _forumRow(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        }
      },
    );
  }

  Widget _forumRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: allCates.length,
              itemBuilder: (context, index) {
                return _leftItem(allCates[index], index);
              },
            ),
          ),
        ),
        new Expanded(
          flex: 4,
          child: Container(
            height: double.infinity,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10, right: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: ifAll ? allForum.length + 1 : speForum.length,
              itemBuilder: (context, index) {
                if (ifAll) {
                  if (index == 0) {
                    return Container(
                      padding: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
                      constraints: BoxConstraints(
                        maxHeight: ScreenUtil().setWidth(70),
                        maxWidth: ScreenUtil().setWidth(750),
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        autofocus: false,
                        controller: _inputController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 0, top: 0, right: 10, bottom: 0),
                          fillColor: Color(0x30cccccc),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00FF0000)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          hintText: '请输入搜索内容',
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            color: Color.fromRGBO(153, 153, 153, 1),
                          ),
                          prefixIcon: Icon(Icons.search),
                          suffix: _inputController.text.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    _inputController.value =
                                        _inputController.value.copyWith(
                                      text: '',
                                      composing: TextRange.empty,
                                    );
                                    setState(() {
                                      allForum = allForumCopy;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                )
                              : Text(''),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00000000)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                        onChanged: (value) {
                          print('onChanged:$value');
                          if (value.trim().isNotEmpty) {
                            List<Map> arr = [];
                            allForumCopy.forEach((element) {
                              print(element['name']);
                              if (element['name'].contains(value)) {
                                arr.add(element);
                              }
                            });
                            setState(() {
                              allForum = arr;
                            });
                          } else {
                            setState(() {
                              allForum = allForumCopy;
                            });
                          }
                        },
                        onEditingComplete: () {
                          print('onEditingComplete');
                        },
                        onTap: () {
                          // FocusScope.of(context).requestFocus(_focusNode);
                        },
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {}
                        },
                      ),
                    );
                  }
                  return _rightItem(allForum[index - 1], index - 1);
                } else {
                  return _rightItem(speForum[index], index);
                }
              },
            ), //传入一级分类下标
          ),
        ),
      ],
    );
  }

  setSearch() {}

  Widget _secretRow() {
    return Container(
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Column(
        children: <Widget>[
          _chooseForum(),
          _title('标题'),
          _titleInput(),
        ],
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
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
      ),
    );
  }

  Widget _navWidget() {
    return Container(
      // height: ScreenUtil().setHeight(70),
      height: 45,
      padding: EdgeInsets.only(top: 0, left: 20),
      width: ScreenUtil().setWidth(720),
      // color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _navItem('全部版块', 'forum'),
          // _navItem('秘密花园', 'secret'),
        ],
      ),
    );
  }

  Widget _navItem(name, id) {
    return Container(
      width: ScreenUtil().setWidth(140),
      // height: ScreenUtil().setHeight(70),
      height: 45,
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(18)),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        // color: Colors.black12,
        border: Border(
          bottom: BorderSide(
            width: 4,
            color: tabs == id ? KColor.primaryColor : Colors.white,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            tabs = id;
          });
        },
        child: Text(
          name,
          style: tabs == id ? KFont.homeNavActStyle : KFont.homeNavStyle,
        ),
      ),
    );
  }

  Widget _leftItem(item, index) {
    return InkWell(
      onTap: () {
        // FocusScope.of(this.context).requestFocus(FocusNode());
        setState(() {
          params2['tagId'] = item['id'];
          print('tagId $item["id"]');
        });
        getTag();
      },
      child: Container(
        height: ScreenUtil().setWidth(80),
        alignment: Alignment.center,
        child: Text(
          item['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(30),
            color: params2['tagId'] == item['id']
                ? KColor.primaryColor
                : Colors.black,
            fontWeight: params2['tagId'] == item['id'] ? FontWeight.w600 : null,
          ),
        ),
      ),
    );
  }

  Widget _rightItem(item, index) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10),
          ScreenUtil().setWidth(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/forumpage',
            arguments: {"forumId": item['id'].toString()},
          );
        },
        child: Row(
          children: <Widget>[
            Container(
              // color: Colors.black,
              width: ScreenUtil().setWidth(70),
              height: ScreenUtil().setWidth(70),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: KSet.imgOrigin +
                      item['imageName'] +
                      '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                  width: ScreenUtil().setWidth(60),
                  height: ScreenUtil().setWidth(60),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(20),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        width: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setWidth(50),
                        child: MaterialButton(
                          color: item['joined'] != null &&
                                  (item['joined'] == 1 ||
                                      item['joined'] == true)
                              ? Color.fromRGBO(230, 230, 230, 1)
                              : Color.fromRGBO(255, 147, 0, 0.8),
                          textColor: Colors.white,
                          minWidth: ScreenUtil().setWidth(100),
                          height: ScreenUtil().setWidth(0),
                          elevation: 0,
                          child: Container(
                            // width: 30,
                            // height: 20,
                            alignment: Alignment.center,
                            child: Text(
                              item['joined'] != null &&
                                      (item['joined'] == 1 ||
                                          item['joined'] == true)
                                  ? '已加入'
                                  : '加入',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(25),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 0),
                          onPressed: () async {
                            if (Provider.of<UserStateProvide>(context,
                                    listen: false)
                                .ISLOGIN) {
                              bool joined;
                              if (item['joined'] == true ||
                                  item['joined'] == 1) {
                                joined = false;
                              } else {
                                joined = true;
                              }

                              var m;
                              if (ifAll) {
                                m = allForum;

                                // return _rightItem(allForum[index], index);
                              } else {
                                // return _rightItem(speForum[index], index);
                                m = speForum;
                              }
                              m[index]['joined'] = joined;
                              if (ifAll) {
                                setState(() {
                                  allForum = m;
                                });
                              } else {
                                setState(() {
                                  speForum = m;
                                });
                              }
                              if (joined) {
                                var response = await HttpUtil().get(
                                    Api.joinForum,
                                    parameters: {'forumId': item['id']});
                              } else {
                                var response = await HttpUtil().get(
                                    Api.leaveForum,
                                    parameters: {'forumId': item['id']});
                              }
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/accoutlogin',
                              );
                            }
                          },
                        ),
                      ),
                    ],
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
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _list() {
    // List<Widget> listWidget = hotGoodsList.map((val) {
    if (pageData.length != 0) {
      List<Map> arr = [];
      pageData.forEach((v) {
        if (v['type'] == 'image' || v['type'] == 'link') {
          arr.addAll([v]);
        }
      });
      List<Widget> listWidget = arr.map((item) {
        return SizedBox(
          height: 80.0, //设置高度
          child: new Card(
            elevation: 15.0, //设置阴影
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14.0))), //设置圆角
            child: new Column(
              // card只能有一个widget，但这个widget内容可以包含其他的widget
              children: [
                new ListTile(
                  title: new Text('版块名称',
                      style: new TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text('版块描述'),
                  leading: new Icon(
                    Icons.restaurant_menu,
                    color: Colors.blue[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
      return Column(
        children: listWidget,
      );
    }
  }
}
