import 'dart:ffi';
import 'dart:ui';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/pages/publish/desc_widget.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';

class ImagePublishPage extends StatefulWidget {
  var arguments;
  ImagePublishPage({Key key, this.arguments}) : super(key: key);
  _ImagePublishPageState createState() => _ImagePublishPageState();
}

class _ImagePublishPageState extends State<ImagePublishPage> {
  TextEditingController _titleController = TextEditingController();
  String forumId;
  String forumName;
  String forumImageName;
  var isLoading = false;
  List imageList = [];
  List imagesUrl = [];
  ScrollController _scrollController = ScrollController();
  var chooseType;
  var videoUrl;
  bool canSub = true;
  final _picker = ImagePicker();
  var counts;
  var totals;
  var percent = 0.0;
  @override
  void initState() {
    super.initState();
    if (widget.arguments != null && widget.arguments['str'] != null) {
      var a = widget.arguments['str'].split('|');
      forumId = a[0];
      forumName = a[1];
      forumImageName = a[2];
    }
  }

  // 既然有监听当然也要有卸载，防止内存泄漏嘛
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: KColor.defaultGrayColor, //修改颜色
          ),
          title: Text(
            '发布图片/视频',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          // bottomOpacity: 0,
          elevation: 0, //头部阴影区域高度
          actions: <Widget>[
            _btnPush(context),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      DescWidget(),
                      _chooseForum(context),
                      _title('标题'),
                      _titleInput(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _title('选择图片/视频'),
                          chooseType != null
                              ? InkWell(
                            onTap: () {
                              setState(() {
                                chooseType = null;
                                imageList = [];
                                imagesUrl = [];
                                videoUrl = null;
                              });
                              _pickImage();
                            },
                            child: Text(
                              '重新选择',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          )
                              : Container(
                            width: 20,
                          ),
                        ],
                      ),
                      chooseType != null
                          ? (chooseType != 'video'
                          ? Container(
                        height: 500,
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            if (index != imageList.length) {
                              return Container(
                                height: 80,
                                // color: Colors
                                //     .primaries[index % Colors.primaries.length],
                                child: Image.file(
                                  File(imageList[index].path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return Container(
                                alignment: Alignment.center,
                                height: 80,
                                // color: Colors
                                //     .primaries[index % Colors.primaries.length],
                                child: _imageAdd(),
                              );
                            }
                          },
                          itemCount: imageList.length + 1,
                        ),
                      )
                          : VideoWidget(
                          item: {'video': videoUrl},
                          video: true,
                          detail: true))
                          : Container(
                        height: 150,
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            if (index != imageList.length) {
                              return Container(
                                height: 80,
                                // color: Colors
                                //     .primaries[index % Colors.primaries.length],
                                child: Image.file(
                                  File(imageList[index].path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return Container(
                                alignment: Alignment.center,
                                height: 80,
                                // color: Colors
                                //     .primaries[index % Colors.primaries.length],
                                child: _imageAdd(),
                              );
                            }
                          },
                          itemCount: imageList.length + 1,
                        ),
                      ),
                      totals != null
                          ? Container(
                        height: ScreenUtil().setWidth(300),
                        width: ScreenUtil().setWidth(750),
                        alignment: Alignment.center,
                        child: Container(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  //限制进度条的高度
                                  height: 10.0,
                                  //限制进度条的宽度
                                  width: ScreenUtil().setWidth(600),
                                  child: new LinearProgressIndicator(
                                    //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
                                      value: double.parse(
                                          percent.toStringAsFixed(2)),
                                      //背景颜色
                                      backgroundColor: Color.fromRGBO(
                                          240, 240, 240, 1),
                                      //进度颜色
                                      valueColor:
                                      new AlwaysStoppedAnimation<
                                          Color>(Colors.green)),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  totals +
                                      'M (' +
                                      (percent * 100).toStringAsFixed(1) +
                                      '%)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                      // _btnPush(context),
                    ],
                  ),
                ),
               Positioned(
                  top: ScreenUtil().setHeight(550),
                  left: ScreenUtil().setWidth(350),
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(254, 149, 0, 100)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 标题输入框
  Widget _titleInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _titleController,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        // decoration: InputDecoration.collapsed(hintText: "请输入标题"),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入标题",
          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: KColor.defaultGrayColor, width: 1)),
        ),
      ),
    );
  }

  // 选择版块
  Widget _chooseForum(context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 6),
      child: Ink(
        child: ListTile(
          onTap: () {
            Navigator.push<String>(context,
                new MaterialPageRoute(builder: (BuildContext context) {
              return new ForumListPage();
            })).then((String result) {
              //处理代码
              if (result != null) {
                var a = result.split('|');
                setState(() {
                  forumId = a[0];
                  forumName = a[1];
                  forumImageName = a[2];
                });
              }
            });
          },
          title: Text(
            '选择版块',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(34),
            ),
          ),
          contentPadding: EdgeInsets.all(0),
          trailing: forumName == null
              ? Icon(Icons.arrow_forward_ios)
              : Text(
                  forumName + ' >',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(34),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _title(title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
      ),
    );
  }

  // 上传图片
  Widget _imageAdd() {
    return Container(
      // alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          _pickImage();
        },
        child: Container(
          height: ScreenUtil().setWidth(200),
          width: ScreenUtil().setWidth(200),
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: KColor.defaultBorderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.add_a_photo,
            color: KColor.defaultGrayColor,
            size: ScreenUtil().setWidth(70),
          ),
        ),
      ),
    );
  }

  List<Map> picks = [
    {
      'title': '拍照',
      'icon': Icon(
        Icons.camera_alt,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(60),
      ),
      'value': 1
    },
    {
      'title': '选择照片',
      'icon': Icon(
        Icons.photo_library,
        color: Color.fromRGBO(153, 153, 153, 1),
        size: ScreenUtil().setWidth(56),
      ),
      'value': 3
    },
    {
      'title': '拍视频',
      'icon': Image.asset(
        'assets/images/_icon/shipin.png',
        width: ScreenUtil().setWidth(60),
      ),
      'value': 2
    },
    {
      'title': '选择视频',
      'icon': Image.asset(
        'assets/images/_icon/choosevideo.png',
        width: ScreenUtil().setWidth(50),
      ),
      'value': 4
    },
  ];

  _doColor(index) {
    if (chooseType == null) {
      return Colors.black;
    } else if (chooseType == 'image') {
      if (index == 2 || index == 3) {
        return Colors.grey;
      } else {
        return Colors.black;
      }
    } else {
      if (index == 0 || index == 1) {
        return Colors.grey;
      } else {
        return Colors.black;
      }
    }
  }

  // 底部弹框
  _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setWidth(350),
        color: Color.fromRGBO(245, 245, 245, 1),
        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () async {
                  switch (index) {
                    case 0:
                      getImage(true);
                      break;
                    case 1:
                      getImage(false);
                      break;
                    case 2:
                      getVideo(true);
                      break;
                    case 3:
                      getVideo(false);
                      break;
                  }
                },
                child: Container(
                  height: ScreenUtil().setWidth(250),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: ScreenUtil().setWidth(60),
                        child: picks[index]['icon'],
                        alignment: Alignment.center,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        picks[index]['title'],
                        style: TextStyle(
                          color: _doColor(index),
                        ),
                      )
                    ],
                  ),
                  // color: Colors.primaries[(index) % Colors.primaries.length],
                  color: Colors.white,
                ),
              ),
            );
          },
          itemCount: picks.length,
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
        onTap: () async {
          if (type == 'image') {
            getImage(isTakePhoto);
          } else {
            // getVideo(isTakePhoto);
          }
        },
      ),
    );
  }

  Future getImage(isTakePhoto) async {
    List image;
    if (chooseType == null || chooseType == 'image') {
      Navigator.pop(context);
      if (isTakePhoto) {
        // var ims = await ImagePicker.pickImage(
        //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
        // TODO[cijian]: 支持上传视频，见
        var ims = await ImagesPicker.openCamera(
          pickType: PickType.image, //quality: 0.8, maxSize: 20480
          // maxTime: 15, // record video max time
        );
        print(ims); //image/jpeg [Instance of 'Media']

        setState(() {
          imageList.addAll(ims.map((e) {
            return File(e.path);
          }).toList());
          imagesUrl.addAll(new List(ims.length));
        });
        for (var i = (imageList.length - ims.length);
            i < imageList.length;
            i++) {
          _upLoadImage(imageList[i], i);
        }
      } else {
        List res = await ImagesPicker.pick(
          count: 9, pickType: PickType.image, //maxSize: 20480,
          // cropOpt: CropOption(
          //     // aspectRatio: CropAspectRatio.wh16x9
          //     ),
        );
        print(res);
        if (res != null) {
          print(res);

          setState(() {
            imageList.addAll(res.map((e) {
              return File(e.path);
            }).toList());
            imagesUrl.addAll(new List(res.length));
          });
          for (var i = (imageList.length - res.length);
              i < imageList.length;
              i++) {
            _upLoadImage(imageList[i], i);
          }
        }
        // PickedFile image = await _picker.getImage(source: ImageSource.gallery);
      }
    }
  }

  Future getVideo(isTakeVideo) async {
    if (chooseType == null || chooseType == 'video') {
      Navigator.pop(context);
      if (isTakeVideo) {
        // var ims = await ImagePicker.pickImage(
        //     source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
        var ims = await ImagesPicker.openCamera(
          pickType: PickType.video,
          maxTime: 120, // record video max time
        );
        print('视频地址');
        _upLoadVideo(File(ims[0].path));
      } else {
        if (Platform.isIOS) {
          PickedFile res = await _picker.getVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(seconds: 600),
          );
          // final File file = File(res.path);
          _upLoadVideo(File(res.path));
          print('获取视频结果ios');
          print(res);
        } else {
          List res = await ImagesPicker.pick(
            count: 1, pickType: PickType.video, quality: 0.8,
            // cropOpt: CropOption(
            //     // aspectRatio: CropAspectRatio.wh16x9
            //     ),
          );
          // maxSize: 307200,
          _upLoadVideo(File(res[0].path));
          print('获取视频结果android');
          print(res);
        }
      }
    }
  }

  //上传图片
  _upLoadImage(File image, int i) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });
    setState(() {
      isLoading = true;
    });
    Dio dio = new Dio();
    var response =
        await dio.post("https://chao.fun/api/upload_image", data: formdata);
    print('上传结束');
    print(response);
    print(response.data['data']);
    if (response.data['success']) {
      setState(() {
        if (chooseType == null) {
          chooseType = 'image';
        }
        imagesUrl[i] = response.data['data'];
        if (i == imageList.length - 1) {
          isLoading = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
        imageList.removeAt(i);
        imagesUrl.removeAt(i);
      });
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }

  _upLoadVideo(File video) async {
    String path = video.path;
    print('进入视频上传');
    print(path);
    var name =
        path.substring(path.lastIndexOf("/") + 1, path.length).toLowerCase();
    print(name);
    name = (name.endsWith(".jpg") ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png')
        ? name
            .replaceAll(".jpg", ".mp4")
            .replaceAll(".jpeg", ".mp4")
            .replaceAll(".png", ".mp4")
        : name);
    print(name);
    print('视频开始上传');
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "fileName": name
    });
    Dio dio = new Dio();
    var response = await dio.post("https://chao.fun/api/upload_image",
        data: formdata, onSendProgress: (int count, int total) {
      if (total != null) {
        if (totals == null) {
          setState(() {
            totals = (total / (1024 * 1024)).toStringAsFixed(2);
          });
        }
        setState(() {
          counts = (count / (1024 * 1024)).toStringAsFixed(2);
          percent = (count / total);
        });
      }
      print('count $count');
      print('total $total');
      print('percent $percent');
    });
    print('上传结束');
    print(response);
    print(response.data['data']);
    if (response.data['success']) {
      videoUrl = response.data['data'];
      setState(() {
        totals = null;
        if (chooseType == null) {
          chooseType = 'video';
        }
      });
    } else {
      setState(() {
        chooseType = null;
      });
      Fluttertoast.showToast(
        msg: response.data['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }

  // 发布按钮
  Widget _btnPush(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14, top: 14, right: 10),
      width: ScreenUtil().setWidth(90),
      height: ScreenUtil().setWidth(30),
      child: MaterialButton(
        color: Colors.pink,
        textColor: Colors.white,
        child: new Text(
          '发布',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
          ),
        ),
        minWidth: ScreenUtil().setWidth(80),
        height: ScreenUtil().setWidth(30),
        padding: EdgeInsets.all(0),
        onPressed: () {
          var title = _titleController.text;
          print(title);
          if (title.trim().isNotEmpty && forumId != null) {
            if (chooseType == 'image') {
              if (imageList.length > 0 &&
                  imageList.length != 0 &&
                  imagesUrl.length != 0 &&
                  imageList.length == imagesUrl.length) {
                print('开始上传');
                var a = imagesUrl.map((element) {
                  return KSet.imgOrigin + element;
                });
                print(a);
                if (canSub) {
                  setState(() {
                    canSub = false;
                  });
                  toPush(context, forumId, title);
                } else {
                  Fluttertoast.showToast(
                    msg: '请勿重复提交',
                    gravity: ToastGravity.CENTER,
                  );
                }
              }
            } else if (chooseType == 'video' && videoUrl != null) {
              if (canSub) {
                setState(() {
                  canSub = false;
                });
                toPush(context, forumId, title);
              } else {
                Fluttertoast.showToast(
                  msg: '请勿重复提交',
                  gravity: ToastGravity.CENTER,
                );
              }
            }
          } else {
            Fluttertoast.showToast(
              msg: '请填写完整哦~',
              gravity: ToastGravity.CENTER,
            );
          }
        },
      ),
    );
  }

  toPush(context, forumId, title) async {
    setState(() {
      isLoading = true;
    });
    String img = '';
    var response;
    if (chooseType == 'image') {
      if (imagesUrl.length == 1) {
        img = imagesUrl[0];
      } else {
        img = imagesUrl.join(',');
      }
      if (imagesUrl.length == 1) {
        response = await HttpUtil().get(Api.submitImage,
            parameters: {'forumId': forumId, 'title': title, 'ossName': img});
      } else {
        response = await HttpUtil().get(Api.submitImage,
            parameters: {'forumId': forumId, 'title': title, 'ossNames': img});
      }
    } else if (chooseType == 'video') {
      response = await HttpUtil().get(Api.submitVideo, parameters: {
        'forumId': forumId,
        'title': title,
        'ossName': videoUrl
      });
    }

    if (response['success']) {
      setState(() {
        canSub = true;
        isLoading = false;
      });
      Provider.of<UserStateProvide>(context, listen: false)
          .setRemmenberForumList(
              {'id': forumId, 'name': forumName, 'imageName': forumImageName});
      Fluttertoast.showToast(
        msg: '发布成功',
        gravity: ToastGravity.CENTER,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        canSub = true;
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
