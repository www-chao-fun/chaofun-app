import 'package:flutter_chaofan/pages/hometabs/all_tab_page.dart';
import 'package:flutter_chaofan/pages/hometabs/recommend_tab_page.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/hometop/topsearch_widget.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
// 刷新组件
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/provide/user.dart';

import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmptyPage extends StatefulWidget {
  _EmptyPageState createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    return new InkWell();
  }

}
