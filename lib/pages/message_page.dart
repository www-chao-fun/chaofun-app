import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/nonetwork_page.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/items/msg_widget.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  static const _cityNames = {
    '北京': ['东城区'],
    '郑州': ['高新区'],
    '上海': ['黄浦区'],
    '杭州': ['西湖区'],
  };
  EasyRefreshController _controller;
  double appBarAlpha = 0;
  int counter;
  var params = {
    "pageSize": '20',
    "marker": '',
    'type': ''
  }; //comment,comment_post,upvote,at
  List<Map> pageData = [];
  var commentFuture;
  HomeService homeService = HomeService();
  var ISLOGIN;

  List listDeat = [];

  int _count = 10;

  Future<void> _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
    _controller.finishRefresh();
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      getDatas('');
    }
    _controller.finishLoad();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = EasyRefreshController();
    print('我的消息1');
    getDatas('');
    // commentFuture = homeService.messageList(params, (response) {
    //   var data = response;
    //   // setState(() {
    //   setState(() {
    //     params['marker'] = data['marker'] != null ? data['marker'] : '';
    //     pageData = (data['messages'] as List).cast();
    //   });
    // }, (message) {
    //   print('失败了');
    // });
  }

  void inits(context) {
    var islogin = Provider.of<UserStateProvide>(context, listen: false).ISLOGIN;
    setState(() {
      ISLOGIN = islogin;
    });
  }

  Future futuregetDatas(type) async {
    var data = await HttpUtil().get(Api.messageList, parameters: params);
    // print('我的消息2');
    // print(data);
    // if (type == 'refresh') {
    //   setState(() {
    //     pageData = [];
    //   });
    // }
    // if (data['data'] != null && data['data']['messages'].length > 0) {
    //   List<Map> res = (data['data']['messages'] as List).cast();

    //   setState(() {
    //     pageData.addAll(res);

    //     params["marker"] = data['data']['marker'];
    //   });
    // } else {
    // }
    return data;
  }

  void getDatas(type) async {
    var data = await HttpUtil().get(Api.messageList, parameters: params);
    print('我的消息2');
    print(data);
    if (type == 'refresh') {
      setState(() {
        pageData = [];
      });
    }
    if (data['data'] != null && data['data']['messages'].length > 0) {
      List<Map> res = (data['data']['messages'] as List).cast();

      setState(() {
        pageData.addAll(res);

        params["marker"] = data['data']['marker'];
      });
    } else {
      // Fluttertoast.showToast(
      //   msg: '没有更多了~',
      //   gravity: ToastGravity.CENTER,
      // );
    }
  }

  void refreshData() async {
    setState(() {
      params['marker'] = '';
      getDatas('refresh');
    });
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        print('还没有开始网络请求');
        return Text('还没有开始网络请求');
      case ConnectionState.active:
        print('active');
        return Text('ConnectionState.active');
      case ConnectionState.waiting:
      // print('waiting');
      // return Center(
      //   child: CircularProgressIndicator(),
      // );
      case ConnectionState.done:
        print('done');
        if (snapshot.hasError) return NoNetWorkPage(callBack: KSet.reLoad);
        return Consumer<UserStateProvide>(
          builder: (BuildContext context, UserStateProvide user, Widget child) {
            if (user.ISLOGIN) {
              return EasyRefresh.custom(
                enableControlFinishRefresh: true,
                enableControlFinishLoad: true,
                controller: _controller,
                header: ClassicalHeader(
                  showInfo: false,
                  refreshReadyText: KSet.refreshReadyText,
                  refreshingText: KSet.refreshingText,
                  refreshText: KSet.refreshText,
                  refreshedText: KSet.refreshedText,
                  textColor: KSet.textRefreshColor,
                  refreshFailedText: '加载失败',
                ),
                footer: ClassicalFooter(
                  enableHapticFeedback: false,
                  showInfo: false,
                  loadingText: KSet.loadingText,
                  loadedText: KSet.loadedText,
                  textColor: KSet.textRefreshColor,
                  loadFailedText: '加载失败',
                ),
                onRefresh: _onRefresh,
                onLoad: _onLoading,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // return _item(pageData[index]);
                        return MsgWidget(
                          item: pageData[index],
                        );
                      },
                      childCount: pageData.length,
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text('登录后查看消息'),
              );
            }
          },
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    inits(context);
    return Scaffold(
        // backgroundColor: Color.fromRGBO(247, 247, 247, 1),
        appBar: AppBar(
          elevation: 0,
          leading: Container(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).textTheme.titleLarge.color,
                size: 20,
              ),
            ),
          ),
          // brightness: Brightness.light,
          title: Text(
            '消息',
            style:
            TextStyle(
                color: Theme.of(context).textTheme.titleLarge.color,
                fontSize: ScreenUtil().setSp(38)
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body:
        FutureBuilder(
          builder: _buildFuture,
          future: futuregetDatas(
              ''), // 用户定义的需要异步执行的代码，类型为Future<String>或者null的变量或函数
        ),
      );
  }

  _list() {
    if (pageData.length != 0) {
      List<Map> arr = [];
      List<Widget> listWidget = pageData.map((item) {
        return _item(item);
      }).toList();
      return Column(
        children: listWidget,
      );
    } else {
      return Center(
        child: Text('还没有消息哦~'),
      );
    }
  }

  Widget _item(item) {
    var sender = item['sender'] != null ? item['sender']['userName'] : '未登录用户';
    var text = "暂不支持该消息展示，请升级查看";

    var postTitle = '';

    if (item['post'] != null && item['post']['title'] != null) {
      postTitle = item['post']['title'];
    }

    var comment = '';

    if (item['comment'] != null && item['comment']['text'] != null) {
      comment = item['comment']['text'];
    }

    if (item['type'] == 'upvote_post') {
      text = '你的帖子「$postTitle」被用户「$sender」赞了';
    } else if (item['type'] == 'upvote_comment') {
      text = '你在「$postTitle」帖子的下的评论被用户「$sender」赞了';
    } else if (item['type'] == 'comment_post') {
      text = '你的帖子「$postTitle」被用户「$sender」评论了，评论为「$comment」';
    } else if (item['type'] == 'sub_comment') {
      text = '你在「$postTitle」帖子下的评论被用户「$sender」回复了，回复为「$comment」';
    } else if (item['type'] == 'at') {
      text = '在「$postTitle」帖子下，用户「$sender」@你：「$comment」';
    } else if (item['type'] == 'delete_post') {
      if (item['reason'] != null) {
        text = '你的帖子「$postTitle」已被删除，原因为：${item["reason"]}';
      } else {
        text = '你的帖子「$postTitle」已被删除，请阅读炒饭和分区发帖规范。';
      }
    } else if (item['type'] == 'text_notice') {
      text = item['text'];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (item['post'] != null) {
            Navigator.pushNamed(
              context,
              '/postdetail',
              arguments: {"postId": item['post']['postId'].toString()},
            );
          } else if (item['type'] == 'text_notice' && item['link'] != null) {
            KSet.toNavigate(context, item['link'], '炒饭通知');
            // https://chao.fun/p/1026976
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
        ),
      ),
    );
  }
}
