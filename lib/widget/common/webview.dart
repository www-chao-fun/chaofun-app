import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://www.baidu.com';

class WebView extends StatefulWidget {
  final url;
  final title;
  WebView({Key key, @required this.url, this.title}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();
  var cans = true;
  void initState() {
    super.initState();
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      // try {
      //   if (!widget.url.startsWith("http") || !widget.url.startsWith("https")) {
      //     cans = true;
      //   } else {
      //     cans = false;
      //   }
      // } catch (e) {
      //   return false;
      // }
      if (state.type == WebViewState.shouldStart) {
        //拦截即将展现的页面
        if (!widget.url.startsWith("http")) {
          print('加载结束');
          flutterWebviewPlugin.stopLoading(); //停止加载
          print('禁止非https链接访问');
          return;
        }
      }
      switch (state.type) {
        case WebViewState.shouldStart:
          print('准备加载');
          //准备加载
          break;
        case WebViewState.startLoad:
          print('开始加载');
          //开始加载
          break;
        case WebViewState.finishLoad:
          print('加载完成');
          //加载完成
          break;
        case WebViewState.abortLoad:
          print('222');
          break;
      }
    });
  }

  void doItem() {}

  @override
  Widget build(BuildContext context) {
    print('widget.url');
    print(widget.url);
    return cans
        ? WebviewScaffold(
            url: widget.url,
            appBar: AppBar(
              title: Text(widget.title),
            ),
            withZoom: true, //允许网页缩放
            withLocalStorage: true,
            withJavascript: true, //允许执行 js 代码
          )
        : Center(
            child: Text('错误了'),
          );
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }
}
