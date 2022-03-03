import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/user/at_user_list.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/items/bottom_widget.dart';
import 'package:flutter_chaofan/widget/items/comment_widget.dart';
import 'package:flutter_chaofan/widget/items/predict_widget.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_chaofan/widget/items/vote_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:flutter_umeng_plugin/flutter_umeng_plugin.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/widget/items/link_widget.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostItemWidget extends StatefulWidget {
  String imgurl;
  Map data;
  Map postInfo;
  PostItemWidget({Key key, this.imgurl, this.data, this.postInfo})
      : super(key: key);
  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget>
    with AutomaticKeepAliveClientMixin {
  var data;
  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(10),
        right: ScreenUtil().setWidth(10),
      ),
      child: (data['article'].startsWith('<p') ||
              data['article'].startsWith('<ol') ||
              data['article'].startsWith('<ul') ||
              data['article'].startsWith('<div') ||
              data['article'].startsWith('<h') ||
              data['article'].startsWith('<br'))
    ? Html(
              data: data['article'],
              style: {
                'p': Style(
                  fontSize: FontSize.large,
                  lineHeight: LineHeight(1.5),
                  whiteSpace: WhiteSpace.PRE,
                ),
              },
              onImageTap: (src, _, __, ___) {
                Navigator.of(context).push(
                  FadeRoute(
                    page: JhPhotoAllScreenShow(
                      imgDataArr: [src],
                      index: 0,
                    ),
                  ),
                );
                print(src);
              },
              onLinkTap: (src, _, __, ___) {
                toNavigate(src, context);
                print(src);
              },
            )
          : Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5),
              child: Text(
                data['article'],
                style: TextStyle(
                  height: 1.6,
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
    );
  }

  void toNavigate(url, context) {
    String u = '';

    // String url = 'https://chao.fun';
    String title = '炒饭 - 分享奇趣、发现世界';

    // if (args.containsKey("url")) {
    //   url = args['url'].toString();
    // } else {
    //   return;
    // }

    // if (args.containsKey("title")) {
    //   title = args['title'].toString();
    // }

    // var arguments = {};

    var nativePush = false;
    var arguments;

    if (url.startsWith("https://chao.fun/") ||
        url.startsWith("https://www.chao.fun") ||
        url.startsWith("http://chao.fun") ||
        url.startsWith("http://www.chao.fun") ||
        url.startsWith("https://chao.fun")) {
      var newUrl = url
          .replaceAll("https://chao.fun/", "")
          .replaceAll("https://www.chao.fun/", "")
          .replaceAll("http://chao.fun", "")
          .replaceAll("http://www.chao.fun", "");

      var a = newUrl.split('/');
      print('不一样');
      print(a);
      nativePush = true;
      if (a.length >= 2 && (a[0] == 'f' || a[0] == 'p' || a[0] == 'user')) {
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
//        Future.delayed(Duration(seconds: 1), () {
        if (u != '') {
          print('u');
          print(u);
          Navigator.pushNamed(context, u, arguments: arguments);
        } else {}

//        });
      } else {
        print('跳转首页');
        if (url == 'https://www.chao.fun' ||
            url == 'http://www.chao.fun' ||
            url == 'https://chao.fun' ||
            url == 'http://chao.fun' ||
            url == 'https://www.chao.fun/' ||
            url == 'http://www.chao.fun/' ||
            url == 'https://chao.fun/' ||
            url == 'http://chao.fun/') {
          Provider.of<CurrentIndexProvide>(context, listen: false)
              .currentIndex = 0;
          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => IndexPage()),
            (route) => route == null,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChaoFunWebView(
                url: url,
                title: title,
                showHeader: true,
                cookie: true,
              ),
            ),
          );
        }
      }
    }

    if (!nativePush) {
      title = '外部链接';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaoFunWebView(
            url: url,
            title: title,
            showHeader: true,
            cookie: true,
          ),
        ),
      );
    }
  }
}
