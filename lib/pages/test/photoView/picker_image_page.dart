import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../config/index.dart';
import '../../../service/http_servicenew.dart';

class PhotoApp extends StatefulWidget {
  _PhotoAppState createState() => _PhotoAppState();
}

class _PhotoAppState extends State<PhotoApp> {
  List<File> _images = [];

  Future getImage(isTakePhoto) async {
    Navigator.pop(context);

    var image = await ImagePicker.pickImage(
        source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
    _upLoadImage(image);
    setState(() {
      _images.add(image);
    });
  }

  Future getVideo(isTakeVideo) async {
    Navigator.pop(context);

    var image = await ImagePicker.pickVideo(
        source: isTakeVideo ? ImageSource.camera : ImageSource.gallery);
    _upLoadImage(image);
    print('拍摄视频：' + image.toString());
    setState(() {
      _images.add(image);
    });
  }

/*选取视频*/
  _getVideo() async {
    var image = await ImagePicker.pickVideo(source: ImageSource.gallery);
    print('选取视频：' + image.toString());
  }

/*拍摄视频*/
  _takeVideo() async {
    var image = await ImagePicker.pickVideo(source: ImageSource.camera);
    print('拍摄视频：' + image.toString());
  }

//上传图片
  _upLoadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    print(image);
    FormData formdata = FormData.fromMap(
        {"file": await MultipartFile.fromFile(path, filename: name)});

    // Dio dio = new Dio();
    // var respone = await dio.post("http://192.168.8.193:7001/app/uploadImage",
    //     data: formdata);
    request('uploadImage', formData: formdata).then((value) {
      Fluttertoast.showToast(
        msg: '图片上传成功',
        gravity: ToastGravity.CENTER,
        textColor: Colors.grey,
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('拍照APP开发'),
      ),
      body: Center(
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: _getImages(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: '选择图片',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  // 底部弹框
  _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        child: Column(
          children: <Widget>[
            _item('拍照', true, 'image'),
            _item('从相册选择', false, 'image'),
            _item('拍照视频', true, 'video'),
            _item('从相册选择视频', false, 'video'),
          ],
        ),
      ),
    );
  }

// 底部弹框 显示列表内容
  _item(String title, bool isTakePhoto, String type) {
    return GestureDetector(
      // 卡片列表控件
      child: ListTile(
        leading: Icon(isTakePhoto ? Icons.camera_alt : Icons.photo_library),
        title: Text(title),
        onTap: () {
          if (type == 'image') {
            getImage(isTakePhoto);
          } else {
            getVideo(isTakePhoto);
          }
        },
      ),
    );
  }

// 获取图片
  _getImages() {
    return _images.map((file) {
      return Stack(
        children: <Widget>[
          ClipRRect(
            // 圆角效果
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              file,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: ClipOval(
                // 圆角删除按钮
                child: GestureDetector(
              onTap: () {
                setState(() {
                  _images.remove(file);
                });
              },
              child: ClipOval(
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.black54),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            )),
          )
        ],
      );
    }).toList(); // map 转换为 list
  }
}
