import 'dart:ui';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/publish/desc_widget.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class ArticlePublishPage extends StatefulWidget {
  var arguments;
  ArticlePublishPage({Key key, this.arguments}) : super(key: key);
  _ArticlePublishPageState createState() => _ArticlePublishPageState();
}

class _ArticlePublishPageState extends State<ArticlePublishPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String forumId;
  String forumName;
  var isLoading = false;
  String forumImageName;
  bool canSub = true;
  // FocusNode blankNode = FocusNode();

  // FocusNode _focusNode;
  // 当前键盘是否是激活状态
  // bool isKeyboardActived = false;
  // FocusNode _focusNode2;
  // 当前键盘是否是激活状态
  // bool isKeyboardActived2 = false;

  @override
  void initState() {
    super.initState();
    // _focusNode = FocusNode();
    // // 监听输入框焦点变化
    // _focusNode.addListener(_onFocus);

    // _focusNode2 = FocusNode();
    // // 监听输入框焦点变化
    // _focusNode2.addListener(_onFocus2);
    // // 创建一个界面变化的观察者
    // WidgetsBinding.instance.addObserver(this);
    if (widget.arguments != null && widget.arguments['str'] != null) {
      var a = widget.arguments['str'].split('|');
      forumId = a[0];
      forumName = a[1];
      forumImageName = a[2];
    }
  }

  // @override
  // void didChangeMetrics() {
  //   super.didChangeMetrics();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // 当前是安卓系统并且在焦点聚焦的情况下
  //     if (Platform.isAndroid && (_focusNode.hasFocus)) {
  //       if (isKeyboardActived) {
  //         isKeyboardActived = false;
  //         // 使输入框失去焦点
  //         _focusNode.unfocus();
  //         return;
  //       }
  //       isKeyboardActived = true;
  //     } else if (Platform.isAndroid && (_focusNode2.hasFocus)) {
  //       if (isKeyboardActived2) {
  //         isKeyboardActived2 = false;
  //         // 使输入框失去焦点
  //         _focusNode2.unfocus();
  //         return;
  //       }
  //       isKeyboardActived2 = true;
  //     }
  //   });
  // }

  // 既然有监听当然也要有卸载，防止内存泄漏嘛
  @override
  void dispose() {
    super.dispose();
    // _focusNode.dispose();
    // _focusNode2.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  // 焦点变化时触发的函数
  // _onFocus() {
  //   if (_focusNode.hasFocus) {
  //     // 聚焦时候的操作
  //     return;
  //   }

  //   // 失去焦点时候的操作
  //   isKeyboardActived = false;
  // }

  // _onFocus2() {
  //   if (_focusNode2.hasFocus) {
  //     // 聚焦时候的操作
  //     return;
  //   }

  //   // 失去焦点时候的操作
  //   isKeyboardActived2 = false;
  // }

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
            '发布文字',
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
          child: Container(
            padding: EdgeInsets.all(10), //SingleChildScrollView
            child: Column(
              children: <Widget>[
                DescWidget(),
                _chooseForum(context),
                _title('标题'),
                _titleInput(),
                _title('文字内容'),
                _content(),
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
        // focusNode: _focusNode,
        controller: _titleController,
        textInputAction: TextInputAction.done,
        maxLines: 3,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入标题",
          contentPadding: EdgeInsets.fromLTRB(14, 8, 14, 8),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: KColor.defaultGrayColor, width: 1)),
        ),
        onSubmitted: (_) {
          // 点击键盘上的 "完成" 回调
          // 关闭弹出的键盘
          FocusScope.of(context).requestFocus(FocusNode());
          // focusNodePassword.unfocus();
          // 如果没有关联focusnode 要关闭键盘可以用：  FocusScope.of(context).requestFocus(FocusNode());
        },
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
              // if (result != null) {
              //   var a = result.split('|');
              //   setState(() {
              //     forumId = a[0];
              //     forumName = a[1];
              //   });
              // }
              if (result != null) {
                var a = result.split('|');
                setState(() {
                  forumId = a[0];
                  forumName = a[1];
                  forumImageName = a[2];
                });
              }

              print('页面返回来了');
              print(result);
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

  // 上传图片
  Widget _content() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextField(
        // focusNode: _focusNode2,
        controller: _contentController,
        maxLines: 6,
        // decoration: InputDecoration.collapsed(hintText: "请输入标题"),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入内容",
          contentPadding: EdgeInsets.fromLTRB(14, 8, 10, 8),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: KColor.defaultGrayColor, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: KColor.defaultGrayColor, width: 1)),
        ),
      ),
    );
  }

  Future getImage(isTakePhoto) async {
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(
        source: isTakePhoto ? ImageSource.camera : ImageSource.gallery);
  }

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
          var content = _contentController.text;
          if (title.trim().isNotEmpty && content.trim().isNotEmpty) {
            if (canSub) {
              setState(() {
                canSub = false;
              });
              toPush(context, forumId, title, content);
            } else {
              Fluttertoast.showToast(
                msg: '请勿重复提交',
                gravity: ToastGravity.CENTER,
              );
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

  toPush(context, forumId, title, content) async {
    print('打印内容：${content}');
    // var a = content.match(/[\s\D]/g);
    // RegExp reg = new RegExp([\D]);
    // String str1= r'Hello \n  World'
    print(content.length);

    var a = content.replaceAll("\n", "A");
    print(a);
    FormData formdata = FormData.fromMap({
      'forumId': forumId,
      'title': title,
      'articleType': 'richtext',
      'article': content
    });
    var response = await HttpUtil().post(
      Api.submitArticle,
      parameters: {'data': formdata},
      options: Options(
        headers: {
          Headers.contentTypeHeader:
              'application/x-www-form-urlencoded', // set content-length
          Headers.acceptHeader: 'application/json'
        },
      ),
    );

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
        msg: response['errorMessage'].toString(),
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
