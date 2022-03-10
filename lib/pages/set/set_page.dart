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

class SetPage extends StatefulWidget {
  _SetPageState createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  String version;
  var appVersionInfo;

  bool ifdown = false;
  bool loopGif = true;
  bool autoPlayGif = true;
  var plat;
  var downpercent = 0.0;
  @override
  void initState() {

    super.initState();

    this.init();
  }

  void init() async {
    var tLoopGif = await Provider.of<UserStateProvide>(context, listen: false).getLoopGif();
    var tAutoPlayGif = await Provider.of<UserStateProvide>(context, listen: false).getAutoPlayGif();
    setState(() {
      loopGif = tLoopGif;
      autoPlayGif = tAutoPlayGif;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          '设置',
          style:
              TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(38)),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/setinfopage',
                      arguments: {'type': 1},
                    );
                  },
                  child: Container(
                    height: ScreenUtil().setWidth(110),
                    padding: EdgeInsets.only(left: 0, right: 10),
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        // bottom: BorderSide(
                        //   width: 1,
                        //   color: Color.fromRGBO(183, 183, 183, 0.2),
                        // ),
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
                          '个人资料',
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Container(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: ScreenUtil().setWidth(80),
                                  height: ScreenUtil().setWidth(80),
                                  child: Provider.of<UserStateProvide>(context,
                                                  listen: true)
                                              .userInfo['icon'] !=
                                          null
                                      ? CachedNetworkImage(
                                          imageUrl: KSet.imgOrigin +
                                              Provider.of<UserStateProvide>(
                                                      context,
                                                      listen: true)
                                                  .userInfo['icon'] +
                                              '?x-oss-process=image/resize,h_150/format,webp/quality,q_75',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/icon/default.jpg'),
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    // print(Provider.of<UserStateProvide>(context, listen: false)
                    //     .userInfo['phone']);
                    if (Provider.of<UserStateProvide>(context, listen: false)
                                .userInfo['phone'] ==
                            null ||
                        Provider.of<UserStateProvide>(context, listen: false)
                                .userInfo['phone'] ==
                            '') {
                      Navigator.pushNamed(
                        context,
                        '/bindphonepage',
                        arguments: {'type': 1},
                      );
                    }
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
                        Text(
                          '手机号',
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Provider.of<UserStateProvide>(context, listen: true)
                                        .userInfo['phone'] ==
                                    null ||
                                Provider.of<UserStateProvide>(context,
                                            listen: false)
                                        .userInfo['phone'] ==
                                    ''
                            ? Text('去绑定 >',
                                style: TextStyle(
                                    color: Color.fromRGBO(155, 155, 155, 1)))
                            : Text(Provider.of<UserStateProvide>(context,
                                    listen: true)
                                .userInfo['phone']),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
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
                          'GIF循环播放',
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            //CupertinoSwitch
                            value: loopGif,
                            onChanged: (value) {
                              setState(() {
                                loopGif = !loopGif;
                              });
                              Provider.of<UserStateProvide>(context,
                                      listen: false)
                                  .setLoopGif();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
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
                          'GIF自动播放',
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            //CupertinoSwitch
                            value: autoPlayGif,
                            onChanged: (value) {
                              setState(() {
                                autoPlayGif = !autoPlayGif;
                              });
                              Provider.of<UserStateProvide>(context,
                                  listen: false)
                                  .setAutoPlayGif();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 推送设置
              Container(
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/pushSet',
                      arguments: {'type': 1},
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
                        Text(
                          '推送设置',
                          style: TextStyle(
                              color: Color.fromRGBO(105, 105, 105, 1)),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
