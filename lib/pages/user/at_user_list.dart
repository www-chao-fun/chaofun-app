import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AtUserListPage extends StatefulWidget {
  Function callBackAt;
  AtUserListPage({Key key, this.callBackAt}) : super(key: key);
  _AtUserListPageState createState() => _AtUserListPageState();
}

class _AtUserListPageState extends State<AtUserListPage> {
  var params = {
    'keyword': '',
    'pageNum': '1',
  };
  TextEditingController _inputController = TextEditingController();
  var paramsFocus = {};
  List userList;
  List chooseList = [];
  List storageFocus = [];
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    // getDatas();
    getDatasFocus();
  }

  getDatas() async {
    print('打印结果1');
    var res = await HttpUtil().get(Api.searchUserForAt, parameters: params);
    setState(() {
      userList = res['data']; //['data']
    });
    print('打印结果');
    print(res);
    return res;
  }

  getDatasFocus() async {
    print('打印结果1');
    var res = await HttpUtil().get(Api.list_focus, parameters: {
      'userId': Provider.of<UserStateProvide>(context, listen: false)
          .userInfo['userId'],
      'pageSize': 100,
    });
    setState(() {
      userList = res['data']['users'];
      storageFocus = res['data']['users'];
    });
    print('打印结果');
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          // color: Theme.of(context).backgroundColor,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color:Theme.of(context).textTheme.titleLarge.color,
              size: 20,
            ),
          ),
        ),
        // brightness: Brightness.light,
        title: Text(
          '我要@TA',
          style:
              TextStyle(
              color:Theme.of(context).textTheme.titleLarge.color,
            fontSize: ScreenUtil().setSp(38)),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(30),
            ),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ScreenUtil().setWidth(60),
                    maxWidth: ScreenUtil().setWidth(750),
                  ),
                  child: TextField(
                    // focusNode: _focusNode,
                    autofocus: true,
                    controller: _inputController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 0, top: 0, right: 10, bottom: 0),
                      fillColor: Theme.of(context).backgroundColor,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00FF0000)),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      hintText: '请输入搜索内容',
                      hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: Theme.of(context).hintColor,
                      ),
                      prefixIcon: Icon(Icons.search),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00000000)),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    onChanged: (value) {
                      print('onChanged:$value');
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          params['keyword'] = value;
                        });
                        getDatas();
                      } else {
                        setState(() {
                          userList = storageFocus;
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
                ),
                chooseList.length > 0
                    ? Container(
                        height: ScreenUtil().setWidth(50),
                        margin: EdgeInsets.only(top: ScreenUtil().setWidth(10)),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (BuildContext context, int index) =>
                              VerticalDivider(
                            width: 10,
                            color: Color(0xFFFFFFFF),
                          ),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Container(
                                child: Text('已选择：'),
                              );
                            } else {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    chooseList.removeAt(index - 1);
                                  });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    height: ScreenUtil().setWidth(20),
                                    color: Color.fromRGBO(153, 153, 153, 0.2),
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    // margin: EdgeInsets.only(right: 10),

                                    child: Text(
                                      chooseList[index - 1]['userName'],
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(28),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          itemCount: chooseList.length + 1,
                        ),
                      )
                    : Container(
                        height: ScreenUtil().setWidth(60),
                      ),
              ],
            ),
          ),
          userList != null
              ? Container(
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setWidth(130),
                      bottom: ScreenUtil().setWidth(100)),
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(30),
                    right: ScreenUtil().setWidth(30),
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            chooseList.insert(0, userList[index]);
                          });
                          _inputController.value =
                              _inputController.value.copyWith(
                            text: '',
                            composing: TextRange.empty,
                          );
                          setState(() {
                            userList = storageFocus;
                          });
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          // height: ScreenUtil().setHeight(70),
                          child: Row(
                            children: [
                              userList[index]['icon'] != null
                                  ? Container(
                                      width: ScreenUtil().setWidth(80),
                                      height: ScreenUtil().setWidth(80),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                          imageUrl: KSet.imgOrigin +
                                              userList[index]['icon'] +
                                              '?x-oss-process=image/resize,h_80/format,webp/quality,q_75', //userList[index]['icon'],
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 0,
                                    ),
                              SizedBox(
                                width: ScreenUtil().setWidth(20),
                              ),
                              Container(
                                height: ScreenUtil().setWidth(80),
                                alignment: Alignment.centerLeft,
                                child: Text(userList[index]['userName']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: userList.length,
                  ),
                )
              : Container(),
          Positioned(
            bottom: 0,
            child: Container(
              width: ScreenUtil().setWidth(750),
              alignment: Alignment.center,
              child: MaterialButton(
                color: Colors.pink,
                textColor: Colors.white,
                child: new Text(
                  '完成',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                  ),
                ),
                minWidth: ScreenUtil().setWidth(680),
                height: ScreenUtil().setWidth(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Colors.pink),
                ),
                onPressed: () {
                  Navigator.pop(context, chooseList);
                },
              ),
            ),
          ),
          // FutureBuilder(
          //   builder: _buildFuture,
          //   future: getDatas(), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
          // ),
        ],
      ),
    );
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        print('还没有开始网络请求');
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        print('active');
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
      // print('waiting');
      // return Center(
      //   child: CircularProgressIndicator(),
      // );
      case ConnectionState.done:
        print('done');
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return Container(
          margin: EdgeInsets.only(top: 80),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                height: 80,
                child: Text('123123'),
              );
            },
            itemCount: userList.length,
          ),
        );
      default:
        return null;
    }
  }
}
