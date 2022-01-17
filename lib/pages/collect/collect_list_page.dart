import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/collect/collect_add_page.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_chaofan/provide/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CollectListPage extends StatefulWidget {
  final Map arguments;
  CollectListPage({Key key, this.arguments}) : super(key: key);
  _CollectListPageState createState() => _CollectListPageState();
}

class _CollectListPageState extends State<CollectListPage> {
  String version;
  var appVersionInfo;

  bool ifdown = false;
  bool loopGif;
  var plat;
  var downpercent = 0.0;
  var hasSet;

  var _radioGroupValue = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loopGif = Provider.of<UserStateProvide>(context, listen: false).loopGif;
    if (widget.arguments['id'] != null) {
      _radioGroupValue = widget.arguments['id'];
    }
    collectionlist();
  }

  collectionlist() async {
    var res = await HttpUtil().get(Api.collectionlist, parameters: {});
    if (res['success'] && res['data'] != null) {
      var data = res['data'];
      var a = [];
      a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      // a.addAll(data);
      setState(() {
        setData = a;
        hasSet = true;
      });
    }
    print(res);
  }

  List setData = [];
  bool openAt = true;
  bool openComment = true;
  bool openNotice = true;
  bool openUp = true;

  _doBind(item) {
    if (item['name'] == 'openUp') {
      return openUp;
    } else if (item['name'] == 'openComment') {
      return openComment;
    } else if (item['name'] == 'openAt') {
      return openAt;
    } else if (item['name'] == 'openNotice') {
      return openNotice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          color: Colors.white,
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
        brightness: Brightness.light,
        title: Text(
          widget.arguments['type'] == 'choose' ? '选择合集' : '我的合集',
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(34)),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(bottom: 12, top: 12, right: 10),
            width: ScreenUtil().setWidth(140),
            height: ScreenUtil().setWidth(20),
            child: MaterialButton(
              color: Color.fromRGBO(255, 147, 0, 1),
              textColor: Colors.white,
              child: new Text(
                '创建合集',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
              minWidth: ScreenUtil().setWidth(120),
              height: ScreenUtil().setWidth(20),
              padding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(
                  color: Color.fromRGBO(255, 147, 0, 1),
                ),
              ),
              onPressed: () async {
                Navigator.push<String>(context,
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return new CollectAddPage();
                })).then((String result) {
                  //处理代码
                  setState(() {
                    setData = [];
                  });
                  collectionlist();
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          widget.arguments['type'] == 'choose'
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      child: RadioListTile(
                        title: Text(
                          setData[index]['name'],
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1),
                              fontSize: ScreenUtil().setSp(32)),
                        ),
                        value: setData[index]['id'].toString(),
                        groupValue: _radioGroupValue,
                        onChanged: (value) {
                          setState(() {
                            _radioGroupValue = value;
                          });
                        },
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                    );
                  },
                  itemCount: setData.length,
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == setData.length) {
                      return Container(
                        height: 80,
                      );
                    }
                    return Container(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          SystemUiOverlayStyle systemUiOverlayStyle =
                              SystemUiOverlayStyle(
                            statusBarColor: Colors.transparent,
                            // statusBarIconBrightness: Brightness.dark,
                          ); //Colors.black38
                          SystemChrome.setSystemUIOverlayStyle(
                              systemUiOverlayStyle);
                          Navigator.pushNamed(
                            context,
                            '/collectdetail',
                            arguments: {
                              'id': setData[index]['id'],
                              'name': setData[index]['name']
                            },
                          );
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(110),
                          padding: EdgeInsets.only(left: 0, right: 10),
                          margin: EdgeInsets.only(left: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(183, 183, 183, 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/_icon/collects.png',
                                width: ScreenUtil().setWidth(40),
                                height: ScreenUtil().setWidth(40),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    setData[index]['name'],
                                    style: TextStyle(
                                        color: Color.fromRGBO(105, 105, 105, 1),
                                        fontSize: ScreenUtil().setSp(32)),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: KColor.defaultBorderColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: setData.length + 1,
                ),
          widget.arguments['type'] == 'choose'
              ? Positioned(
                  left: 20,
                  right: 20,
                  bottom: 5,
                  child: MaterialButton(
                    color: Colors.pink,
                    textColor: Colors.white,
                    child: new Text(
                      '确定',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                    minWidth: ScreenUtil().setWidth(680),
                    height: ScreenUtil().setWidth(90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.pink),
                    ),
                    onPressed: () async {
                      if (_radioGroupValue != '') {
                        var pas = {
                          'postId': widget.arguments['postId'],
                          'collectionId': _radioGroupValue,
                        };
                        print('pas$pas');
                        var res = await HttpUtil()
                            .get(Api.addCollectionPost, parameters: pas);
                        if (res['success']) {
                          Fluttertoast.showToast(
                            msg: '加入合集成功',
                            gravity: ToastGravity.CENTER,
                          );
                          Future.delayed(Duration(milliseconds: 1500))
                              .then((e) {
                            Navigator.pop(context, 'success');
                          });
                        }
                      }
                    },
                  ),
                )
              : Container(
                  height: 0,
                ),
        ],
      ),
    );
  }
}
