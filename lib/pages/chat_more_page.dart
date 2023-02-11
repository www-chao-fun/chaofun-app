
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_chaofan/widget/im/more_item_card.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:images_picker/images_picker.dart';

import 'chat_home_page.dart';

class ChatMorePage extends StatefulWidget {
  final int index;
  final int id;
  final int type;
  final double keyboardHeight;

  ChatMorePage({this.index = 0, this.id, this.type, this.keyboardHeight});

  @override
  _ChatMorePageState createState() => _ChatMorePageState();
}

class _ChatMorePageState extends State<ChatMorePage> {
  List data = [
    {"name": "相册", "icon": "assets/images/chat/ic_details_photo.webp"},
    {"name": "拍摄", "icon": "assets/images/chat/ic_details_camera.webp"},
  ];

  List dataS = [
  ];


  action(String name) async {
    List ims = null;
    if (name == '相册') {
      ims = await ImagesPicker.pick(
        count:9,
        pickType: PickType.image, //maxSize: 20480,
      );
    } else if (name == '拍摄') {
      ims = await ImagesPicker.openCamera(
        pickType: PickType.image,
        maxSize: 1,//quality: 0.8, maxSize: 20480
      );
    }

    if (ims == null) {
      return;
    }

    setState(() {
      ims.forEach((e) {
        _upLoadImage(File(e.path));
      });

//        imagesUrl.addAll(new List(ims.length));
    });


  }

  //上传图片
  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });

    Dio dio = new Dio();
    String imageUrl = null;
    var response =
    await dio.post("https://choa.fun/api/upload_image", data: formdata);
    print('上传结束');
    print(response);
    print(response.data['data']);
    if (response.data['success']) {
        imageUrl = response.data['data'];
    } else {
      setState(() {
        imageUrl == null;
      });
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (imageUrl != null) {
      allChannel.sink.add(
          "{\"scope\": \"chat\", \"data\": {\"type\": \"image\", \"channelId\": " +
              widget.id.toString() + ", \"content\": \"" + imageUrl + "\"}}");
    }
  }

  itemBuild(data) {
    return new Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.only(bottom: 20.0),
      child: new Wrap(
        runSpacing: 10.0,
        spacing: 10,
        children: List.generate(data.length, (index) {
          String name = data[index]['name'];
          String icon = data[index]['icon'];
          return new MoreItemCard(
            name: name,
            icon: icon,
            keyboardHeight: widget.keyboardHeight,
            onPressed: () => action(name),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 0) {
      return itemBuild(data);
    } else {
      return itemBuild(dataS);
    }
  }
}
