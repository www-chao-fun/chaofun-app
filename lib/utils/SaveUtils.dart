


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

save(context, fileNames, type) async {
  print('save file');
  print('save filename : ' + fileNames);
  var appDocDir = await getTemporaryDirectory();

  for (var fileName in fileNames.split(",")) {
    String savePath = appDocDir.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() +  fileName;
    String downloadUrl = KSet.imgOrigin + fileName;
    if (downloadUrl.endsWith('.webp')) {
      savePath = savePath.replaceAll('.webp', '.png');
      downloadUrl =downloadUrl.replaceAll('.webp', '.webp?x-oss-process=image/format,png');
    }
    await Dio().download(downloadUrl, savePath);
    final result = await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
    if (type == 1) {
      Navigator.of(context).pop();
    }
    // 清理文件
    File(savePath).delete();
  }

  // print(result);
  if (Platform.isIOS) {
    Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
  } else {
    bool permission = await requestPermission();
    if (permission) {
      Fluttertoast.showToast(msg: '已保存到相册', toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(msg: '没有相册或存储权限', toastLength: Toast.LENGTH_LONG);
    }
  }

}

String getFileName(String url) {
  var splitList = url.split("/");
  var subPrefix = splitList[splitList.length -1];
  return subPrefix.split("?")[0];
}


Future<bool> requestPermission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  final info = statuses[Permission.storage].toString();
  if (info.contains("granted")) {
    return Future.value(true);

  } else {
  return Future.value(false);
  }
  // Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  // PermissionStatus.granted   denied
  // final info = statuses[Permission.storage].toString();
  // print(info);PermissionHandler
}