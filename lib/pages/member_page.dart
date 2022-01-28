import 'dart:ui';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/font.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/pages/post_detail/webview_flutter.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
// import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/image/selfs_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:images_picker/images_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_chaofan/database/userHelper.dart';
import 'package:flutter_chaofan/database/model/userDB.dart';
import 'package:flutter_chaofan/utils/notice.dart';


class MemberPage extends StatefulWidget {
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  static const MethodChannel _methodChannel =
      const MethodChannel('app.chao.fun/main_channel');
  var db = UserHelper();

  CookieManager cookieManager = new CookieManager();

  var _scrollController = ScrollController();


  List<Map> listData = [
    {"label": "修改资料", "value": "1", "icon": "assets/images/icon/fabu.png"},
    // {"label": "浏览历史", "value": "11", "icon": "assets/images/icon/fabu.png"},
    // {"label": "管理的版块", "value": "12", "icon": "assets/images/icon/fabu.png"},
    // {"label": "我的发布", "value": "1", "icon": "assets/images/icon/fabu.png"},
    // {"label": "我点赞的", "value": "2", "icon": "assets/images/icon/dianzan.png"},
    // {"label": "我的收藏", "value": "3", "icon": "assets/images/icon/shoucang.png"},
    // {"label": "我的合集", "value": "5", "icon": "assets/images/icon/shoucang.png"},
    // {"label": "我的工具", "value": "4", "icon": "assets/images/icon/shoucang.png"},
  ];
// 颜色 #FB8A96
  List<Map> listData2 = [
    {"label": "检查更新", "value": "6", "icon": "assets/images/icon/update.png"},
    {"label": "联系我们", "value": "7", "icon": "assets/images/icon/about.png"},
    {"label": "鸣谢", "value": "8", "icon": "assets/images/icon/like_filled.png"},
    {"label": "设置", "value": "9", "icon": "assets/images/icon/set.png"},
    {"label": "清除缓存", "value": "10", "icon": "assets/images/icon/set.png"},
    // {"label": "关于我们", "value": "7", "icon": "assets/images/icon/about.png"},
  ];

  // 颜色 #FB8A96
  List<Map> listData3 = [
    {"label": "用户服务协议", "value": "13", "icon": "assets/images/icon/update.png"},
    {"label": "隐私政策", "value": "14", "icon": "assets/images/icon/about.png"},
  ];
  var ISLOGIN = false;
  List<Map> listForum = [{}, {}, {}, {}, {}, {}];
  var userInfo;
  var activitys = {'has': false, 'imgUrl': '', 'title': '', 'url': ''};

  _saveUserDB(data) async {
    var d = userDB.fromJson(data);
    await db.saveItem(d);
    // db.close();
  }

