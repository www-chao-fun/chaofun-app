import 'dart:ui';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/common/pageFade.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

//自定义的路由方法
class JsChannelMethods {
  static viewImage(context, data, index) {
    // Navigator.of(context).push();
    Navigator.of(context).push(
      CustomRoute(
        JhPhotoAllScreenShow(
          imgDataArr: data,
          index: index,
        ),
      ),
    );
  }
  static getCookie(_controller) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookie = prefs.getString("cookie");
    _controller?.evaluateJavascript('callJS("$cookie")')?.then((result) {
      // You can handle JS result here.
      print('33333');
      print(result);
    });
  }

  static navigator(context, url, params) {
    Navigator.pushNamed(context, '/' + url);
  }
}
