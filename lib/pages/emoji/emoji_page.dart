

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmojiPage extends StatefulWidget {
  var callBack;
  EmojiPage({Key key, this.callBack}) : super(key: key);
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
  List<dynamic> allEmojis = [];

  int lineEmojiNum =  6;


  @override
  void initState() {
    _getEmoji();
  }

  _getEmoji() async {
    var response = await HttpUtil().get(Api.getEmojis, alterFailed: true);
    if (response['success']) {
      setState(() {
        allEmojis = response['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.titleLarge.color, //修改颜色
                size: 16),
            title: Text(
              '选择表情',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge.color,
                fontSize: ScreenUtil().setSp(34),
              ),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          preferredSize: Size.fromHeight(60),
        ),
        body: ListView.builder(itemBuilder: (BuildContext context, int vIndex) {
          return
            Container(height: ScreenUtil().setWidth(125),

              child:
              ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int hIndex) {
                return ClipRRect(
                  key: Key(allEmojis[vIndex * lineEmojiNum + hIndex]['id'].toString()),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: ScreenUtil().setWidth(125),
                    width: ScreenUtil().setWidth(125),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.callBack(allEmojis[vIndex * lineEmojiNum + hIndex]['name']);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: ScreenUtil().setWidth(120),
                            width: ScreenUtil().setWidth(120),
                            child: Image.network(
                              'https://i.chao.fun/' + allEmojis[vIndex * lineEmojiNum + hIndex]['name'] + '?x-oss-process=image/resize,h_360/format,webp/quality,q_75',
                              height: ScreenUtil().setWidth(120),
                              width: ScreenUtil().setWidth(120),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              showCupertinoDialog(
                                //showCupertinoDialog
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text('提示'),
                                      content: Text('你确定要删除该表情吗？'),
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
                                            var response = await HttpUtil().get(Api.removeEmoji, parameters: {'emojiId': allEmojis[vIndex * lineEmojiNum + hIndex]['id']});
                                            if (response['success']) {
                                              Fluttertoast.showToast(
                                                msg: '删除表情成功',
                                                gravity: ToastGravity.CENTER,
                                              );
                                            }
                                            _getEmoji();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount:  vIndex == (allEmojis.length / lineEmojiNum ).ceil() - 1 ?
              (allEmojis.length % lineEmojiNum == 0 ? lineEmojiNum : allEmojis.length % lineEmojiNum) : lineEmojiNum,
            )
          );
        },
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: (allEmojis.length / lineEmojiNum).ceil(),
        )
    );
  }



}