  _getUserDB() async {
    var a = await db.getTotalList();
    if (a.length > 0) {
      var islogin = Provider.of<UserStateProvide>(context, listen: false)
          .changeState(true);
      setState(() {
        ISLOGIN = true;
        userInfo = a[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserDB();
    getUserInfo();
    // 切换 Tag 刷新用户信息
    Notice.addListener("refreshUserInfo", (data) => getUserInfo());
  }

  @override
  void activate() {
    getUserInfo();
  }

  void inits(context) {
    var islogin = Provider.of<UserStateProvide>(context, listen: false).ISLOGIN;
    setState(() {
      ISLOGIN = islogin;
    });
  }

  void getUserInfo() async {
    var response = await HttpUtil().get(Api.getUserInfo);

    db.clear('table_user');
    if (response['data'] != null) {
      Provider.of<UserStateProvide>(context, listen: false).changeState(true);
      Provider.of<UserStateProvide>(context, listen: false)
          .changeUserInfo(response['data']);

      setState(() {
        userInfo = response['data'];
      });
      _saveUserDB(userInfo);
      final bindInfo = await _methodChannel
          .invokeMapMethod<String, dynamic>('getDeviceInfo');
      var _ = HttpUtil().get(Api.bindDevice, parameters: bindInfo);
    } else {
      setState(() {
        ISLOGIN = false;
        userInfo = null;
      });
      Provider.of<UserStateProvide>(context, listen: false).changeState(false);
      Provider.of<UserStateProvide>(context, listen: false)
          .removeSharedPreferences('cookie');
      await db.clear('table_user');
      final unbindInfo = await _methodChannel
          .invokeMapMethod<String, dynamic>('getDeviceInfo');
      var _ = HttpUtil().get(Api.unbindDevice, parameters: unbindInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    inits(context);
    return Scaffold(
      backgroundColor: KColor.defaultPageBgColor,
      appBar: PreferredSize(
        child: Container(
          width: double.infinity,
          height: 0,
          decoration: BoxDecoration(color: Colors.transparent),
          // child: SafeArea(child: Text("1212")),
        ),
        preferredSize: Size(double.infinity, 0),
      ),
      body:
      NotificationListener<ScrollEndNotification>(
          onNotification: (t) {
            if (_scrollController.position.pixels < 0.1) {
              getUserInfo();
            }
          },
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 20),
            children: <Widget>[
              ISLOGIN && (userInfo != null) ? _topHeader(userInfo) : _untopHeader(),
              ISLOGIN && (userInfo != null)
                  ? _secondLine(context)
                  : Container(height: 0),
              ISLOGIN && (userInfo != null)
                  ? _thirdLine(context)
                  : Container(height: 0),
              ISLOGIN && (userInfo != null)
                  ? _iconsList(context)
                  : Container(height: 0),
              _iconsList2(context, listData2),
              _iconsList2(context, listData3),
              // actWidget(),
              // ISLOGIN && (userInfo != null)
              //     ? _clearStorage(context)
              //     : Container(height: 0),
              ISLOGIN && (userInfo != null)
                  ? _outLogin(context)
                  : Container(height: 0),
              ISLOGIN && (userInfo != null)
                  ? _cancel(context)
                  : Container(height: 0)
            ],
          )
      ),
    );
  }

  Widget _secondLine(context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 1,
          child: Container(
            // decoration: BoxDecoration(
            //   border: Border(
            //     right: BorderSide(
            //       width: 0.5,
            //       color: Color.fromRGBO(33, 29, 47, 0.5),
            //     ),
            //   ),
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  userInfo['followers'] != null
                      ? userInfo['followers'].toString()
                      : '0',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '粉丝',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Color.fromRGBO(33, 29, 47, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 0.8,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color.fromRGBO(33, 29, 47, 0.2)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  userInfo['focus'] != null
                      ? userInfo['focus'].toString()
                      : '0',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '关注',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Color.fromRGBO(33, 29, 47, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 0.8,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color.fromRGBO(33, 29, 47, 0.2)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  userInfo['ups'] != null ? userInfo['ups'].toString() : '0',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '获赞',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Color.fromRGBO(33, 29, 47, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 0.8,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color.fromRGBO(33, 29, 47, 0.2)),
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChaoFunWebView(
                    url: 'https://chao.fun/webview/fbi',
                    title: '饭币（FBi）',
                    showAction: 0,
                    cookie: true,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  userInfo['fbi'] != null
                      ? userInfo['fbi'].toString()
                      : '0',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'FBi',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Color.fromRGBO(33, 29, 47, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _thirdLine(context) {
    return Container(
      margin: EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 15),
      height: ScreenUtil().setWidth(152),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(224, 224, 224, 0.5),
              offset: Offset(1.0, 2.0),
              blurRadius: 2.0,
              spreadRadius: 1.0)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _thirdItem(
              'assets/images/_icon/my_star.png', '收藏', '', '/usersavepage'),
          _thirdItem(
              'assets/images/_icon/my_heji.png', '合集', '', '/collectlist'),
          _thirdItem('assets/images/_icon/my_niming.png', '匿名发布', '', null),
        ],
      ),
    );
  }

  Widget _thirdItem(imgUrl, text, num, url) {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            if (url != null) {
              Navigator.pushNamed(
                context,
                url,
                arguments: {'type': 1},
              );
            } else {
              Fluttertoast.showToast(
                msg: '功能待开放',
                gravity: ToastGravity.CENTER,
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imgUrl,
                width: ScreenUtil().setWidth(48),
              ),
              SizedBox(
                height: 4,
              ),
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: text,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: Color.fromRGBO(33, 29, 47, 1),
                    ),
                    children: [
                      TextSpan(
                        text: num.toString(),
                        style: TextStyle(
                          color: Color.fromRGBO(33, 29, 47, 0.5),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topHeader(info) {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.fromLTRB(32, 80, 32, 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(108),
                margin: EdgeInsets.only(right: 10),
                child: ClipOval(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        FadeRoute(
                          page: SelfHeader(
                            imgDataArr: [
                              KSet.imgOrigin +
                                  info['icon'] +
                                  '?x-oss-process=image/resize,h_150'
                            ],
                            index: 0,
                            showMore: true,
                            callBack: () {
                              getUserInfo();
                            },
                          ),
                        ),
                      );
                      // getImage(false);
                    },
                    child: userInfo['icon'] != null
                        ? CachedNetworkImage(
                            imageUrl: KSet.imgOrigin +
                                info['icon'] +
                                '?x-oss-process=image/resize,h_150',
                            width: ScreenUtil().setWidth(108),
                            height: ScreenUtil().setWidth(108),
                            fit: BoxFit.cover,
                          )
                        : Image.asset('assets/images/icon/default.jpg'),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  color: KColor.defaultPageBgColor,
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                  height: ScreenUtil().setWidth(114),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/userMemberPage',
                        arguments: {"userId": userInfo['userId'].toString()},
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            userInfo['userName'],
                            // '按时可获得按时回到家看书登记卡时候大健康',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(34),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            userInfo['desc'] == null
                                ? '空空如也'
                                : userInfo['desc'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color.fromRGBO(33, 29, 47, 0.5),
                              fontSize: ScreenUtil().setSp(26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/userMemberPage',
                    arguments: {"userId": userInfo['userId'].toString()},
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 4,
                    top: 4,
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(33, 29, 47, 0.05),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    // border: Border.all(
                    //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                  ),
                  child: Text(
                    '主页',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      color: KColor.primaryColor,
                    ),
                  ),
                ),
              ),
              // Icon(
              //   Icons.arrow_forward_ios,
              //   color: Color.fromRGBO(167, 165, 172, 1),
              //   size: 12,
              // ),
            ],
          ),
          // _threeList(),
        ],
      ),
    );
  }

  Future getImage(isTakePhoto) async {
    // Navigator.pop(context);
    // var image = await ImagePicker.pickImage(
    //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
    List res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.image,
      maxSize: 10480,
      quality: 0.8,
      // cropOpt: CropOption(aspectRatio: CropAspectRatio.wh16x9),
      cropOpt: CropOption(
        aspectRatio: CropAspectRatio.custom,
        cropType: CropType.circle,
      ),
    );
    _upLoadImage(File(res[0].path));
  }

  //上传图片
  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });
    Dio dio = new Dio();
    var res =
        await dio.post("https://chao.fun/api/upload_image", data: formdata);
    print('上传结束');
    print(res);
    print(res.data['data']);
    if (res.data['success']) {
      // setState(() {});
      // String name = res.data['data'];
      var response = await HttpUtil()
          .get(Api.setIcon, parameters: {'imageName': res.data['data']});
      if (response['success']) {
        setState(() {
          userInfo['icon'] = res.data['data'];
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: res.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Widget _untopHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(32, 80, 32, 60),
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/_icon/logo.png',
            width: ScreenUtil().setWidth(140),
          ),
          SizedBox(
            width: 30,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/accoutlogin',
              );
            },
            child: Text(
              '未登录(点击登录)',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(34),
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // MaterialButton(
          //   color: Colors.pink,
          //   textColor: Colors.white,
          //   child: new Text('未登录'),
          //   onPressed: () {
          //     Navigator.pushNamed(
          //       context,
          //       '/accoutlogin',
          //     );
          //   },
          // )
        ],
      ),
    );
  }

