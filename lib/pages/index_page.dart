import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_chaofan/pages/chat_home_page.dart';
import 'package:flutter_chaofan/pages/device_info_api.dart';
import 'package:flutter_chaofan/pages/discover.dart';
import 'package:flutter_chaofan/pages/member_page.dart';
import 'package:flutter_chaofan/pages/message_page.dart';
import 'package:flutter_chaofan/pages/nonetwork_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/notice.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/index.dart';
import '../provide/current_index_provide.dart';
import 'empty_page.dart';
import 'home_page.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter/rendering.dart';

import 'package:r_upgrade/r_upgrade.dart';
import 'package:flutter_chaofan/database/comhelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class IndexPage extends StatefulWidget {
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  var platform = '';

  bool isLoading = false;
  // 记录是否更新
  bool showUpdate = false;
  bool ifdown = false;
  bool compareT = false;
  int lastIndex;
  int lastTime;
  var plat;
  var versionInfo;
  var isLogin = false;
  UpgradeMethod upgradeMethod;

  var showAgree = true;

  var db = ComHelper();
  bool isNet = true;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  getVersion() async {
    var response =
        await HttpUtil().get(Api.getLatestAppVersion, parameters: {});
    Map a = response['data'];
    print('getVersion');
    print(a.toString());
    // Map a = {
    //   'android': {
    //     'version': '2.20.7',
    //     'content': '- 支持微博分享\n- 支持发现页中的「更多」\n- 快来升级玩耍吧!\n- 点击更新后需等待点击更',
    //     'force': false,
    //     'action': 'force'
    //   },
    //   'ios': {
    //     'version': '2.17.5',
    //     'content': '- 支持微博分享- 支持发现页中的「更多」快来升级玩耍吧!',
    //     'force': false,
    //     'action': 'check'
    //   }
    // };
    //action 字段，三种情况  force-强制更新, notify-弹窗提示（一天一次）, check-不弹窗更新
    return a;
  }

  String brand;
  void inits() async {
    /// 拉取版本号信息
    var _flatform;
    if (Platform.isAndroid) {
      _flatform = 'android';
    } else {
      _flatform = 'ios';
    }
    var versionMap = await getVersion();
    var versionNow = await PackageInfo.fromPlatform();
    var version = versionNow.version.toString();
    print(
        '---------------------------------------------------------------------------------------------------------------------');
    print('_version是$version');
    print(versionMap.toString());

    if (_flatform == 'android' && version != versionMap['android']['version']) {
      if (compare(version, versionMap['android']['version'])) {
        setState(() {
          versionInfo = versionMap['android'];
        });
        compareTime(versionMap['android']['action']);
      }
    }
    if (_flatform == 'ios' && version != versionMap['ios']['version']) {
      print('版本更新了${version}升级为${versionMap['android']['version']}');
      print('版本更新了${version}升级为${versionMap['android']['content'].length}');
      if (compare(version, versionMap['ios']['version'])) {
        setState(() {
          versionInfo = versionMap['ios'];
        });
        compareTime(versionMap['android']['action']);
      }
    }
  }

  checkIfShowAgree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      setState(() {
        showAgree = (prefs.getString('showAgree') != null ? true : false);
      });
    } else {
      setState(() {
        showAgree = true;
      });
    }
    if (showAgree) {
      initAndroidSDK();
    }
  }

  initAndroidSDK() async {
    _methodChannel.invokeMethod("initAndroidSDK");
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        print('666777888');
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        // deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    print('设备device');
    print(build.device);
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  var id;
  var downpercent = 0.0;
  compare(a, b) {
    var arr = a.split('.');
    var brr = b.split('.');
    if (int.parse(brr[0]) > int.parse(arr[0])) {
      return true;
    } else if (int.parse(brr[0]) == int.parse(arr[0])) {
      if (int.parse(brr[1]) > int.parse(arr[1])) {
        return true;
      } else if (int.parse(brr[1]) == int.parse(arr[1])) {
        if (int.parse(brr[2]) > int.parse(arr[2])) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  static const MethodChannel _methodChannel =
      const MethodChannel('app.chao.fun/main_channel');

  Future<dynamic> platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "push":
        toNavigate(call.arguments);
    }
  }

  void getUserInfo() async {
    var response = await HttpUtil().get(Api.getUserInfo);

    if (response['data'] != null) {
      final bindInfo = await _methodChannel
          .invokeMapMethod<String, dynamic>('getDeviceInfo');
      var _ = HttpUtil().get(Api.bindDevice, parameters: bindInfo);
      setState(() {
        isLogin = true;
      });
    } else {
      final unbindInfo = await _methodChannel
          .invokeMapMethod<String, dynamic>('getDeviceInfo');
      var _ = HttpUtil().get(Api.unbindDevice, parameters: unbindInfo);
    }
  }

  
  void setUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();

    var v = now.toString().substring(0, 10);

    prefs.setString('updateTime', v);
  }

  compareTime(str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var time = prefs.getString('updateTime');
    var now = new DateTime.now();
    var v = now.toString().substring(0, 10);
    if (str == 'check' || (str != 'force' && time == v)) {
      print('弹过了');
      setState(() {
        showUpdate = false;
      });
    } else {
      print('没弹过');
      setState(() {
        showUpdate = true;
      });
    }
    Provider.of<UserStateProvide>(context, listen: false)
        .changeAppVersionInfo(versionInfo);
  }

  @override
  void initState() {
    super.initState();
    checkIfShowAgree();
    _methodChannel.setMethodCallHandler(platformCallHandler);
    lastIndex = -1;
    lastTime = DateTime.now().millisecondsSinceEpoch;
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
        print('监听网络连接变化');
        print(result.toString());
      });
      if (_connectionStatus == 'ConnectivityResult.wifi' ||
          _connectionStatus == 'ConnectivityResult.mobile') {
        //'ConnectivityResult.none'
        Provider.of<UserStateProvide>(context, listen: false)
            .setHasNetWork(true);
        setState(() {
          isNet = true;
        });
      } else {
        Provider.of<UserStateProvide>(context, listen: false)
            .setHasNetWork(false);
      }
    });
    _checkHasData();
    getUserInfo();
    
    print('查看设备');

    if (Platform.isIOS) {
      //ios相关代码
      platform = 'ios';
    } else if (Platform.isAndroid) {
      //android相关代码
      platform = 'android';
    }
    setState(() {
      plat = platform;
    });
    inits();
  }

  void Devinfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('ooooooooooooooooooooooooo');
    print(androidInfo.manufacturer); // 产品/硬件的制造商。
    print(androidInfo.device); //设备名称
    print(androidInfo.model); //最终产品的最终用户可见名称。
    print(androidInfo.androidId); // Android硬件设备ID。
    print(androidInfo.board); //设备基板名称
    print(androidInfo.bootloader); //获取设备引导程序版本号
    print(androidInfo.product); //整个产品的名称
  }

  void toNavigate(Map args) {
    String u = '';

    String url = 'https://chao.fun';
    String title = '炒饭 - 分享奇趣、发现世界';

    if (args.containsKey("url")) {
      url = args['url'].toString();
    } else {
      return;
    }

    if (args.containsKey("title")) {
      title = args['title'].toString();
    }

    var arguments = {};

    var nativePush = false;

    if (url.startsWith("https://chao.fun/") ||
        url.startsWith("https://www.chao.fun/") ||
        url.startsWith("http://chao.fun") ||
        url.startsWith("http://www.chao.fun")) {
      var newUrl = url
          .replaceAll("https://chao.fun/", "")
          .replaceAll("https://www.chao.fun/", "")
          .replaceAll("http://chao.fun", "")
          .replaceAll("http://www.chao.fun", "");

      var a = newUrl.split('/');
      print('打印出来；$a');
      if (a.length >= 2 && (a[0] == 'f' || a[0] == 'p' || a[0] == 'user')) {
        nativePush = true;
        String start = a[0];
        String end = a[1];
        switch (start) {
          case "f":
            u = '/forumpage';
            arguments = {'forumId': end};
            break;
          case "user":
            u = '/userMemberPage';
            arguments = {'userId': end};
            break;
          case "p":
            u = '/postdetail';
            arguments = {'postId': end};
            break;
        }
        Navigator.pushNamed(context, u, arguments: arguments);
      } else if (a[0] == "route" && a[2] != null && a[2] == 'message') {
        nativePush = true;
        Provider.of<CurrentIndexProvide>(context, listen: false).setIndex(3);
      }
    }

    if (!nativePush) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaoFunWebView(
            url: url,
            title: title,
            showAction: 0,
            cookie: true,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  //平台消息是异步的，所以我们用异步方法初始化。
  Future<Null> initConnectivity() async {
    String connectionStatus;
    //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      print('获取网络连接状态');
      print(connectionStatus);
      if (connectionStatus == 'ConnectivityResult.wifi' ||
          connectionStatus == 'ConnectivityResult.mobile') {
        Provider.of<UserStateProvide>(context, listen: false)
            .setHasNetWork(true);
      } else {
        Provider.of<UserStateProvide>(context, listen: false)
            .setHasNetWork(false);
      }
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // 如果在异步平台消息运行时从树中删除了该小部件，
    // 那么我们希望放弃回复，而不是调用setstate来更新我们不存在的外观。
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
      print(connectionStatus);
    });
  }

  refreshScreens() async {
    String connectionStatus;
    //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      print('获取网络连接状态');
      print(connectionStatus);
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // 如果在异步平台消息运行时从树中删除了该小部件，
    // 那么我们希望放弃回复，而不是调用setstate来更新我们不存在的外观。
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
      print(connectionStatus);
    });
  }

  // getBottomNavigationBarItem() {
  //   var widget = Consumer<UserStateProvide>(builder: (context, user, child) {
  //     if (user.ISLOGIN) {
  //       return  BottomNavigationBarItem(
  //           icon: Image.asset(
  //             'assets/images/_icon/011.png',
  //             width: 24,
  //             height: 24,
  //           ),
  //           activeIcon: Image.asset(
  //             'assets/images/_icon/012.png',
  //             width: 24,
  //             height: 24,
  //           ),
  //           label: '首页');
  //     } else {
  //       return  BottomNavigationBarItem(
  //           icon: Image.asset(
  //             'assets/images/_icon/qz_1.png',
  //             width: 24,
  //             height: 24,
  //           ),
  //           activeIcon: Image.asset(
  //             'assets/images/_icon/qz.png',
  //             width: 24,
  //             height: 24,
  //           ),
  //           label: '全站');
  //     }
  //   });
  //   return widget;
  // }


  final List<Widget> tabBodies = [
    HomePage(),
    DiscoverPage(),
    EmptyPage(),
    ChatHomePage(),
    // // TestVideo(),
    MemberPage()
  ];
  asd(context) {
    print('ooooo');
    setState(() {
      _connectionStatus = '';
    });
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => IndexPage()),
      (route) => route == null,
    );
  }

  _checkHasData() async {
    try {
      var a = await db.hasData();
      if (a.length == 0 &&
          !Provider.of<UserStateProvide>(context, listen: false).hasNetWork) {
        setState(() {
          isNet = false;
        });
      }
    } catch (e) {
      setState(() {
        isNet = true;
      });
    }
  }

  List<Widget> tabNetWorkNone() {
    return [
      NoNetWorkPage(callBack: asd),
      NoNetWorkPage(callBack: asd),
      NoNetWorkPage(callBack: asd),
      NoNetWorkPage(callBack: asd),
      NoNetWorkPage(callBack: asd),
    ];
  }

  void toCheckOut(v) {
    setState(() {});
  }

  void delays() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 5000));
    // if failed,use refreshFailed()

    print('开始调整111');
    Navigator.pushNamed(
      context,
      '/accoutlogin',
    );
  }

  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    // Provide.value<UserStateProvide>(context).setIndexDialog();
    Provider.of<UserStateProvide>(context, listen: false).setIndexDialog();

    final List<BottomNavigationBarItem> bottomTabs = [
      isLogin ?
      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/_icon/011.png',
            width: 24,
            height: 24,
          ),
          activeIcon:Image.asset(
            'assets/images/_icon/012.png',
            width: 24,
            height: 24,
          ),
          label: '首页'
      ): BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/_icon/qz_1.png',
            width: 24,
            height: 24,
          ),
          activeIcon:Image.asset(
            'assets/images/_icon/qz.png',
            width: 24,
            height: 24,
          ),
          label: '全站'),
      // getBottomNavigationBarItem(),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/_icon/021.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/_icon/022.png',
          width: 24,
          height: 24,
        ),
        label: KString.categoryTitle,
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/_icon/push.png',
          width: 35,
          height: 35,
        ),
        activeIcon: Image.asset(
          'assets/images/_icon/push.png',
          width: 35,
          height: 35,
        ),
        label: KString.gameTitle,
        //分类
      ),
      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/_icon/052.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/images/_icon/051.png',
            width: 24,
            height: 24,
          ),
          label: KString.chatTitle
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/images/_icon/041.png',
          width: 24,
          height: 24,
        ),
        activeIcon: Image.asset(
          'assets/images/_icon/042.png',
          width: 24,
          height: 24,
        ),
        label:
        KString.shoppingCartTitle,)
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10.0, //选中时的大小
        unselectedFontSize: 10.0,
        unselectedItemColor: Color.fromRGBO(167, 165, 172, 1),
        selectedItemColor: Color.fromRGBO(33, 29, 47, 1),
        currentIndex: Provider.of<CurrentIndexProvide>(context).currentIndex,
        items: bottomTabs,
        onTap: (index) {
          print('------------------------------------------------------------');
          FocusScope.of(this.context).requestFocus(FocusNode());
          if (index == 0) {
//              双击刷新判断
            if (DateTime.now().millisecondsSinceEpoch - lastTime < 500 &&
                lastIndex == index) {
              Provider.of<UserStateProvide>(context, listen: false)
                  .setDoubleTap(true);
            } else {
              Provider.of<CurrentIndexProvide>(context, listen: false)
                  .currentIndex = index;
            }
          } else if (index == 2) {
            // _pickImage(context);
            if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
              // Navigator.pushNamed(context, '/submitpage', arguments: {});
              Navigator.pushNamed(context, '/forumlist');
            } else {
              Navigator.pushNamed(
                context,
                '/accoutlogin',
              );
            }
          } else {
            if (index == 4) {
              refreshUserInfo(context);
            }
            Provider.of<CurrentIndexProvide>(context, listen: false)
                .currentIndex = index;

          }
          setState(() {
            lastIndex = index;
            lastTime = DateTime.now().millisecondsSinceEpoch;
          });
        },
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: Provider.of<CurrentIndexProvide>(context, listen: false)
                .currentIndex,
            children: !isNet ? tabNetWorkNone() : tabBodies,
            // children: tabBodies,
          ),
          !(showAgree != null && showAgree)
              ? Positioned(
                  top: ScreenUtil().setHeight(400),
                  left: ScreenUtil().setWidth(75),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      border: Border.all(
                          color: Color.fromRGBO(153, 153, 153, 0.3),
                          width: 0.5),
                    ),
                    width: ScreenUtil().setWidth(600),
                    height: ScreenUtil().setHeight(600),
                    child: Column(
                      children: [
                        Container(
                          height: ScreenUtil().setHeight(80),
                          alignment: Alignment.center,
                          child: Text(
                            '服务条款和隐私保护提示',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: BorderRadius.only(
                            //   topLeft: Radius.circular(10),
                            //   topRight: Radius.circular(10),

                            // ),
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(153, 153, 153, 0.3),
                                width: 0.5,
                              ),
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                        Expanded(
                          // child: ChaoFunWebView(
                          //   url: 'https://chao.fun/webview/agreement',
                          //   title: '',
                          //   showHeader: false,
                          // ),
                          // child: InAppWebView(
                          //     key: webViewKey,
                          //     // initialUrl: url,
                          //     initialUrlRequest: URLRequest(
                          //         url: Uri.parse(
                          //             'https://chao.fun/webview/agreement')),
                          //     // initialHeaders: {},
                          //     initialOptions: InAppWebViewGroupOptions(
                          //       crossPlatform: InAppWebViewOptions(
                          //         useShouldOverrideUrlLoading: true,
                          //         mediaPlaybackRequiresUserGesture: false,
                          //       ),
                          //       android: AndroidInAppWebViewOptions(
                          //         useHybridComposition: true,
                          //       ),
                          //       ios: IOSInAppWebViewOptions(
                          //         allowsInlineMediaPlayback: true,
                          //       ),
                          //     ),
                          //     onWebViewCreated:
                          //         (InAppWebViewController controller) {}),
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(24),
                              right: ScreenUtil().setWidth(24),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '欢迎使用炒饭超Fun！',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color.fromRGBO(103, 103, 103, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '在使用我们的产品和服务前，请您先阅读并了解',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color.fromRGBO(103, 103, 103, 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChaoFunWebView(
                                            url:
                                                'https://chao.fun/webview/useragree', //'https://chao.fun/webview/agreement',
                                            title: '用户服务协议',
                                            showAction: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '<< 用户服务协议 >>',
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(30),
                                          color:
                                              Color.fromRGBO(64, 158, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChaoFunWebView(
                                            url:
                                                'https://chao.fun/webview/agreement', //'https://chao.fun/webview/agreement',
                                            title: '隐私政策',
                                            showAction: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '<< 隐私政策 >>',
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(30),
                                          color:
                                              Color.fromRGBO(64, 158, 255, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '我们将严格按照上述协议为您提供服务，保护您的信息安全，点击“同意”即表示您已阅读并同意全部条款，可以继续使用我们的产品和服务',
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Color.fromRGBO(103, 103, 103, 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                            height: ScreenUtil().setHeight(80),
                            padding: EdgeInsets.only(left: 30, right: 30),
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: Border(
                                  top: BorderSide(
                                color: Color.fromRGBO(153, 153, 153, 0.3),
                                width: 0.5,
                              )),
                            ),
                            margin: EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                MaterialButton(
                                  color: Colors.white,
                                  child: new Text(
                                    '拒绝并退出',
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                    ),
                                  ),
                                  minWidth: ScreenUtil().setWidth(200),
                                  height: ScreenUtil().setWidth(70),
                                  padding: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  onPressed: () async {
                                    pop();
                                  },
                                ),
                                MaterialButton(
                                  color: Color.fromRGBO(255, 147, 0, 1),
                                  child: new Text(
                                    '同意',
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                    ),
                                  ),
                                  minWidth: ScreenUtil().setWidth(200),
                                  height: ScreenUtil().setWidth(70),
                                  padding: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString('showAgree', '1');
                                    initAndroidSDK();
                                    setState(() {
                                      showAgree = true;
                                    });
                                  },
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                )
              : Text(''),
          showUpdate
              ? toShowUp(context)
              : Container(
                  height: 0,
                ),
        ],
      ),
    );

//     return Consumer<CurrentIndexProvide>(
//       builder: (context, val, child) {
//         // 取到当前索引状态值
//         int currentIndex =
//             Provider.of<CurrentIndexProvide>(context).currentIndex;

//         return Scaffold(
//           backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
//           bottomNavigationBar: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             selectedFontSize: 10.0, //选中时的大小
//             unselectedFontSize: 10.0,
//             unselectedItemColor: Color.fromRGBO(167, 165, 172, 1),
//             selectedItemColor: Color.fromRGBO(33, 29, 47, 1),
//             currentIndex: currentIndex,
//             items: bottomTabs,
//             onTap: (index) {
//               print(
//                   '------------------------------------------------------------');
//               if (index == 0) {
// //              双击刷新判断
//                 if (DateTime.now().millisecondsSinceEpoch - lastTime < 500 &&
//                     lastIndex == index) {
//                   Provider.of<UserStateProvide>(context).setDoubleTap(true);
//                 } else {
//                   Provider.of<CurrentIndexProvide>(context).changeIndex(index);
//                 }
//               } else if (index == 2) {
//                 _pickImage(context);
//               } else {
//                 Provider.of<CurrentIndexProvide>(context).changeIndex(index);
//               }
//               lastIndex = index;
//               lastTime = DateTime.now().millisecondsSinceEpoch;
//             },
//           ),
//           body: Stack(
//             children: [
//               IndexedStack(
//                 index: currentIndex,
//                 children: _connectionStatus == 'ConnectivityResult.none'
//                     ? tabNetWorkNone()
//                     : tabBodies,
//               ),
//               showUpdate
//                   ? toShowUp(context)
//                   : Container(
//                       height: 0,
//                     ),
//             ],
//           ),
//         );
//       },
//     );
  }

  toShowUp(context) {
    Provider.of<UserStateProvide>(context, listen: false)
        .changeAppVersionInfo(versionInfo);
    Provider.of<UserStateProvide>(context, listen: false).setIndexDialog();
    if (versionInfo['action'] != 'check') {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Center(
            child: Container(
              width: ScreenUtil().setWidth(550),
              height: ScreenUtil().setWidth(750),
              padding: EdgeInsets.only(bottom: 10, top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    padding: EdgeInsets.only(top: 10, bottom: 0),
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
                      '新版本 ' + versionInfo['version'],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      // height: ScreenUtil().setWidth(400),
                      // color: Colors.red,
                      // child: Text(
                      //   versionInfo['content'] != null
                      //       ? versionInfo['content']
                      //       : '暂无更新内容',
                      //   style: TextStyle(
                      //     height: 1.5,
                      //     fontSize: ScreenUtil().setSp(28),
                      //     color: Color.fromRGBO(97, 101, 105, 1),
                      //   ),
                      // ),
                      child: SingleChildScrollView(
                        child: Text(
                          versionInfo['content'] != null
                              ? versionInfo['content']
                              : '暂无更新内容',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: ScreenUtil().setSp(28),
                            color: Color.fromRGBO(97, 101, 105, 1),
                          ),
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
                      mainAxisAlignment: versionInfo['action'] == 'notify'
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      children: [
                        versionInfo['action'] == 'notify'
                            ? MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: BorderSide(
                                    color: Color.fromRGBO(255, 147, 0, 1),
                                  ),
                                ),
                                elevation: 0,
                                minWidth: ScreenUtil().setWidth(200),
                                color: Colors.white,
                                textColor: Colors.black,
                                child: new Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Color.fromRGBO(153, 153, 153, 1),
                                  ),
                                ),
                                onPressed: () async {
                                  // ...
                                  setState(() {
                                    showUpdate = false;
                                  });
                                  setUpdateTime();
                                  // Provide.value<UserStateProvide>(context)
                                  //     .changeAppVersionInfo(versionInfo);
                                },
                              )
                            : SizedBox(
                                width: 0,
                              ),
                        MaterialButton(
                          color: !ifdown
                              ? Color.fromRGBO(255, 147, 0, 1)
                              : Colors.grey,
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
                                  print(info.percent);
                                  setState(() {
                                    downpercent = info.percent / 100;
                                  });

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
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _pushItem(context, item) {
    return Container(
      // padding: EdgeInsets.fromLTRB(
      //   ScreenUtil().setWidth(40),
      //   ScreenUtil().setWidth(30),
      //   ScreenUtil().setWidth(40),
      //   ScreenUtil().setWidth(20),
      // ),
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (Provider.of<UserStateProvide>(context, listen: false).ISLOGIN) {
            if (item['type'] == 'link') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/linkpublish');
            } else if (item['type'] == 'image') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/imagepublish');
            } else if (item['type'] == 'textarea') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/articlepublish');
            } else if (item['type'] == 'vote') {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/votepublish');
            }
          } else {
            Navigator.pushNamed(
              context,
              '/accoutlogin',
            );
          }
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(50)),
                  // color: Colors.blue,
                ),
                // padding: EdgeInsets.fromLTRB(
                //   ScreenUtil().setWidth(20),
                //   ScreenUtil().setWidth(20),
                //   ScreenUtil().setWidth(20),
                //   ScreenUtil().setWidth(20),
                // ),
                margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
                child: Image.asset(
                  item['icon'],
                  width: ScreenUtil().setWidth(92),
                  height: ScreenUtil().setWidth(92),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                item['label'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setHeight(384),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Container(
              //   // color: Colors.blue,
              //   height: 40,
              //   margin: EdgeInsets.only(bottom: 10, top: 0),
              //   alignment: Alignment.center,
              //   child: Text(
              //     '我要发布',
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: KSet.pubList.map((item) {
                  return _pushItem(context, item);
                }).toList(),
              ),
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(700),
                    height: ScreenUtil().setWidth(70),
                    // color: Colors.blue,
                    child: Image.asset(
                      'assets/images/_icon/close.png',
                      width: ScreenUtil().setWidth(80),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

refreshUserInfo(BuildContext context) async {
  Notice.send('refreshUserInfo', null);
}