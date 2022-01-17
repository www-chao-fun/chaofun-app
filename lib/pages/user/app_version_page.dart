import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_chaofan/provide/user.dart';
import 'package:provider/provider.dart';

import 'package:r_upgrade/r_upgrade.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_chaofan/utils/SaveUtils.dart';


enum UpgradeMethod {
  all,
  hot,
  increment,
}

String version2;

getVersion() async {
  final versionNow = await PackageInfo.fromPlatform();
  version2 = versionNow.version;
}

class AppVersionPage extends StatefulWidget {
  _AppVersionPageState createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {
  UpgradeMethod upgradeMethod;
  String version;
  var appVersionInfo;

  bool ifdown = false;
  var plat;
  var downpercent = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    if (Platform.isIOS) {
      //ios相关代码
      setState(() {
        plat = 'ios';
      });
    } else if (Platform.isAndroid) {
      //android相关代码
      setState(() {
        plat = 'android';
      });
    }

    PackageInfo.fromPlatform().then((value) {
      setState(() {
        version = value.version.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(version2);
    print(version);
    appVersionInfo =
        Provider.of<UserStateProvide>(context, listen: false).appVersionInfo;
    print('appVersionInfo');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: AppBar(
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
            '',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        preferredSize: Size.fromHeight(40),
      ),
      body: appVersionInfo == null
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50, bottom: 20),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/icon/logo.png',
                      width: 80,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '炒饭超Fun',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(34),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Version ' + version,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                    ),
                  ),
                ),
                appVersionInfo != null
                    ? Container(
                        child: Text(
                          '新版本 ' + appVersionInfo['version'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 10,
                        ),
                      )
                    : Text(''),
                appVersionInfo != null
                    ? Container(
                        padding: EdgeInsets.only(
                          left: 120,
                          right: 120,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(appVersionInfo[
                            'content']), //appVersionInfo['content']
                      )
                    : Text(''),
                Consumer<UserStateProvide>(builder: (BuildContext context,
                    UserStateProvide user, Widget child) {
                  if (appVersionInfo == null) {
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 50),
                      child: MaterialButton(
                        elevation: 0,
                        color: Colors.white,
                        textColor: Colors.black,
                        child: new Text('当前为最新版本'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: BorderSide(color: KColor.defaultBorderColor),
                        ),
                        onPressed: () async {
                          // ...
                        },
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 50),
                      child: btn(context),
                    );
                  }
                }),
              ],
            )
          : Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(800),
              margin: EdgeInsets.only(top: ScreenUtil().setWidth(150)),
              child: _cons(),
            ),
    );
  }

  Widget _cons() {
    return Container(
      width: ScreenUtil().setWidth(450),
      // height: ScreenUtil().setWidth(700),
      padding: EdgeInsets.only(bottom: 10, top: 20),
      decoration: BoxDecoration(
        // color: Colors.red,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Image.asset(
              'assets/images/img/update.png',
              width: ScreenUtil().setWidth(298),
              height: ScreenUtil().setWidth(166),
            ),
            alignment: Alignment.center,
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                // border: Border(
                //   bottom: BorderSide(
                //     width: 0.5,
                //     color: Color.fromRGBO(240, 240, 240, 1),
                //   ),
                // ),
                ),
            child: Text(
              '新版本 ' + appVersionInfo['version'] + ' ( ' + version + ' )',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                appVersionInfo['content'] != null
                    ? appVersionInfo['content']
                    : '暂无更新内容',
                style: TextStyle(
                  height: 1.5,
                  fontSize: ScreenUtil().setSp(28),
                  color: Color.fromRGBO(97, 101, 105, 1),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   height: ScreenUtil().setWidth(70),
          // ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: appVersionInfo['action'] == 'notify'
                  ? MainAxisAlignment.spaceAround
                  : MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: !ifdown ? Color.fromRGBO(255, 147, 0, 1) : Colors.grey,
                  textColor: Colors.white,
                  minWidth: ScreenUtil().setWidth(200),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: plat == 'android'
                      ? new Text(!ifdown
                          ? '立即升级'
                          : '下载中...${(downpercent * 100).toStringAsFixed(1)}%')
                      : new Text('立即升级'),
                  onPressed: () async {
                    if (!ifdown) {
                      if (plat == 'android') {
                        bool permission = await requestPermission();
                        if (!permission) {
                          Fluttertoast.showToast(msg: '没有相册或存储权限', toastLength: Toast.LENGTH_LONG);
                          return;
                        }
                        setState(() {
                          ifdown = true;
                        });
                        print('点击下载');
                        var id = await RUpgrade.upgrade(
                            'https://chao.fun/chaofan.apk',
                            fileName: 'chaofan.apk',
                            isAutoRequestInstall: true,
                            notificationStyle:
                                NotificationStyle.speechAndPlanTime,
                            useDownloadManager: false);
                        RUpgrade.stream.listen((DownloadInfo info) {
                          print('info');
                          print(info.percent);
                          var s = info.percent / 100;
                          setState(() {
                            downpercent = s;
                          });
                          if (s == 0.0) {
                            setState(() {
                              ifdown = false;
                            });
                          }

                          ///...
                        });
                        setState(() {
                          id = id;
                        });
                        upgradeMethod = UpgradeMethod.all;
                        print('开始安装');
                      } else {
                        await RUpgrade.upgradeFromUrl(
                          'https://apps.apple.com/cn/app/%E7%82%92%E9%A5%AD%E8%B6%85fun/id1526950194',
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget btn(context) {
    return MaterialButton(
      elevation: 0,
      color: Colors.white,
      textColor: Colors.black,
      child: RichText(
        text: TextSpan(
          text: '立即更新',
          style: TextStyle(
            // fontSize: 30,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(text: 'new', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: KColor.defaultBorderColor),
      ),
      onPressed: () async {
        print('点击下载');
        Fluttertoast.showToast(
          msg: '准备下载',
          gravity: ToastGravity.CENTER,
          // textColor: Colors.grey,
        );
        if (Platform.isAndroid) {
          Fluttertoast.showToast(
            msg: '开始下载,请稍等...',
            gravity: ToastGravity.CENTER,
            // textColor: Colors.grey,
          );
          print('点击下载');
          var id = await RUpgrade.upgrade('https://chao.fun/chaofan.apk',
              fileName: 'chaofan.apk',
              isAutoRequestInstall: true,
              notificationStyle: NotificationStyle.speechAndPlanTime,
              useDownloadManager: false);
          upgradeMethod = UpgradeMethod.all;
          print('开始安装');
        } else {
          await RUpgrade.upgradeFromUrl(
            'https://apps.apple.com/cn/app/%E7%82%92%E9%A5%AD%E8%B6%85fun/id1526950194',
          );
        }
      },
    );
  }
}
