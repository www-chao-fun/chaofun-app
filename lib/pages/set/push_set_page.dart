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

class PushSetPage extends StatefulWidget {
  _PushSetPageState createState() => _PushSetPageState();
}

class _PushSetPageState extends State<PushSetPage> {
  String version;
  var appVersionInfo;

  bool ifdown = false;
  bool loopGif;
  var plat;
  var downpercent = 0.0;
  var hasSet;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loopGif = Provider.of<UserStateProvide>(context, listen: false).loopGif;
    getPushConfig();
  }

  getPushConfig() async {
    var res = await HttpUtil().get(Api.getPushConfig, parameters: {});
    if (res['success'] && res['data'] != null) {
      var data = res['data'];
      setState(() {
        openAt = data['openAt'];
        openComment = data['openComment'];
        openNotice = data['openNotice'];
        openUp = data['openUp'];
        openChat = data['openChat'];
      });
    }
    setState(() {
      hasSet = true;
    });
    print(res);
  }

  List setData = [
    {'title': '点赞', 'name': 'openUp'},
    {'title': '评论', 'name': 'openComment'},
    {'title': '@我', 'name': 'openAt'},
    {'title': '通知', 'name': 'openNotice'},
    {'title': '聊天', 'name': 'openChat'},
  ];
  bool openAt = true;
  bool openComment = true;
  bool openNotice = true;
  bool openUp = true;
  bool openChat = true;

  _doBind(item) {
    if (item['name'] == 'openUp') {
      return openUp;
    } else if (item['name'] == 'openComment') {
      return openComment;
    } else if (item['name'] == 'openAt') {
      return openAt;
    } else if (item['name'] == 'openNotice') {
      return openNotice;
    } else if (item['name'] == 'openChat') {
      return openChat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
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
          '推送设置',
          style:
              Theme.of(context).textTheme.headline6,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: [
          hasSet != null
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: InkWell(
                        onTap: () {},
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
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  //CupertinoSwitch
                                  value: _doBind(setData[index]),
                                  onChanged: (value) async {
                                    print(value);
                                    var item = setData[index];
                                    print(value);
                                    if (item['name'] == 'openUp') {
                                      setState(() {
                                        openUp = value;
                                      });
                                    } else if (item['name'] == 'openComment') {
                                      setState(() {
                                        openComment = value;
                                      });
                                    } else if (item['name'] == 'openAt') {
                                      setState(() {
                                        openAt = value;
                                      });
                                    } else if (item['name'] == 'openNotice') {
                                      setState(() {
                                        openNotice = value;
                                      });
                                    } else if (item['name'] == 'openChat') {
                                      setState(() {
                                        openChat = value;
                                      });
                                    }
                                    var res = await HttpUtil().post(
                                        Api.setPushConfig,
                                        queryParameters: {
                                          'openUp': openUp,
                                          'openComment': openComment,
                                          'openAt': openAt,
                                          'openNotice': openNotice,
                                          'openChat': openChat
                                        });
                                    print(res);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: setData.length,
                )
              : Container(
                  height: 0,
                ),
        ],
      ),
    );
  }
}
