import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

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
      try {
        if (!widget.url.startsWith("http:") ||
            !widget.url.startsWith("https:")) {
          cans = false;
        } else {
          cans = true;
        }
      } catch (e) {
        return false;
      }
      switch (state.type) {
        case WebViewState.shouldStart:
          //准备加载
          break;
        case WebViewState.startLoad:
          //开始加载
          break;
        case WebViewState.finishLoad:
          //加载完成
          break;
        case WebViewState.abortLoad:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return cans
        ? WebviewScaffold(
            url: widget.url,
            appBar: PreferredSize(
              child: AppBar(
                brightness: Brightness.light,
                title: Text(widget.title),
                backgroundColor: Colors.white,
              ),
              preferredSize: Size.fromHeight(20),
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
