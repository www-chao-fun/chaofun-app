import 'dart:ui';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/common/pageFade.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:images_picker/images_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

//自定义的路由方法
Future getImage(_controller, isTakePhoto) async {
  // Navigator.pop(context);
  // var image = await ImagePicker.pickImage(
  //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
  List res = await ImagesPicker.pick(
    count: 1,
    pickType: PickType.image,
    // cropOpt: CropOption(aspectRatio: CropAspectRatio.wh16x9),
  );
  _upLoadImage(_controller, File(res[0].path));
}

//上传图片
_upLoadImage(_controller, File image) async {
  String path = image.path;
  var name = path.substring(path.lastIndexOf("/") + 1, path.length);
  FormData formdata = FormData.fromMap({
    "file": await MultipartFile.fromFile(path, filename: name),
    "fileName": name
  });
  Dio dio = new Dio();
  var res = await dio.post("https://choa.fun/api/upload_image", data: formdata);
  print('上传结束');
  print(res);
  print(res.data['data']);
  if (res.data['success']) {
    ChaoFunJsChannelMethods.setUploadImage(_controller, res.data['data']);
  } else {}
}

class ChaoFunJsChannelMethods {
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

  static uploadImage(context, _controller) {
    getImage(_controller, false);
  }

  static setUploadImage(_controller, src) {
    _controller
        ?.evaluateJavascript(source: 'setUploadImage("$src")')
        ?.then((result) {
      // You can handle JS result here.
      print('33333');
      print(result);
    });
  }

  // static toAppUser(context, controller, args) {
  //   Navigator
  // }

  static getCookie(_controller) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookie = prefs.getString("cookie");
    _controller
        ?.evaluateJavascript(source: 'callJS("$cookie")')
        ?.then((result) {
      // You can handle JS result here.
      print('33333');
      print(result);
    });
  }

  static navigator(context, url, params) {
    if (url != null) {
      if (params != null) {
        Navigator.pushNamed(context, '/' + url, arguments: params);
      } else {
        Navigator.pushNamed(context, '/' + url);
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => IndexPage()),
        (route) => route == null,
      );
    }
  }

  static toViewPage(context, url, params) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChaoFunWebView(
          url: url,
          title: (params != null && params['title'] != null)
              ? params['title']
              : '外部链接',
          showAction: 0,
          showHeader: url.contains('https://chao.fan') || url.contains('https://tuxun.fun') || url.contains('https://choa.fun')
              ? (params['showHeader'] == null ? false : params['showHeader'])
              : true,
          cookie: url.contains('https://tuxun.fun') || url.contains('https://choa.fun') || url.contains('https://chao.fan') || url.contains('https://chao.fun') || url.contains('http://47.96.98.153') ? true : false,
        ),
      ),
    );
  }
}
