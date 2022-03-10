import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/font.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/utils/check.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/items/article_widget.dart';
import 'package:flutter_chaofan/widget/items/bottom_widget.dart';
import 'package:flutter_chaofan/widget/items/image_widget.dart';
import 'package:flutter_chaofan/widget/items/link_widget.dart';
import 'package:flutter_chaofan/widget/items/predict_widget.dart';
import 'package:flutter_chaofan/widget/items/top_widget.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_chaofan/widget/items/vote_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ItemIndex extends StatelessWidget {
  Map item;
  String type;
  String cate;
  bool isComment;
  ItemIndex({Key key, this.item, this.type, this.cate, this.isComment})
      : super(key: key);
  Widget doItem(context, item) {
    switch (item['type']) {
      case 'image':
        return ImageWidget(
            imgurl: KSet.imgOrigin + item['imageName'], item: item);
        // return VideoWidget(item: item);
        break;
      case 'link':
        return LinkWidget(item: item);
        break;
      case 'article':
        return ArticleWidget(item: item);
        break;
      case 'gif':
      case 'inner_video':
        if (Provider.of<UserStateProvide>(context, listen: false).hasNetWork) {
          if (item['type'] == 'inner_video') {
            return Container(
              width: ScreenUtil().setWidth(750),
              child: VideoWidget(item: item, video: true),
            );
          } else {
            return Container(
              width: ScreenUtil().setWidth(750),
              child: VideoWidget(item: item),
            );
          }
        } else {
          return Container(
            height: ScreenUtil().setWidth(400),
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Container(
                height: ScreenUtil().setWidth(180),
                child: Column(
                  children: [
                    Image.asset('assets/images/_icon/videoError.png'),
                    Text(
                      '网络异常，视频加载失败',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: Color.fromRGBO(153, 153, 153, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        break;
      case 'video':
        return LinkWidget(item: item);
        break;
      case 'vote':
        return VoteWidget(item: item);
        break;
      case 'forward':
        return _forwardWidget(context, item);
        break;
      case 'prediction':
        return Column(
          children: [
            PredictWidget(item: item),
            this.cate != 'prediction'
                ? Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 5),
              height: ScreenUtil().setHeight(90),
              padding: EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                color: Color.fromRGBO(227, 237, 247, 1),
                borderRadius:
                BorderRadius.circular(ScreenUtil().setWidth(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['predictionsTournament']['name'],
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      color: Color.fromRGBO(83, 83, 83, 1),
                    ),
                  ),
                  MaterialButton(
                    color: Color.fromRGBO(255, 147, 0, 0.7),
                    child: new Text(
                      '点击查看',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                      ),
                    ),
                    elevation: 0,
                    minWidth: ScreenUtil().setWidth(180),
                    height: ScreenUtil().setWidth(60),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () async {
                      Navigator.pushNamed(context, '/predictionpage',
                          arguments: {
                            'forumId': item['forum']['id'],
                            'forumName': item['forum']['name'],
                          });
                    },
                  ),
                ],
              ),
            )
                : Container(
              height: 0,
            ),
          ],
        );
        break;
      default:
        return _default();
        break;
    }
  }

  Widget _forwardWidget(context, item) {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.only(left: 10, right: 10, top: 14, bottom: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/postdetail',
                arguments: {"postId": item['sourcePost']['postId'].toString()},
              );
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                item['sourcePost']['forum']['name'] +
                    ' · ' +
                    item['sourcePost']['title'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          doItem(context, item['sourcePost']),
        ],
      ),
    );
  }

  Widget _default() {
    return Container(
      height: ScreenUtil().setWidth(150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
            width: 0.5,
            color: Color.fromRGBO(235, 235, 235, 1),
          )),
      child: Text(
        '当前版本不支持的类型，请尝试升级版本查看',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget doTitle(context, item, vs) {
    if (item['type'] != 'link' && item['type'] != 'video') {
      return InkWell(
        onTap: () {
          if (item['type'] != 'video') {
            Navigator.pushNamed(
              context,
              '/postdetail',
              arguments: {"postId": item['postId'].toString()},
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WebViewExample(url: item['link'], title: item['title']),
              ),
            );
          }
        },
        child: InkWell(
          highlightColor: Colors.grey,
          onLongPress: () {
            print('长按');
            var title = "";
            if (item['type'] == 'link') {
              Clipboard.setData(ClipboardData(text: item['link']));
              title = '已复制链接';
            } else {
              Clipboard.setData(ClipboardData(text: item['title']));
              title = '已复制标题';
            }
            Fluttertoast.showToast(
              msg: title,
              gravity: ToastGravity.CENTER,
              // textColor: Colors.grey,
            );
          },
          onTap: () {
            if (item['type'] != 'video') {
              Navigator.pushNamed(
                context,
                '/postdetail',
                arguments: {"postId": item['postId'].toString()},
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WebViewExample(url: item['link'], title: item['title']),
                ),
              );
            }
          },
          child: item['title'] != null && item['title'].toString().trim() != ''?  Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30),
                top: 0,
                bottom: 5),
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  getTag(context, item),
                  vs != null &&
                      (item['type'] == 'vote' ||
                          item['type'] == 'prediction')
                      ? WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      // color: KColor.primaryColor,
                      padding: EdgeInsets.only(left: 0, right: 0),
                      margin: EdgeInsets.only(right: 0),
                      child: Text(
                        '【' + doTypeName(item['type']) + '】',
                        style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                  )
                      : TextSpan(text: ''),
                  // TextSpan(
                  //   text: (item['tags'] != null && item['tags'].length > 0
                  //       ? ('[' + item['tags'][0]['name'] + '] ')
                  //       : ''),
                  //   style: TextStyle(
                  //     fontSize: ScreenUtil().setSp(30),
                  //     // color: Color.fromRGBO(255, 147, 0, 1),
                  //     color: (item['tags'] != null &&
                  //             item['tags'].length > 0 &&
                  //             item['tags'][0]['backgroundColor'] != null &&
                  //             item['tags'][0]['backgroundColor'] != null)
                  //         ? fromHex(item['tags'][0]['backgroundColor'])
                  //         : Color.fromRGBO(255, 147, 0, 1),
                  //     // fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  TextSpan(
                    text: item['title'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ) : Container(),
        ),
      );
    } else {
      if (vs == null) {
        return Container(
          color: Colors.blue,
          height: 0,
          child: Text(''),
        );
      } else {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChaoFunWebView(
                  url: item['link'],
                  title: item['title'],
                  showAction: 0,
                  cookie: true,
                  showHeader: true,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            // color: Colors.blue,
            constraints: BoxConstraints(
              minHeight: ScreenUtil().setWidth(130),
            ),
            child: Text(
              item['title'],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                color: KColor.defaultTitleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  doTypeName(val) {
    switch (val) {
      case 'article':
        return '文章';
        break;
      case 'vote':
        return '投票';
        break;
      case 'prediction':
        return '竞猜';
        break;
      default:
        return '未知';
    }
  }

  static InlineSpan getTag(BuildContext context, Map item) {
    return item['tags'] != null && item['tags'].length > 0 ? WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        margin: EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              ScreenUtil().setWidth(4)),
          color: (item['tags'] != null &&
              item['tags'].length > 0 &&
              item['tags'][0]['backgroundColor'] !=
                  null &&
              item['tags'][0]['backgroundColor'] !=
                  null)
              ? fromHex(item['tags'][0]['backgroundColor'])
              : Color.fromRGBO(255, 147, 0, 1),
        ),
        child: Text(
          (item['tags'] != null && item['tags'].length > 0
              ? (item['tags'][0]['name'])
              : ''),
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    )
        : TextSpan();

  }

  @override
  Widget build(BuildContext context) {
    // var d = new DateTime(2019, 1, 10, 9, 30);
    // print(d);
    clearMemoryImageCache();
    return Consumer<UserStateProvide>(
      builder:
          (BuildContext context, UserStateProvide disabledList, Widget child) {
        var disabledPostList =
            Provider.of<UserStateProvide>(context).disabledPostList;
        var disabledUserList =
            Provider.of<UserStateProvide>(context).disabledUserList;
        if (!disabledPostList.contains(item['postId']) &&
            (item['userInfo'] != null) &&
            !disabledUserList.contains(item['userInfo']['userId'])) {
          return InkWell(
              onTap:() {
                Navigator.pushNamed(
                  context,
                  '/postdetail',
                  arguments: {
                    "postId": item['postId']
                        .toString()
                  },
                );
              },
              child: Container(
                width: ScreenUtil().setWidth(750),
                margin: EdgeInsets.only(bottom: 0, left: 0, right: 0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  margin: EdgeInsets.only(bottom: 5),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30),
                          right: ScreenUtil().setWidth(30),
                        ),
                        child: ItemsTop(
                          item: item,
                          type: type,
                          // callTag: callTag,
                        ),
                      ),
                      Container(
                        // color: Colors.red,
                        child: Provider.of<UserStateProvide>(context, listen: false)
                            .modelType !=
                            'model1' ||
                            (this.cate == 'prediction')
                            ? Column(
                          children: <Widget>[
                            doTitle(context, item, null),
                            Stack(
                              children: [
                                doItem(context, item),
                                 Positioned(
                                    top: 0,
                                    left: 0,
                                    child:
                                    new Visibility(
                                      visible: item == null || item['type'] == 'link' || item['title']== null || item['title'] == '',
                                      child:
                                      Text.rich(
                                    TextSpan(
                                        children: [getTag(context, item)]
                                    ))),
                                ),
                              ]
                            ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: doTitle(context, item, '1'),
                            ),
                            item['type'] != 'vote' &&
                                item['type'] != 'prediction'
                                ? Container(
                              margin: EdgeInsets.only(
                                  right: ScreenUtil().setWidth(20)),
                              width: ScreenUtil().setWidth(180),
                              height: ScreenUtil().setWidth(130),
                              // color: Colors.red,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(4)),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/postdetail',
                                          arguments: {
                                            "postId": item['postId']
                                                .toString()
                                          },
                                        );
                                      },
                                      child: _getImageUrl(item),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: _postType(item),
                                  ),
                                ],
                              ),
                            )
                                : Container(
                              width: 0,
                            ),
                          ],
                        ),
                      ), //gmtComment

                      item['gmtComment'] != null &&
                          this.isComment != null &&
                          this.isComment
                          ? InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/postdetail',
                            arguments: {"postId": item['postId'].toString()},
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10, top: 5),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                left: 2, right: 2, top: 2, bottom: 2),
                            color: Color.fromRGBO(221, 221, 221, 0.5),
                            width: ScreenUtil().setWidth(230),
                            child: Text(
                              '最新评论·' + Utils.moments(item['gmtComment']),
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(24),
                                color: Color.fromRGBO(33, 29, 47, 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 4, right: 4),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                      Container(
                        // color: Colors.black,
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30),
                          right: ScreenUtil().setWidth(30),
                        ),
                        child: BottomWidget(item: item),
                      ),
                    ],
                  ),
                  // padding: EdgeInsets.only(
                  //   left: ScreenUtil().setWidth(30),
                  //   right: ScreenUtil().setWidth(30),
                  // ),
                ),
              )
          );
        } else {
          return Container(
            height: 0,
          );
        }
      },
    );
  }

  Widget _postType(item) {
    switch (item['type']) {
      case 'image':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.image_outlined,
            color: Colors.white,
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.play_circle_outline_outlined, color: Colors.white),
        );
        break;
      case 'link':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.link_rounded, color: Colors.white),
        );
        break;
      case 'article':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.article, color: Colors.white),
        );
        break;
      default:
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.article, color: Colors.white),
        );
    }
  }

  _getImageUrl(item) {
    switch (item['type']) {
      case 'image':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: CachedNetworkImage(
            imageUrl: KSet.imgOrigin +
                item['imageName'] +
                '?x-oss-process=image/resize,w_200/format,webp/quality,q_75',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: CachedNetworkImage(
            imageUrl: (KSet.imgOrigin +
                (item['type'] == 'inner_video'
                    ? item['video']
                    : item['imageName'])) +
                '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,w_200',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
        break;
      case 'link':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: item['cover'] != null
              ? CachedNetworkImage(
            imageUrl: (KSet.imgOrigin +
                item['cover'] +
                '?x-oss-process=image/resize,w_200/format,webp/quality,q_75'),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
              : Image.asset('assets/images/_icon/link.png'),
        );
        break;
      case 'article':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: item['imageName'] != null
              ? CachedNetworkImage(
            imageUrl: (KSet.imgOrigin +
                item['imageName'] +
                '?x-oss-process=image/resize,w_450/format,webp/quality,q_75'),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
              : CachedNetworkImage(
            imageUrl:
            'https://i.chao.fun/biz/9563cdd828d2b674c424b79761ccb4c0.png',
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      case 'prediction':
        return Container(
          width: 0,
        );
        break;
      default:
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: Text('不支持的类型'),
        );
    }
  }

// callTag(data) {
//   item['tags'] = [
//     {'name': '找不到'}
//   ];
// }
}
