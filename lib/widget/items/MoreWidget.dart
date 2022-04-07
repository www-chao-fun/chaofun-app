

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/SaveUtils.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MoreWidget{

  var item;
  MoreWidget({Key key,
    this.item});

  TextEditingController _inputController = TextEditingController();

  show(BuildContext context) {
    int high = 500;
    List<Map> newTools = [
      // {"label": "关注Ta", "value": "1", "icon": "assets/icon/love.png"},
      {"label": "复制帖子链接", "value": "2", "icon": "assets/icon/copy.png"},
      {"label": "屏蔽此帖子", "value": "3", "icon": "assets/icon/disabled.png"},
      {"label": "屏蔽此用户", "value": "4", "icon": "assets/icon/disableuser.png"},
      {"label": "举报", "value": "5", "icon": "assets/icon/jubao.png"},
    ];

    if (item['canDeleted'] == true) {
      high += 180;
      newTools.insert(
          4, {"label": "删除帖子", "value": "1", "icon": "assets/icon/delete.png"});
      newTools.insert(0, {
        "label": "添加/修改标签",
        "value": "6",
        "icon": "assets/images/_icon/add_tag.png"
      });
    }

    if (item['canAddToRecommend'] != null && item['canAddToRecommend']) {
      newTools.insert(0, {
        "label": "推荐",
        "value": "8",
        "icon": "assets/images/_icon/add_tag.png"
      });
    }


    if (item['canChangeTitle'] == true) {
      high += 150;
      newTools.insert(0, {
        "label": "加入合集",
        "value": "7",
        "icon": "assets/images/_icon/addcol.png"
      });
    }

    if (item['type'] == 'inner_video') {
      high += 150;
      newTools.insert(0, {
        "label": "保存视频",
        "value": "10",
        "icon": "assets/images/_icon/addcol.png"
      });
    }

    if (item['type'] == 'gif') {
      high += 150;
      newTools.insert(0, {
        "label": "保存GIF",
        "value": "11",
        "icon": "assets/images/_icon/addcol.png"
      });
    }

    if (item['type'] == 'image') {
      high += 150;
      if (item['images'] != null) {
        newTools.insert(0, {
          "label": "保存所有图片",
          "value": "13",
          "icon": "assets/images/_icon/addcol.png"
        });
      } else {
        newTools.insert(0, {
          "label": "保存图片",
          "value": "12",
          "icon": "assets/images/_icon/addcol.png"
        });
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setWidth(high),
        child: Column(
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: newTools.map((pushItem) {
                if (item['value'] == 6) {
                } else {

                }
                return _pushItem(context, pushItem);
              }).toList(),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      // Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child: Container(
                      // color: Colors.blue,
                      width: ScreenUtil().setWidth(750),
                      height: ScreenUtil().setWidth(70),
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(20),
                          bottom: ScreenUtil().setWidth(20)),
                      child: Image.asset(
                        'assets/images/icon/close-btn.png',
                        width: ScreenUtil().setWidth(60),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _pushItem(context, pushItem) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
        ),
      ),
      child: InkWell(
        onTap: () async {
          if (pushItem['value'] == '5') {
            Navigator.of(context).pop();
            doWay(context);
          } else if (pushItem['value'] == '3') {
            Navigator.of(context).pop();
            Fluttertoast.showToast(
              msg: '屏蔽帖子成功',
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );

            Provider.of<UserStateProvide>(context, listen: false)
                .addDisabledList(item['postId']);
          } else if (pushItem['value'] == '4') {
            Provider.of<UserStateProvide>(context, listen: false)
                .addDisabledUserList(item['userInfo']['userId']);
            Fluttertoast.showToast(
              msg: '屏蔽用户成功',
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
            Navigator.of(context).pop();
          } else if (pushItem['value'] == '2') {
            Clipboard.setData(ClipboardData(
                text: 'https://chao.fun/p/' + item['postId'].toString()));
            Fluttertoast.showToast(
              msg: "已复制帖子链接",
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
            Navigator.of(context).pop();
          } else if (pushItem['value'] == '1') {
            showCupertinoDialog(
              //showCupertinoDialog
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('提示'),
                    content: Text('确定删除帖子吗？'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop('cancel');
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('确定'),
                        onPressed: () async {
                          var response = await HttpUtil.instance
                              .get(Api.deletePost, parameters: {'postId': item['postId']});

                          if (response['success']) {
                            Fluttertoast.showToast(
                              msg: "删除帖子成功",
                              gravity: ToastGravity.CENTER,
                              // textColor: Colors.grey,
                            );
                            Provider.of<UserStateProvide>(context, listen: false)
                                .addDisabledList(item['postId']);
                          } else {
                            Fluttertoast.showToast(
                              msg: response['errorMessage'],
                              gravity: ToastGravity.CENTER,
                              // textColor: Colors.grey,
                            );
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          // });
                        },
                      ),
                    ],
                  );
                });

          } else if (pushItem['value'] == '6') {
            // Navigator.of(context).pop();
            var res = await HttpUtil().get(Api.listTag,
                parameters: {'forumId': item['forum']['id'].toString()});
            _pickTagList(context, res['data']);
            if (res['data'].length > 0) {
            } else {
              Fluttertoast.showToast(
                msg: '暂无可添加标签',
                gravity: ToastGravity.CENTER,
              );
            }
            print('listTag结果');
            print(res);
          } else if (pushItem['value'] == '7') {
            var ps = {'type': 'choose', 'postId': item['postId'].toString()};
            if (item['collection'] != null) {
              ps['id'] = item['collection']['id'].toString();
            }
            Navigator.pushNamed(
              context,
              '/collectlist',
              arguments: ps,
            ).then((value) {
              if (value != null) {
                Navigator.pop(context);
              }
            });
          } else if (pushItem['value'] == '8') {
            Navigator.of(context).pop();
            var res = await HttpUtil().get(Api.addRecommend,
                parameters: {'postId': item['postId']});

            if (res['success']) {
              Fluttertoast.showToast(
                msg: '推荐成功',
                gravity: ToastGravity.CENTER,
              );
            } else {
              Fluttertoast.showToast(
                msg: '推荐失败',
                gravity: ToastGravity.CENTER,
              );
            }
          } else if (pushItem['value'] == '10') {
            // print(item);
            save(context, item['video'], 1);
          } else if (pushItem['value'] == '11') {
            // print(item);
            save(context, item['imageName'].replaceAll('.mp4', '.gif'), 1);
          } else if (pushItem['value'] == '12') {
            save(context, item['imageName'], 1);
          } else if (pushItem['value'] == '13') {
            save(context, item['images'].join(','), 1);
          }
          print(item['value']);
          print(item);
        },
        child: Container(
          // color: Colors.blue,
          height: ScreenUtil().setWidth(90),
          child: Row(
            children: [
              // SizedBox(
              //   width: 10,
              // ),
              // Container(
              //   width: ScreenUtil().setWidth(44),
              //   height: ScreenUtil().setWidth(44),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     image: DecorationImage(
              //       image: AssetImage(
              //         pushItem['icon'],
              //       ),
              //       fit: BoxFit.fill,
              //     ),
              //   ),
              // ),
              SizedBox(
                width: 10,
              ),
              Text(
                pushItem['label'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  _pickTagList(context, data) {
    int high = 500;
    print('再次弹窗');;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: ScreenUtil().setWidth(730),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, right: 10),
              height: ScreenUtil().setWidth(80),
              child: Text(
                '添加/修改标签',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child:Container(
                  height: ScreenUtil().setWidth(530),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          var res = await HttpUtil().get(Api.addTag, parameters: {
                            'postId': item['postId'].toString(),
                            'tagId': data[index]['id'].toString(),
                          });
                          print('添加标签');
                          if (res['success']) {
                            Fluttertoast.showToast(
                              msg: '添加标签成功',
                              gravity: ToastGravity.CENTER,
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                            var maps = {
                              'postId': item['postId'].toString(),
                              'tags': data[index]
                            };
                            Provider.of<UserStateProvide>(context,
                                listen: false)
                                .setChangeTag(maps);
                          }

                          // callTag(data[index]);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 0.5, color: KColor.defaultBorderColor),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: ScreenUtil().setWidth(90),
                          child: Text('# ' + data[index]['name']),
                        ),
                      );
                    },
                    itemCount: data.length,
                  ),
                ),
              ),
            ),
            Stack(
                children:[

                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      // color: Colors.blue,
                      width: ScreenUtil().setWidth(750),
                      height: ScreenUtil().setWidth(70),
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(10),
                          bottom: ScreenUtil().setWidth(40)),
                      child: Image.asset(
                        'assets/images/icon/close-btn.png',
                        width: ScreenUtil().setWidth(60),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: TextButton(
                        onPressed: () async {
                          var res = await HttpUtil().get(Api.removeTag, parameters: {
                            'postId': item['postId'].toString(),
                          });
                          Fluttertoast.showToast(
                            msg: '清除标签成功',
                            gravity: ToastGravity.CENTER,
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('清除帖子标签'),
                      )
                  ),
                ],

            ),
          ],
        ),
      ),
    );
  }

  doWay(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => new AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets, //边距（必要）
        duration: const Duration(milliseconds: 80), //时常 （必要）
        child: Container(
          height: ScreenUtil().setHeight(220),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.only(left: 10, top: 6, bottom: 4),
                    border: OutlineInputBorder(),
                    hintText: '请输入举报理由(可为空)',
                  ),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(0, 4, 10, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                  color: Colors.pink,
                  child: InkWell(
                    onTap: () {
                      toUpReport(context, _inputController.text, item);
                      // toUpReport(context, content, item);
                    },
                    child: Text(
                      '提交',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  toUpReport(context, content, item) async {
    var response = await HttpUtil().get(Api.upReport, parameters: {
      'contentType': 'post',
      'reason': content,
      'id': item['postId']
    });
    if (response['success']) {
      Provider.of<UserStateProvide>(context, listen: false)
          .addDisabledList(item['postId']);
      Fluttertoast.showToast(
        msg: '举报成功',
        gravity: ToastGravity.CENTER,
        // textColor: Colors.grey,
      );
    } else {
      if (response['errorCode'] == 'login_error') {
        Fluttertoast.showToast(
          msg: '尚未登录，请登录后重试',
          gravity: ToastGravity.CENTER,
          // textColor: Colors.grey,
        );
      }
    }
    Navigator.of(context).pop();
  }
}