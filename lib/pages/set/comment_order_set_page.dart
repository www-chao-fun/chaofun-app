import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_chaofan/provide/user.dart';
import 'package:provider/provider.dart';

class CommentOrderSetPage extends StatefulWidget {
  _CommentOrderSetPageState createState() => _CommentOrderSetPageState();
}

class _CommentOrderSetPageState extends State<CommentOrderSetPage> {

  bool openLast = true;
  bool openNew = false;
  bool openHot = false;
  bool openOld = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    String fixedCommentOrder =  Provider.of<UserStateProvide>(context, listen: false).fixedCommentOrder;
    if (fixedCommentOrder == 'hot') {
      setState(() {
        openHot = true;
      });
    } else if (fixedCommentOrder == 'new') {
      setState(() {
        openNew = true;
      });
    } else if (fixedCommentOrder == 'old') {
      setState(() {
        openOld = true;
      });
    }
  }

  List setData = [
    {'title': '最新', 'name': 'new'},
    {'title': '最热', 'name': 'hot'},
    {'title': '时间', 'name': 'old'},
  ];

  _doBind(item) {
    if (item['name'] == 'new') {
      return openNew;
    } else if (item['name'] == 'hot') {
      return openHot;
    } else if (item['name'] == 'old') {
      return openOld;
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
          '默认评论排序',
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(38)),
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      openHot = false;
                      openNew = false;
                      openOld = false;

                      if (setData[index]['name'] == 'hot') {
                        setState(() {
                          openHot = true;
                        });
                      } else if (setData[index]['name']  == 'new') {
                        setState(() {
                          openNew = true;
                        });
                      } else if (setData[index]['name']  == 'old') {
                        setState(() {
                          openOld = true;
                        });
                      }
                      Provider.of<UserStateProvide>(context, listen: false).setFixedCommentOrder(setData[index]['name']);
                    });
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(110),
                    padding: EdgeInsets.only(left: 0, right: 0),
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
                        Text(
                          setData[index]['title'],
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Padding(padding:  EdgeInsets.only(right: 20),
                            child:
                            Visibility(
                                visible: _doBind(setData[index]),
                                child: Icon(Icons.check, color: Colors.green,)
                            )
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: setData.length,
          )
        ],
      ),
    );
  }
}
