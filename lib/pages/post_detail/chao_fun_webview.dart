// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/nonetwork_page.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/chao_fun_webview_js_channel.dart';

String _js = '''
  if (!window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler = function () {
          var _callHandlerID = setTimeout(function () { });
          window.flutter_inappwebview._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));
          return new Promise(function (resolve, reject) {
              window.flutter_inappwebview[_callHandlerID] = resolve;
          });
      };
  }
  ''';

class ChaoFunWebView extends StatefulWidget {
  final url;
  final title;
  var showAction;
  bool cookie;
  bool showHeader;
  Function callBack;

  ChaoFunWebView({
    Key key,
    @required this.url,
    this.title,
    this.cookie = true,
    this.showHeader = true,
    this.showAction,
    this.callBack,
  }) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<ChaoFunWebView> {
  final Completer<InAppWebViewController> _controller =
  Completer<InAppWebViewController>();
  InAppWebViewController webView;
  final GlobalKey webViewKey = GlobalKey();
  CookieManager cookieManager = CookieManager.instance();
  String url = "";
  String title = "";
  double progress = 0;
  bool useCookie;

  bool showHeader = true;

  bool isLoading = false;

  bool isError = false;

  var showAction;

  @override
  void initState() {
    super.initState();

    setState(() {
      url = widget.url;
      title = widget.title;
      showHeader = (widget.showHeader != null ? widget.showHeader : true);
      showAction = widget.showAction;
    });
    if (widget.cookie) {
      setCookies();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  // TODO[cijian]: 这里必须只能对 https://chao.fan 做 Cookie 注入
  // 获取cookie
  setCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cookieManager.deleteAllCookies();
    print('取值cookie');
    print(prefs.getString("cookie"));
    if (prefs.getString("cookie") != null) {
      var getcookieList = prefs.getString("cookie").split(';');
      print(getcookieList);
      print(getcookieList.length);
      print(getcookieList[1].runtimeType.toString());
      print(getcookieList[1] == '');
      Uri domain = getDomain();
      if (domain.host == 'cf.qq.cab' || domain.host == 'qq.cab' || domain.host == 'choa.fun' || domain.host == 'tuxun.fun' || domain.host == 'chao.fun' || domain.host == 'www.chao.fun' || domain.host == 'chao.fan' || domain.host == 'www.chao.fun' || domain.host == '47.96.98.153') {
        getcookieList.forEach(
              (item) {
            if (item != '') {
              print('进入cookie设置');
              print(item);
              cookieManager.setCookie(
                url: domain,
                name: item.split("=")[0],
                value: item.split("=")[1],
              );
              cookieManager.setCookie(
                url: Uri.parse('https://chao.fan'),
                name: item.split("=")[0],
                value: item.split("=")[1],
              );
              cookieManager.setCookie(
                url: Uri.parse('https://tuxun.fun'),
                name: item.split("=")[0],
                value: item.split("=")[1],
              );
              cookieManager.setCookie(
                url: Uri.parse('https://choa.fun'),
                name: item.split("=")[0],
                value: item.split("=")[1],
              );
              print(cookieManager);
            }
          },
        );
      }
    }
  }

  Uri getDomain() {
    String tempUrl = url;
    if (!(tempUrl.contains('https://') || tempUrl.contains('http://'))) {
      tempUrl = 'https://' + tempUrl;
    }
    return Uri.parse(tempUrl.split('://')[0] +
        '://' +
        tempUrl.split('://')[1].split('/')[0]);
  }

  @override
  Widget build(BuildContext context) {
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
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: ScreenUtil().setSp(30),
              // fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.

          actions: <Widget>[
            showAction == null
                ? NavigationControls(_controller.future)
                : Container(
              width: 0,
            ),
            // SampleMenu(_controller.future),
          ],
        ),
        preferredSize: Size.fromHeight(showHeader ? 40 : 0),
      ),
      body: Stack(children: <Widget>[
        !isError
            ? InAppWebView(
          key: webViewKey,
          // initialUrl: url,
          initialUrlRequest: URLRequest(url: Uri.parse(url)),
          // initialHeaders: {},
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
            ),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            webView = controller;
            _controller.complete(controller);

            controller.addJavaScriptHandler(
                handlerName: "uploadImage",
                callback: (args) {
                  ChaoFunJsChannelMethods.uploadImage(
                      context, controller);
                });
            controller.addJavaScriptHandler(
                handlerName: "toAppUser",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.navigator(
                      context, 'userMemberPage', args[0]);
                });
            controller.addJavaScriptHandler(
                handlerName: "toAppForum",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.navigator(
                      context, 'forumpage', args[0]);
                });
            controller.addJavaScriptHandler(
                handlerName: "toAppPost",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.navigator(
                      context, 'postdetail', args[0]);
                });
            // 去app首页
            controller.addJavaScriptHandler(
                handlerName: "toAppIndex",
                callback: (args) {
                  print('打印参数$args');
                  Provider.of<CurrentIndexProvide>(context, listen: false)
                      .currentIndex = 0;
                  ChaoFunJsChannelMethods.navigator(context, null, {});
                });
            controller.addJavaScriptHandler(
                handlerName: "toViewPage",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.toViewPage(
                      context, args[0]['url'], args[0]);
                });
            // 去登录
            controller.addJavaScriptHandler(
                handlerName: "toLoginPage",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.navigator(
                      context, 'accoutlogin', {});
                });
            //跳转升级页面
            controller.addJavaScriptHandler(
                handlerName: "toUpgradePage",
                callback: (args) {
                  print('打印参数$args');
                  ChaoFunJsChannelMethods.navigator(
                      context, 'appversion', {});
                });
            // 返回
            controller.addJavaScriptHandler(
                handlerName: "nativeBack",
                callback: (args) {
                  print('打印参数$args');
                  Navigator.pop(context);
                });
            // 反馈建议
            controller.addJavaScriptHandler(
              handlerName: "toAdvice",
              callback: (args) {
                print('打印参数$args');
                var str =
                    '22|炒饭日常|biz/097b352092a352efdc585d5d012b8b3e.png';
                ChaoFunJsChannelMethods.navigator(
                    context, 'imagepublish', {"str": str});
              },
            );
            // 查看大图
            controller.addJavaScriptHandler(
              handlerName: "viewImage",
              callback: (args) {
                print('打印参数$args');
                ChaoFunJsChannelMethods.viewImage(
                    context, args[0]['data'], args[0]['index']);
              },
            );
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
              this.isLoading = true;
              // urlController.text = this.url;
            });
          },
          onLoadStop: (controller, url) async {
            // pullToRefreshController.endRefreshing();
            setState(() {
              this.url = url.toString();
              this.isLoading = false;
              // urlController.text = this.url;
            });

            controller.evaluateJavascript(source: _js);
            // String v = (Provider.of<UserStateProvide>(context, listen: false)
            //         .appVersionInfo)
            // .toString();
            var versionNow = await PackageInfo.fromPlatform();
            var version = versionNow.version.toString();
            controller.evaluateJavascript(
                source: 'callChaoFun("10001","${version}");');
          },
          // onFindResultReceived: (controller, url) async {},
          onProgressChanged:
              (InAppWebViewController controller, int progress) {
            setState(() {
              this.progress = progress / 100;
            });
            print('当前进度 ${progress}');
            if (widget.callBack != null) {
              controller.getHtml().then((value) {
                widget.callBack(value);
                Fluttertoast.showToast(
                  msg: '复制成功~',
                  gravity: ToastGravity.CENTER,
                  // textColor: Colors.grey,
                );
              });
            }
          },
          androidOnPermissionRequest:
              (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url;
            print('wocao');
            print(uri);
            if ([
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              print('22222');
              print(navigationAction.request.url);
              // if (await canLaunch(url)) {
              //   // Launch the App
              //   await launch(
              //     url,
              //   );
              //   // and cancel the request

              // }
              return NavigationActionPolicy.ALLOW;
            } else {
              print('33333');
              print(navigationAction.request.url);
              return NavigationActionPolicy.CANCEL;
            }
            // return NavigationActionPolicy.CANCEL;
          },
          onLoadError: (controller, url, code, message) {
            // pullToRefreshController.endRefreshing();
            // Fluttertoast.showToast(
            //   msg: '异常异常异常异常异常',
            //   gravity: ToastGravity.CENTER,
            // );
            setState(() {
              isError = true;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            print('打印控制台输出');
            print(consoleMessage);
          },
        )
            : NoNetWorkPage(),
        isLoading
            ? Container(
          height: 2,
          child: LinearProgressIndicator(
            backgroundColor: Colors.blue,
            // value: 0.2,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        )
            : Container(),
      ]),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<InAppWebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InAppWebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context,
          AsyncSnapshot<InAppWebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final InAppWebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: KColor.defaultGrayColor,
                size: 20,
              ),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("已经是第一页了")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              padding: const EdgeInsets.all(0.0),
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: KColor.defaultGrayColor,
                size: 20,
              ),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("没有下一页了")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.replay,
                color: KColor.defaultGrayColor,
              ),
              onPressed: !webViewReady
                  ? null
                  : () {
                controller.reload();
              },
            ),

            IconButton(
              icon: const Icon(
                Icons.copy,
                color: KColor.defaultGrayColor,
              ),
              onPressed: !webViewReady
                  ? null
                  : () async {
                Uri uri = await controller.getUrl();
                Clipboard.setData(ClipboardData(text:uri.toString()));
                Fluttertoast.showToast(
                  msg: '已复制链接',
                  gravity: ToastGravity.BOTTOM,
                  // textColor: Colors.grey,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