  //我的订单顶部标题
  Widget _threeList() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            // bottom: BorderSide(width: 1, color: Colors.black12),
            ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  '100',
                  style: KFont.titleFontStyle,
                ),
                Text(
                  '帖子',
                  style: KFont.descFontStyle,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  userInfo['ups'].toString(),
                  style: KFont.titleFontStyle,
                ),
                Text(
                  '获赞',
                  style: KFont.descFontStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actWidget() {
    if (activitys['has']) {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewExample(
                          url: activitys['url'], title: activitys['title']),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/images/icon/hot.jpg',
                          width: ScreenUtil().setWidth(60),
                          height: ScreenUtil().setWidth(60),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          activitys['title'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: KColor.defaultBorderColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.5,
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  // Widget _doIconList()

  // 订单区域列表
  Widget _iconsList(context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      // padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Column(
        children: listData.map((item) {
          //userInfo['userId']==2&&
          if (item['value'] != '4' ||
              (userInfo != null &&
                  (userInfo['userId'] == 2 || userInfo['userId'] == 831))) {
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    height: ScreenUtil().setWidth(88),
                    child: InkWell(
                      onTap: () {
                        if (Provider.of<UserStateProvide>(context,
                                listen: false)
                            .ISLOGIN) {
                          if (item['value'] == '1') {
                            // Navigator.pushNamed(
                            //   context,
                            //   '/userpostpage',
                            //   arguments: {'type': 1},
                            // );
                            Navigator.pushNamed(
                              context,
                              '/setinfopage',
                              arguments: {'type': 1},
                            );
                          } else if (item['value'] == '2') {
                            Navigator.pushNamed(
                              context,
                              '/userupspage',
                              arguments: {'type': 1},
                            );
                          } else if (item['value'] == '3') {
                            Navigator.pushNamed(
                              context,
                              '/usersavepage',
                              arguments: {'type': 1},
                            );
                          } else if (item['value'] == '4') {
                            Navigator.pushNamed(
                              context,
                              '/toolsPage',
                              arguments: {'type': 1},
                            );
                          } else if (item['value'] == '5') {
                            Navigator.pushNamed(
                              context,
                              '/collectlist',
                              arguments: {'type': 1},
                            );
                          }
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/accoutlogin',
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color.fromRGBO(167, 165, 172, 1),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.5,
                  ),
                ],
              ),
            );
          } else {
            return Container(
              height: 0,
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _iconsList2(context, List<Map> tListData) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      // padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Column(
        children: tListData.map((item) {
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  height: ScreenUtil().setWidth(88),
                  child: InkWell(
                    onTap: () {
                      if (item['value'] == '6') {
                        Navigator.pushNamed(
                          context,
                          '/appversion',
                          arguments: {'type': 1},
                        );
                      } else if (item['value'] == '7') {
                        if (Provider.of<UserStateProvide>(context,
                                listen: false)
                            .ISLOGIN) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChaoFunWebView(
                                url: 'https://chao.fun/webview/contact?v=1',
                                title: '反馈建议',
                                showAction: 0,
                                cookie: false,
                                showHeader: true,
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/accoutlogin',
                          );
                        }
                      } else if (item['value'] == '8') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaoFunWebView(
                              url: 'https://chao.fun/webview/thx',
                              title: '鸣谢',
                              showAction: 0,
                              cookie: false,
                              showHeader: true,
                            ),
                          ),
                        );
                      } else if (item['value'] == '9') {
                        if (Provider.of<UserStateProvide>(context,
                                listen: false)
                            .ISLOGIN) {
                          Navigator.pushNamed(
                            context,
                            '/setpage',
                            arguments: {'type': 1},
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/accoutlogin',
                          );
                        }
                      } else if (item['value'] == '10') {
                        clearStorages();
                      } else if (item['value'] == '13') {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaoFunWebView(
                              url: 'https://chao.fun/webview/useragree', //'https://chao.fun/webview/agreement',
                              title: '用户服务协议',
                              showAction: false,
                            ),
                          ),
                        );

                      } else if (item['value'] == '14') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChaoFunWebView(
                              // url: 'https://chao.fun/p/417588',
                              url: 'https://chao.fun/webview/agreement', //'https://chao.fun/webview/agreement',
                              title: '隐私政策',
                              showAction: false,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(30),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            (Provider.of<UserStateProvide>(context,
                                                listen: false)
                                            .appVersionInfo !=
                                        null &&
                                    item['value'] == '6')
                                ? Text(
                                    'NEW',
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(20),
                                        color: Colors.red),
                                  )
                                : Text(''),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromRGBO(167, 165, 172, 1),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(700),
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(244, 244, 244, 0.2)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _interst() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              '我感兴趣的',
              style: KFont.titleFontStyle,
            ),
          ),
          InkWell(
            child: Text(
              '查看全部',
              style: TextStyle(
                color: KColor.defaultGrayColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listForum() {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: listForum.map((e) {
          return InkWell(
            child: Column(
              children: <Widget>[
                Image.network(
                  'https://i.chao.fun/990cf5792a356642fe46e7dbe577ebab.png?x-oss-process=image/resize,h_80',
                  width: ScreenUtil().setWidth(60),
                ),
                Text(
                  '全网热门',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _intrestForum() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          _interst(),
          _listForum(),
        ],
      ),
    );
  }

  Future _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    //计算大小
    if (file is File) {
      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory) {
      final List children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await _getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  Future<Null> loadCache() async {
    Directory tempDir = await getTemporaryDirectory(); //getTemporaryDirectory
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    var b = _renderSize(value);

    print('临时目录大小: ' + value.toString());
    print('临时目录大小: ' + b.toString());
    //清除缓存
    delDir(tempDir);
  }

  //递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await delDir(child);
      }
    }
    await file.delete();
    print('清除完毕');
  }

  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    List<String> unitArr = List()
      ..add('B')
      ..add('K')
      ..add('M')
      ..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  Widget _clearStorage(context) {
    return InkWell(
      onTap: () {
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('disabledPostList');
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('disabledUserList');
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('indexDialog');
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('looksList');
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('remmenberForumList');
        Provider.of<UserStateProvide>(context, listen: false)
            .removeSharedPreferences('updateTime');

        Provider.of<UserStateProvide>(context, listen: false)
            .setDisabledPostList();
        Provider.of<UserStateProvide>(context, listen: false)
            .setDisabledUserList();
        Provider.of<UserStateProvide>(context, listen: false).setIndexDialog();
        Provider.of<UserStateProvide>(context, listen: false).getLooksList();
        Fluttertoast.showToast(
          msg: '已清除缓存',
          gravity: ToastGravity.CENTER,
          // textColor: Colors.grey,
        );
        loadCache();
      },
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.fromLTRB(10, 14, 10, 14),
        alignment: Alignment.center,
        child: Text(
          '清除缓存',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  clearStorages() async {
    showCupertinoDialog(
        //showCupertinoDialog
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('提示'),
            content: Text('确定清除缓存吗？'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop('cancel');
                },
              ),
              CupertinoDialogAction(
                child: Text('确定'),
                onPressed: () async {
                  Navigator.of(context).pop('ok');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('disabledPostList');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('disabledUserList');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('indexDialog');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('looksList');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('remmenberForumList');
                  Provider.of<UserStateProvide>(context, listen: false)
                      .removeSharedPreferences('updateTime');

                  Provider.of<UserStateProvide>(context, listen: false)
                      .setDisabledPostList();
                  Provider.of<UserStateProvide>(context, listen: false)
                      .setDisabledUserList();
                  Provider.of<UserStateProvide>(context, listen: false)
                      .setIndexDialog();
                  Provider.of<UserStateProvide>(context, listen: false)
                      .getLooksList();
                  Fluttertoast.showToast(
                    msg: '已清除缓存',
                    gravity: ToastGravity.CENTER,
                    // textColor: Colors.grey,
                  );
                  loadCache();
                },
              ),
            ],
          );
        });
  }

  Widget _outLogin(context) {
    return InkWell(
      onTap: () async {

        showCupertinoDialog(
          //showCupertinoDialog
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('提示'),
                content: Text('你确定退出登陆吗？'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop('cancel');
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text('确定'),
                    onPressed: () async {
                      Notice.send("logout", "");
                      Provider.of<UserStateProvide>(context, listen: false)
                          .changeState(false);
                      // Provider.of<UserStateProvide>(context, listen: false).getLooksList();
                      await db.clear('table_user');
                      await db.clear('All_page');
                      await db.clear('table_addjoin');
                      setState(() {
                        ISLOGIN = false;
                      });
                      final unbindInfo = await _methodChannel
                          .invokeMapMethod<String, dynamic>('getDeviceInfo');
                      var _ = HttpUtil().get(Api.unbindDevice, parameters: unbindInfo);
                      Provider.of<UserStateProvide>(context, listen: false)
                          .removeSharedPreferences('cookie');
                      Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(builder: (context) => IndexPage()),
                            (route) => route == null,
                      );
                    },
                  ),
                ],
              );
            });

      },
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.fromLTRB(10, 14, 10, 14),
        alignment: Alignment.center,
        child: Text(
          '退出登录',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _cancel(context) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChaoFunWebView(
              url: 'https://chao.fun/webview/cancelAccount',
//                            url: 'http://192.168.8.208:8099/webview/contact',
              // url: 'https://chao.fun',
              title: '如何注销账号',
              showAction: 0,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.fromLTRB(10, 14, 10, 14),
        alignment: Alignment.center,
        child: Text(
          '注销账号',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Notice.removeListenerByEvent("refreshUserInfo");
  }
}
