import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/widget/common/customNavgator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://www.baidu.com';

class LinkWidget extends StatefulWidget {
  var item;
  LinkWidget({Key key, this.item}) : super(key: key);

  @override
  _LinkWidgetState createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  var item;
  var urlvali;

  // LinkWidget({Key key, this.item}) : super(key: key);
// FlutterWebviewPlugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onProgressChanged;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = TextEditingController(text: selectedUrl);

  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    urlvali = true;
    flutterWebViewPlugin.close();

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
      var url = selectedUrl;
      if (!url.startsWith("http") || !url.startsWith("https")) {
        setState(() {
          urlvali = false;
        });
      }
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        // setState(() {
        //   _history.add('onUrlChanged: $url');
        // });
        if (!url.startsWith("http") || !url.startsWith("https")) {
          setState(() {
            urlvali = false;
          });
        }
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        // setState(() {
        //   _history.add('onProgressChanged: $progress');
        // });
      }
    });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        // setState(() {
        //   _history.add('Scroll in Y Direction: $y');
        // });
      }
    });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        // setState(() {
        //   _history.add('Scroll in X Direction: $x');
        // });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        // setState(() {
        //   _history.add('onStateChanged: ${state.type} ${state.url}');
        // });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        if (error.code == '-10') {
          CustomNavigatorObserver().navigator.pushNamed("/test");
          // CustomNavigatorObserver
          setState(() {
            urlvali = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  Widget Leading(item) {
    if (item['cover'] == null) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Container(
          color: Color.fromRGBO(245, 245, 245, 1),
          width: 112,
          height: 80,
          margin: EdgeInsets.only(left: 14),
          child: Icon(
            Icons.link,
            size: 50,
          ),
        ),
      );
    } else {
      return Container(
        width: 112,
        height: 80,
        margin: EdgeInsets.only(left: 14),
        constraints: BoxConstraints(
            // maxWidth: ScreenUtil().setWidth(250),

            ),
        decoration: BoxDecoration(
            // border:
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          child: FadeInImage.assetNetwork(
            placeholder: "assets/images/img/place.png",
            image: KSet.imgOrigin +
                item['cover'] +
                (item['cover'].contains('.ico')
                    ? ''
                    : '?x-oss-process=image/format,webp/quality,q_75/resize,h_100'),
            fit: BoxFit.cover,
            imageErrorBuilder: (context, error, stackTrace) {
              // TODO 图片加载错误后展示的 widget
              // print("---图片加载错误---");
              // 此处不能 setState
              return Icon(Icons.error);
            },
          ),
        ),
      );
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    item = widget.item;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        bottom: ScreenUtil().setHeight(0),
      ),
      child: InkWell(
        onTap: () {
          print('123');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChaoFunWebView(
                url: item['link'],
                // url: 'http://192.168.8.208:8099/webview/activity/index',
                title: item['title'],
                cookie: true,
                showHeader: true,
              ),
            ),
          );
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => WebViewExample(
          //         url: item['link'], title: item['title'], showAction: null),
          //   ),
          // );
          // _launchURL(item['link']);
          print("预览");
        },
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: item['link']));
          Fluttertoast.showToast(
            msg: '已复制链接',
            gravity: ToastGravity.BOTTOM,
            // textColor: Colors.grey,
          );
        },
        child: Container(
          decoration: BoxDecoration(
              // border: Border.all(width: 0.5, color: KColor.defaultBorderColor),
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  // color: Colors.blue,
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      color: Color.fromRGBO(33, 29, 47, 1),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 0.0),
                ),
              ),
              Leading(item)
            ],
          ),
          // child: ListTile(
          //   leading: Leading(item),
          //   title: Text(
          //     item['title'],
          //     style: TextStyle(
          //       fontSize: ScreenUtil().setSp(30),
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 0.0),
          // ),
        ),
      ),
    );
  }
}
