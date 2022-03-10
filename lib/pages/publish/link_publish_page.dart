import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/pages/publish/desc_widget.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LinkPublishPage extends StatefulWidget {
  var arguments;
  LinkPublishPage({Key key, this.arguments}) : super(key: key);
  _LinkPublishPageState createState() => _LinkPublishPageState();
}

class _LinkPublishPageState extends State<LinkPublishPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _linkController = TextEditingController();
  String forumId;
  String forumName;
  var isLoading = false;
  String forumImageName;
  bool canSub = true;

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: KColor.defaultGrayColor, //修改颜色
          ),
          title: Text(
            '发布链接',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // bottomOpacity: 0,
          elevation: 0, //头部阴影区域高度
          actions: <Widget>[
            _btnPush(context),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
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
                    _title('链接地址'),
                    _pasteContent(),
                  ],
                ),
                _linkInput(),
                // _btnPush(context),
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

  // 链接地址
  Widget _linkInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _linkController,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(34),
        ),
        decoration: InputDecoration(
          hintText: "请输入链接地址",
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

  // 粘贴
  Widget _pasteContent() {
    return Container(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: InkWell(
          onTap: () async {
            ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
            if (data != null) {
              _linkController.text = data.text;
              print(data.text);
            }
          },
          child: Text(
            '粘贴地址',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
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
          var link = _linkController.text;
          if (title.trim().isNotEmpty && link.trim().isNotEmpty) {
            if (!isLoading) {
              if (canSub) {
                setState(() {
                  canSub = false;
                });
                toPush(context, forumId, title, link);
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

  toPush(context, forumId, title, link) async {
    setState(() {
      isLoading = true;
    });
    var response = await HttpUtil().get(Api.submitLink,
        parameters: {'forumId': forumId, 'title': title, 'link': link});
    if (response['success']) {
      setState(() {
        isLoading = false;
        canSub = true;
      });
      Provider.of<UserStateProvide>(context, listen: false)
          .setRemmenberForumList(
              {'id': forumId, 'name': forumName, 'imageName': forumImageName});
      Fluttertoast.showToast(
        msg: '发布成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        isLoading = false;
        canSub = true;
      });
      Fluttertoast.showToast(
        msg: response['errorMessage'],
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
