import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/font.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/model/im/chat_list.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/post_detail/postwebview.dart';
import 'package:flutter_chaofan/pages/post_detail/webview_flutter.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/utils/check.dart';
import 'package:flutter_chaofan/utils/const.dart';
import 'package:flutter_chaofan/utils/contacts.dart';
import 'package:flutter_chaofan/utils/notice.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/im/my_conversation_view.dart';
// import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/image/selfs_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:images_picker/images_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_chaofan/database/userHelper.dart';
import 'package:flutter_chaofan/database/model/userDB.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_chaofan/provide/user.dart';


import 'chat_page.dart';

class ChatHomePage extends StatefulWidget {
//  static ChatHomePage _instance;
//
//  // 私有的命名构造函数
//  ChatHomePage._internal();
//
//  static ChatHomePage getInstance() {
//    if (_instance == null) {
//      _instance = ChatHomePage._internal();
//    }
//
//    return _instance;
//  }

  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>  with AutomaticKeepAliveClientMixin {


  List<dynamic> _chatData = [];

  bool firstChannelConnect = false;
  Future getChatData() async {
    var result = await ChatListData().chatListData();
    if (mounted) setState(() {
      _chatData  = result;
      if (_chatData == null) {
        _chatData = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    reconnect();
    sendHeartBeat();
    Notice.addListener("logout", (data) => close());
  }

  Future<void> close() async {
    print("chat_home_page logout");
    allChannel.sink.close(null);
  }


  Future<void> reconnect() async {
    getChatData();
    print('Provider.of<UserStateProvide>(context, listen: false).ISLOGIN ' + Provider.of<UserStateProvide>(context, listen: false).ISLOGIN.toString());
    if (firstChannelConnect) {
      firstChannelConnect = false;
    } else {
      await Future.delayed(Duration(milliseconds: 1000));
    }
    allChannel = WebSocketChannel.connect(
      Uri.parse('wss://chao.fun/ws/v0/all'),
    );
    authStream();
    allChannel.stream.listen((data) => processMessage(data),
        onDone: reconnect);
  }

  void processMessage(data) {
    Map<String, dynamic> result = json.decode(data);

    print('processMessage');
    print(data.toString());

    if (result['scope'] == 'chat') {
      if (result['data']['type'] == 'message' || result['data']['type'] == "load_result") {
        String eventName = "chat_channel_" + result['data']['data']['channelId'].toString();
        print('eventName :' + eventName);
        Notice.send(eventName , result['data']);
      }

      if (result['data']['type'] == 'message') {
        chatChannelSort(result['data']['data']['channelId'], result['data']['data']);
      }
    }
  }

  void chatChannelSort(channelId, message) async {
    dynamic targetChannel = null;
    for (var channel in _chatData) {
      if (channel['id'] == channelId) {
        targetChannel = channel;
      }
    }

    if (targetChannel != null) {
      setState(() {
        _chatData.remove(targetChannel);
      });
      targetChannel['lastMessageType'] = message['type'];
      targetChannel['lastMessageTime'] = message['time'];
      targetChannel['lastMessageContent'] = message['content'];
      targetChannel['lastMessageSender'] = message['sender'];
      setState(() {
        _chatData.insert(0, targetChannel);
      });
    } else {
      var response = await HttpUtil().get(Api.getChatChannelInfo, parameters: {"channelId": channelId});

      if (response['data'] != null) {
        setState(() {
          _chatData.insert(0, response['data']);
        });
      }

    }
  }

  void getLastChatRoomSorted() async {

  }

  Future sendHeartBeat() async {
    while(true) {
      try {
        await Future.delayed(Duration(milliseconds: 3000));
        allChannel.sink.add("{\"scope\": \"heart_beat\"}");
      } catch (e) {}
    }
  }

  Future authStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.get('cookie');
    print(value);
    allChannel.sink.add("{\"scope\": \"auth\", \"data\": \"" + value + "\"}");
  }

  Widget timeView(int time) {
    return new SizedBox(
      width: 80.0,
      child: new Text(
        Utils.chatTime(time),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: mainTextColor, fontSize: 12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
//    if (!listNoEmpty(_chatData)) return new HomeNullView();
    print("_ChatHomePageState");
    print(_chatData.toString());
    return
      new SafeArea(
          child: Scaffold(
            backgroundColor: KColor.defaultPageBgColor,
            appBar: PreferredSize(
              child: AppBar(
                elevation: 0,
                brightness: Brightness.light,
                title: Text(
                  '聊天',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(34),
                  ),
                ),
                actions: [TextButton(onPressed: () {
                  getChatData();
                }, child: Text("刷新"))],
                backgroundColor: Colors.white,
              ),
              preferredSize: Size.fromHeight(40),
            ),
            body:
            Provider.of<UserStateProvide>(context, listen: false).ISLOGIN ? (_chatData.length != 0 ?
            new Container(
                color: Color(AppColors.BackgroundColor),
                child: new ScrollConfiguration(
                    behavior: MyBehavior(),
                    child: new ListView.builder(
                      itemCount: _chatData?.length ?? 1,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic>  data = _chatData[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _chatData[index]['unReadMessageNumber'] = 0;
                            });
                            routePush(context, new ChatPage(
                              id: data['id'],
                              title: data['name'],
                              type: data['type'] == 'group' ? 2 : 1,
                              quitCallback: () {
                                getChatData();
                              },
                            ));
                          },
                          child: new MyConversationView(
                            imageUrl: strNoEmpty(data['avatar']) ? KSet.imgOrigin + data['avatar'] + '?x-oss-process=image/resize,h_120/format,webp/quality,q_75' : 'https://i.chao.fun/biz/08a2d3a676f4f520cb99910496e48b4e.png?x-oss-process=image/resize,h_80/format,webp/quality,q_75',
                            title: data['name'] ?? '',
                            content: getShowContent(data),
                            time: data['lastMessageTime'] == null ?  new Container() : timeView(data['lastMessageTime'])  ,
                            isBorder: true,
                            unReadMessageNumber: data['unReadMessageNumber'],
                          ),
                        );
                      },
                    )
                )

            ): Center(
              child: Text('暂无聊天，请到支持的版块加入聊天 例：网络迷踪'),
            )): Center(
              child: Text('登录后查看聊天'),
            ),
          )
      );
  }

  String getShowContent(data) {
    String content = '';

    if (data['lastMessageType'] == 'text') {
        content = data['lastMessageContent'].replaceAll("\n", "");
    } else if (data['lastMessageType'] == 'image') {
        content = "[图片]";
    }

    if (content == null) {
      return '';
    }

    if (content.length > 20) {
      content = content.substring(0, 15) + '...';
    }

    if (data['lastMessageType'] == 'system' || data['type'] == 'single') {
      return content;
    } else {
      if (data['lastMessageSender'] != null) {
        return data['lastMessageSender']['userName'] + ":" + content;
      } else {
        return content;
      }
    }
  }

  @override
  bool get wantKeepAlive => true;


  @override
  void dispose() {
    Notice.removeListenerByEvent("logout");
    allChannel.sink.close(null);
  }

}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}

WebSocketChannel allChannel = WebSocketChannel.connect(
  Uri.parse('wss://chao.fun/ws/v0/all'),
);

Future<dynamic> routePush(BuildContext context, Widget widget) {
  final route = new CupertinoPageRoute(
    builder: (BuildContext context) => widget,
    settings: new RouteSettings(
      name: widget.toStringShort(),
    ),
  );
  return Navigator.push(context, route);
}

