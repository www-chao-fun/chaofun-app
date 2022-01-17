import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';


class ChatList {
  ChatList({
    @required this.name,
    @required this.type,
  });

  final String name;
  final String type;
}

class ChatListData {
  Future<bool> isNull() async {
//    final str = await getConversationsListData();
//    List<dynamic> data = json.decode(str);
//    return !listNoEmpty(data);

    return true;
  }

  chatListData() async {
    List<dynamic> chatList = new List<ChatList>();
    String avatar;
    String name;
    int time;
    String identifier;
    dynamic type;
    String msgType;

    var response = await HttpUtil.instance.get(Api.ChatChannelList, parameters: {});

    return response['data'];
  }
}
