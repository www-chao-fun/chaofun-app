import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/items/top_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MsgWidget extends StatelessWidget {
  var item;
  MsgWidget({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        top: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        bottom: ScreenUtil().setWidth(30),
      ),
      margin: EdgeInsets.only(bottom: 5),
      child: (item['type'] != 'text_notice' && item['type'] != 'delete_post'  && item['type'] != 'delete_comment')
          ? Column(
              children: [
                _msgTop(context),
                SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    if (item['post'] != null) {
                      Navigator.pushNamed(
                        context,
                        '/postdetail',
                        arguments: {
                          "postId": item['post']['postId'].toString(),
                          "targetCommentId": (item['comment'] != null ? item['comment']['id']: null)
                        },
                      );
                    }
                  },
                  child: _doContent(context),
                )
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/_icon/tzhi.png',
                  width: ScreenUtil().setWidth(68),
                  height: ScreenUtil().setWidth(68),
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (item['link'] != null) {
                        Utils.toNavigate(context, item['link'], '炒饭通知');
                        // https://chao.fun/p/1026976
                      } else if (item['type'] == 'delete_comment') {
                        Navigator.pushNamed(
                          context,
                          '/postdetail',
                          arguments: {
                            "postId": item['post']['postId'].toString(),
                          },
                        );
                      }
                    },
                    onLongPress: () {
                      if (item['type'] == 'text_notice') {
                        Clipboard.setData(ClipboardData(text: item['text']));
                        Fluttertoast.showToast(
                          msg: '已复制消息',
                          gravity: ToastGravity.BOTTOM,
                          // textColor: Colors.grey,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: '不支持复制该类型消息',
                          gravity: ToastGravity.BOTTOM,
                          // textColor: Colors.grey,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(33, 29, 47, 0.05),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        // border: Border.all(
                        //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
                      ),
                      child: Text(
                        getText(item),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String getText(item) {

    String result = null;
    if (item['type'] == 'text_notice') {
      result = item['text'];
    }
    if (item['type'] == 'delete_post') {
      result = '你的帖子【' +
          item['post']['title'] +
          '】已被删除，请阅读炒饭和分区发帖规范。';
    }
    if (item['type'] == 'delete_comment') {
      result = '你在帖子【' +
          item['post']['title'] +
          '】下的评论已被删除，请阅读炒饭和分区发帖规范。';
    }

    if (result == null) {
      result = '';
    }

    return result;
  }


  _doContent(context) {
    switch (item['type']) {
      case 'comment_post':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['comment']['text'],
              style: TextStyle(fontSize: ScreenUtil().setSp(28)),
            ),
            SizedBox(
              height: 8,
            ),
            _postTitle(context, Color.fromRGBO(33, 29, 47, 0.05)),
          ],
        );
        break;
      case 'sub_comment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['comment']['text'],
              style: TextStyle(fontSize: ScreenUtil().setSp(28)),
            ),
            SizedBox(
              height: 8,
            ),
            _rComment(context, 'sub_comment'),
          ],
        );
        break;
      case 'at':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['comment']['text'],
              style: TextStyle(fontSize: ScreenUtil().setSp(28)),
            ),
            SizedBox(
              height: 8,
            ),
            _postTitle(context,Color.fromRGBO(33, 29, 47, 0.05)),
          ],
        );
        break;
      case 'upvote_post':
        return _postTitle(context, Color.fromRGBO(33, 29, 47, 0.05));
        break;
      case 'upvote_comment':
        return _rComment(context, 'upvote_comment');
        break;
      // case 'comment_post':
      //   return '评论了你的帖子';
      //   break;
      case 'text_notice':
        return InkWell(
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Color.fromRGBO(33, 29, 47, 0.05),
              borderRadius: BorderRadius.all(Radius.circular(4)),
              // border: Border.all(
              //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
            ),
            child: Text(
              item['text'],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: Color.fromRGBO(33, 29, 47, 0.7),
              ),
            ),
          ),
        );
        break;
      default:
        return Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromRGBO(33, 29, 47, 0.05),
            borderRadius: BorderRadius.all(Radius.circular(4)),
            // border: Border.all(
            //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
          ),
          child: Text(
            '暂不支持的类型',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Color.fromRGBO(33, 29, 47, 0.7),
            ),
          ),
        );
        break;
    }
  }

  Widget _rComment(context, v) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Color.fromRGBO(33, 29, 47, 0.05),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        // border: Border.all(
        //     color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v == 'sub_comment'
                ? item['parentComment']['text']
                : item['comment']['text'],
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          _postTitle(context, Theme.of(context).backgroundColor),
        ],
      ),
    );
  }

  Widget _postTitle(context, color) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        // border:
        //     Border.all(color: Color.fromRGBO(153, 153, 153, 0.3), width: 0.5),
      ),
      child: Text(
        item['post']['title'],
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color:Theme.of(context).hintColor),
      ),
    );
  }

  Widget _msgTop(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              if (item['sender'] != null) {
                Navigator.pushNamed(
                  context,
                  '/userMemberPage',
                  arguments: {"userId": item['sender']['userId'].toString()},
                );
              }
            },
            child: item['type'] != 'text_notice'
                ? CachedNetworkImage(
                    //CachedNetworkImage
                    imageUrl: KSet.imgOrigin +
                        (item['sender'] != null
                            ? item['sender']['icon']
                            : 'biz/9563cdd828d2b674c424b79761ccb4c0.png') +
                        '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                    width: ScreenUtil().setWidth(68),
                    height: ScreenUtil().setWidth(68),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Image.asset("assets/images/img/place.png"),
                    ),
                  )
                : Image.asset(
                    'assets/images/_icon/tzhi.png',
                    width: ScreenUtil().setWidth(68),
                    height: ScreenUtil().setWidth(68),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Container(
          // width: ScreenUtil().setWidth(180),
          alignment: Alignment.centerLeft,
          child: _forumLi(context),
          padding: EdgeInsets.only(left: 8, right: 4),
        ),
      ],
    );
  }

  _forumLi(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(400),
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              if (item['sender'] != null) {
                Navigator.pushNamed(
                  context,
                  '/userMemberPage',
                  arguments: {"userId": item['sender']['userId'].toString()},
                );
              }
            },
            child: Text(
              item['sender'] != null ? item['sender']['userName'] : '游客',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color:Theme.of(context).textTheme.titleLarge.color,
    // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          width: ScreenUtil().setWidth(400),
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/userMemberPage',
                arguments: {"userId": item['userInfo']['userId'].toString()},
              );
            },
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: Utils.moments(item['gmtCreate']) + ' · ',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: Theme.of(context).hintColor,
                ),
                children: [
                  TextSpan(
                    text: _doTypes(),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _doTypes() {
    switch (item['type']) {
      case 'sub_comment':
        return '回复了你的评论';
        break;
      case 'at':
        return '在帖子下提到了你';
        break;
      case 'upvote_post':
        return '点赞了你的帖子';
        break;
      case 'upvote_comment':
        return '点赞了你的评论';
        break;
      case 'comment_post':
        return '评论了你的帖子';
        break;
      default:
        return '123';
        break;
    }
  }
}
