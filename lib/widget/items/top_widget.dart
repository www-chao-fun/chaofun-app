import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/SaveUtils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/api/api.dart';

import 'MoreWidget.dart';

class ItemsTop extends StatelessWidget {
  var item;
  var type;
  var pageSource;
  var source;
  var callTag;
  ItemsTop(
      {Key key,
      this.item,
      this.type,
      this.pageSource,
      this.source,
      this.callTag})
      : super(key: key);

  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // if (item['postId'].toString() != '414101') {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      margin: EdgeInsets.only(bottom: 0),
      width: ScreenUtil().setWidth(750),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        border: Border(
            // bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
            ),
      ),
      child: _rows(context),
    );
  }

  _rows(context) {
    if (type == 'forum') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        if (type == 'forum') {
                          Navigator.pushNamed(
                            context,
                            '/forumpage',
                            arguments: {
                              "forumId": item['forum']['id'].toString()
                            },
                          );
                        } else {}
                      },
                      child: CachedNetworkImage(
                        imageUrl: KSet.imgOrigin +
                            item['forum']['imageName'] +
                            '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                        width: ScreenUtil().setWidth(68),
                        height: ScreenUtil().setWidth(68),
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Center(
                          child: Image.asset("assets/images/img/place.png"),
                        ),
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
              ),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    MoreWidget(item: item).show(context);
                  },
                  child: Image.asset(
                    'assets/images/icon/more.png',
                    width: ScreenUtil().setWidth(30),
                  ),
                ),
                // Text(
                //   Utils.moments(item['gmtCreate']),
                //   style: TextStyle(
                //     color: KColor.defaultGrayColor,
                //     fontSize: ScreenUtil().setSp(24),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      );
    } else if (type == 'trends') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/userMemberPage',
                        arguments: {
                          "userId": item['userInfo']['userId'].toString()
                        },
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: KSet.imgOrigin +
                          item['userInfo']['icon'] +
                          '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                      width: ScreenUtil().setWidth(68),
                      height: ScreenUtil().setWidth(68),
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Center(
                        child: Image.asset("assets/images/img/place.png"),
                      ),
                    ),
                    // child: FadeInImage.assetNetwork(
                    //   placeholder: "assets/images/img/place.png",
                    //   image: KSet.imgOrigin +
                    //       item['forum']['imageName'] +
                    //       '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                    //   fit: BoxFit.fill,
                    //   width: ScreenUtil().setWidth(68),
                    //   height: ScreenUtil().setWidth(68),
                    // ),
                  ),
                ),
                Container(
                  // width: ScreenUtil().setWidth(180),
                  alignment: Alignment.centerLeft,
                  child: _forumLi(context),
                  padding: EdgeInsets.only(left: 8, right: 4),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    MoreWidget(item: item).show(context);
                  },
                  child: Image.asset(
                    'assets/images/icon/more.png',
                    width: ScreenUtil().setWidth(30),
                  ),
                ),
                // Text(
                //   Utils.moments(item['gmtCreate']),
                //   style: TextStyle(
                //     color: KColor.defaultGrayColor,
                //     fontSize: ScreenUtil().setSp(24),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setWidth(40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                      child: Image.network(
                        KSet.imgOrigin +
                            item['userInfo']['icon'] +
                            '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Image.network(
                  //   KSet.imgOrigin +
                  //       item['userInfo']['icon'] +
                  //       '?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                  //   width: ScreenUtil().setWidth(40),
                  //   height: ScreenUtil().setWidth(40),
                  // ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    // width: ScreenUtil().setWidth(180),
                    alignment: Alignment.centerLeft,
                    child: _userLi(context),
                    padding: EdgeInsets.only(left: 0, right: 4),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                // Text(
                //   Utils.moments(item['gmtCreate']),
                //   style: TextStyle(
                //     color: KColor.defaultGrayColor,
                //     fontSize: ScreenUtil().setSp(24),
                //   ),
                // ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    MoreWidget(item: item).show(context);
                  },
                  child: Image.asset(
                    'assets/images/icon/more.png',
                    width: ScreenUtil().setWidth(30),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  _forumTop(context) {
    return Container();
  }

  _forumLi(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(400),
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              if (type == 'forum') {
                Navigator.pushNamed(
                  context,
                  '/forumpage',
                  arguments: {"forumId": item['forum']['id'].toString()},
                );
              } else {
                Navigator.pushNamed(
                  context,
                  '/userMemberPage',
                  arguments: {"userId": item['userInfo']['userId'].toString()},
                );
              }
            },
            child: Text(
              pageSource == null
                  ? item['forum']['name']
                  : item['userInfo']['userName'],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                // color: Color.fromRGBO(33, 29, 47, 1),
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          // width: ScreenUtil().setWidth(400),
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
                    text: '' + _doSource(),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  item['userInfo']['userTag'] != null
                      ? WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 2),
                            color: Color.fromRGBO(221, 221, 221, 0.5),
                            child: Text(
                              item['userInfo']['userTag']['data'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 4, right: 4),
                          ),
                        )
                      : TextSpan(
                          text: '',
                        ),
                ],
              ),
            ),
            // child: Text(
            //   Utils.moments(item['gmtCreate']) + ' · ' + _doSource(),
            //   style: TextStyle(
            //     fontSize: ScreenUtil().setSp(24),
            //     color: Theme.of(context).hintColor,
            //   ),
            // ),
          ),
        ),
      ],
    );
  }

  _doSource() {
    if (pageSource == null) {
      return '来自' + item['userInfo']['userName'];
    } else if (pageSource == 'trends') {
      switch (source['type']) {
        case 'post':
          return '发布了帖子';
          break;
        case 'upvote':
          return '点赞了帖子';
          break;
        default:
          return '其他';
          break;
      }
    }
  }

  _userLi(context) {
    return Column(
      children: <Widget>[
        Container(
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
                text: item['userInfo']['userName'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  item['userInfo']['userTag'] != null
                      ? WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 2),
                            color: Color.fromRGBO(221, 221, 221, 0.5),
                            child: Text(
                              item['userInfo']['userTag']['data'],
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 4, right: 4),
                          ),
                        )
                      : TextSpan(
                          text: '',
                        ),
                  TextSpan(
                    text: ' · ' + Utils.moments(item['gmtCreate']),
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // child: RichText(
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   text: TextSpan(
            //     text: item['userInfo']['userName'] + ' · ',
            //     style: TextStyle(
            //       fontSize: ScreenUtil().setSp(26),
            //       color: Theme.of(context).hintColor,
            //       fontWeight: FontWeight.w500,
            //     ),
            //     children: <TextSpan>[
            //       WidgetSpan(
            //         alignment: PlaceholderAlignment.middle,
            //         child: Image.asset(
            //           'assets/noavatar.png',
            //           width: 20,
            //           height: 20,
            //         ),
            //       ),
            //       TextSpan(
            //         text: Utils.moments(item['gmtCreate']),
            //         style: TextStyle(
            //           color: Theme.of(context).hintColor,
            //           fontWeight: FontWeight.normal,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ),
      ],
    );
  }

}