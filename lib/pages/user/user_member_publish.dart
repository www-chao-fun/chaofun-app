import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/service/home_service.dart';

import 'package:flutter_chaofan/widget/content/content_widget.dart';
import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';

class UserMemberPublish extends StatefulWidget {
  var arguments;
  UserMemberPublish({Key key, this.arguments}) : super(key: key);
  _UserMemberPublishState createState() => _UserMemberPublishState();
}

class _UserMemberPublishState extends State<UserMemberPublish> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return Text('Item$index');
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: 50,
    );
  }
}
