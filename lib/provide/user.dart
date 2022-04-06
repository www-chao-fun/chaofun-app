import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ChangeNotifier通知
// 切换底部导航栏
class UserStateProvide with ChangeNotifier {
  bool ISLOGIN = false;
  var userInfo;
  var pref;
  var disabledPostList = [];
  var disabledUserList = [];
  var homeNavIndex = 'home';
  var sort;
  var sortBool;
  var indexDialog;
  var appVersionInfo;
  bool doubleTap = false;
  bool onlyNew = false;
  bool autoPlayVideo = true;
  var searchHistory = [];

  bool showAgree = false;

  bool hasNetWork = true;

  bool loopGif = true;
  bool autoPlayGif = true;
  bool hasNewMessage = false;
  var theme = 'normal'; // normal, dark, 
  var unreadMessage = 0;
  var modelType = 'model2';
  var commentOrderType = 'last';
  var fixedCommentOrder = 'hot';
  var lastOrderType = 'hot';

  List remmenberForumList = [];

  var order = 'hot';
  var range = '1month';

  void init() {
    getLoopGif();
    getAutoPlayVideo();
    getAutoPlayGif();
    getFixedCommentOrder();
  }

  List looksList = [
    {
      'icon': 'assets/images/_icon/tuijian.png',
      'label': '推荐',
      'value': 'recommend'
    },
  ];
  void setOnlyNew(val) async {
    onlyNew = val;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onlyNew', val);
    notifyListeners();
  }

  void setModelType(val) {
    modelType = val;
    notifyListeners();
  }

  getOnlyNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    onlyNew = true; //prefs.getBool('onlyNew');

    notifyListeners();
    // return onlyNew;
  }

  void setOrder(v) async {
    order = v;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('order', v);
    notifyListeners();
  }

  // void setRange(v) async {
  //   range = v;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('range', v);
  //   notifyListeners();
  // }

  getOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('xxxxxxxxxxx');
    order =
        (prefs.getString('order') != null ? prefs.getString('order') : 'hot');
    onlyNew = prefs.getBool('onlyNew') == null
        ? false
        : prefs.getBool('onlyNew'); //prefs.getBool('onlyNew');
    notifyListeners();
    return {'order': order, 'onlyNew': onlyNew};
  }

  // void getRange(v) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   range = (prefs.getString('range') != null
  //       ? prefs.getString('range')
  //       : '1month');
  //   notifyListeners();
  // }

  void setLoopGif() async {
    loopGif = !loopGif;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('loopGif', loopGif);
    notifyListeners();
  }

  Future<bool> getLoopGif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('loopGif') != null) {
      loopGif = prefs.getBool('loopGif');
    }
    return loopGif;
  }

  void setTheme(theme) async {
    this.theme = theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
    notifyListeners();
  }

  Future<String> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('theme') != null) {
      var tmpTheme = prefs.getString('theme');
      theme = tmpTheme;
    }
    return theme;
  }
  
  Future<void> setAutoPlayGif() async {
    autoPlayGif = !autoPlayGif;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoPlayGif', autoPlayGif);
    notifyListeners();
  }

  Future<bool> getAutoPlayGif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('autoPlayGif') != null) {
      autoPlayGif = prefs.getBool('autoPlayGif');
    }
    return autoPlayGif;
  }

  Future<void> setAutoPlayVideo() async {
    autoPlayVideo = !autoPlayVideo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoPlayVideo', autoPlayVideo);
    notifyListeners();
  }

  Future<bool> getAutoPlayVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('autoPlayVideo') != null) {
      autoPlayVideo = prefs.getBool('autoPlayVideo');
    }
    return autoPlayVideo;
  }

  Future<void> setFixedCommentOrder(order) async {
    fixedCommentOrder = order;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fixedCommentOrder', order);
    notifyListeners();
  }

  Future<String> getFixedCommentOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('fixedCommentOrder') != null) {
      fixedCommentOrder = prefs.getString('fixedCommentOrder');
    }
    return fixedCommentOrder;
  }

  var changeTag;
  void setChangeTag(item) {
    changeTag = item;
    notifyListeners();
  }

  void setAgree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('showAgree') != null ? true : false;
    showAgree = a;
    notifyListeners();
  }

  void setHasNetWork(value) {
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    print(value);
    hasNetWork = value;
    notifyListeners();
  }

  void setDoubleTap(value) {
    doubleTap = value;
    notifyListeners();
  }

  void setIndexDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('indexDialog') != null
        ? prefs.getString('indexDialog')
        : 'false';
    indexDialog = a;
    notifyListeners(); //通知监听者刷新页面
  }

  void changeIndexDialog(str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    indexDialog = str;
    prefs.setString('indexDialog', str);
    notifyListeners(); //通知监听者刷新页面
  }

  void setSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('searchHistory');
    print('renren');
    print(a);
    if (a != null) {
      searchHistory = json.decode(a.toString());
    } else {
      searchHistory = [];
    }
    // disabledPostList = json.decode(a.toString());
    notifyListeners();
  }

  void addSearchHistory(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var i = searchHistory.indexOf(item);

    if (i > -1) {
      searchHistory.removeAt(i);
    }

    searchHistory.insert(0, item);

    if (searchHistory.length > 7) {
      searchHistory = searchHistory.sublist(0, 7);
    }
    var a = json.encode(searchHistory).toString();
    prefs.setString('searchHistory', a);
    notifyListeners();
  }

  void delSearchHistory(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    searchHistory.remove(item);
    var a = json.encode(searchHistory).toString();
    prefs.setString('searchHistory', a);
    notifyListeners();
  }

  void removeSharedPreferences(String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(str);
    if (str == 'cookie') {
      changeState(false);
      print('清空cookie');
      prefs.remove('cookie');
      print(prefs.getString("cookie"));
    }
    if (str == 'looksList') {
      if (ISLOGIN) {
        looksList = [
          {
            'icon': 'assets/images/_icon/quanzhan.png',
            'label': '全站',
            'value': 'all'
          },
          {
            'icon': 'assets/images/_icon/tuijian.png',
            'label': '推荐',
            'value': 'recommend'
          },
          {
            'icon': 'assets/images/_icon/guanzhu.png',
            'label': '关注',
            'value': 'focused'
          },
        ];
      } else {
        looksList = [
          {
            'icon': 'assets/images/_icon/tuijian.png',
            'label': '推荐',
            'value': 'recommend'
          },
        ];
      }
    }
    if (str == 'remmenberForumList') {
      remmenberForumList = [];
    }
    notifyListeners();
  }

  void setDisabledPostList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('disabledPostList');
    if (a != null) {
      disabledPostList = json.decode(a.toString());
    } else {
      disabledPostList = [];
    }
    // disabledPostList = json.decode(a.toString());
    notifyListeners();
  }

  void addDisabledList(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    disabledPostList.add(item);
    var a = json.encode(disabledPostList).toString();
    prefs.setString('disabledPostList', a);
    notifyListeners();
  }

  void setDisabledUserList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('disabledUserList');
    if (a != null) {
      disabledUserList = json.decode(a.toString());
    } else {
      disabledUserList = [];
    }
    // disabledPostList = json.decode(a.toString());
    notifyListeners();
  }

  void addDisabledUserList(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    disabledUserList.add(item);
    var a = json.encode(disabledUserList).toString();
    prefs.setString('disabledUserList', a);
    notifyListeners();
  }

  inits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  void setSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = prefs.getString('sort');

    sort = (a == null ? 'new' : a);
    //
    notifyListeners();
  }

  void setStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ISLOGIN = prefs.getString('ISLOGIN') == '1' ? true : false;

    notifyListeners();
  }

  void changeState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var a = json.encode(disabledUserList).toString();

    ISLOGIN = state;
    if (!state) {
      if (looksList[2]['value'] == 'focused') {
        print('ttttttttttttttttttttttttttttttttt');
        looksList.removeAt(2);
      }
      if (looksList[0]['value'] == 'all') {
        print('dddddddddddddddddddddddddd');
        looksList.removeAt(0);
      }
      print(looksList);
      prefs.setString('looksList', jsonEncode(looksList).toString());
      getLooksList();
    }

    notifyListeners(); //通知监听者刷新页面
  }

  void changeHasMessage(hasMessage) {
    hasNewMessage = hasMessage;
    notifyListeners();
  }
  void changeUserInfo(info) {
    print('更新用户信息');
    print(info);
    userInfo = info;
    notifyListeners(); //通知监听者刷新页面
  }

  void changeHomeNavIndex(index) {
    // 监听首页导航点击
    homeNavIndex = index;
    notifyListeners();
  }

  void changeSort(sort) {
    sort = sort;
    notifyListeners(); //通知监听者刷新页面
  }

  void changeSortBool(sort, value) async {
    sortBool = sort;
    if (value != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // var a = json.encode(disabledUserList).toString();
      prefs.setString('sort', value);
    }

    notifyListeners(); //通知监听者刷新页面
  }

  void changeAppVersionInfo(versionInfo) {
    appVersionInfo = versionInfo;
    notifyListeners(); //通知监听者刷新页面
  }

  void getLooksList() async {
    // print('执行120');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('looksList') != null) {
      var a = prefs.getString('looksList');
      var b = json.decode(a.toString());
      if (!ISLOGIN) {
        if (b[0]['value'] == 'all') {
          b.removeAt(0);
        }
        if (b.length > 2 && b[2]['value'] == 'focused') {
          b.removeAt(2);
        }
      } else {
        if (b[0]['value'] != 'all') {
          b.insert(0, {
            'icon': 'assets/images/_icon/quanzhan.png',
            'label': '全站',
            'value': 'all'
          });
        }
        if (b.length > 2 && b[2]['value'] != 'focused') {
          b.insert(2, {
            'icon': 'assets/images/_icon/guanzhu.png',
            'label': '关注',
            'value': 'focused'
          });
        }
      }
      looksList = b;
      //通知监听者刷新页面
    } else {
      if (ISLOGIN) {
        if (looksList[0]['value'] != 'all') {
          looksList.insert(0, {
            'icon': 'assets/images/_icon/quanzhan.png',
            'label': '全站',
            'value': 'all'
          });
        }
        if (looksList.length < 3) {
          looksList.insert(2, {
            'icon': 'assets/images/_icon/guanzhu.png',
            'label': '关注',
            'value': 'focused'
          });
        }
        print('顶部内容2');
      } else {
        print('执行110');
      }
    }
    notifyListeners();
  }

  void setLooksList(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool has = false;
    int index = 0;
    List a;
    List b;
    if (ISLOGIN) {
      a = looksList.take(3).toList();
      b = looksList.skip(3).toList();
    } else {
      a = looksList.take(1).toList();
      b = looksList.skip(1).toList();
    }

    for (var i = 0; i < b.length; i++) {
      if (b[i]['value'] == item['value'] &&
          b[i]['value'] != 'all' &&
          b[i]['value'] != 'recommend' &&
          b[i]['value'] != 'focused') {
        has = true;
        index = i;
      }
    }
    if (!has) {
      //通知监听者刷新页面
    } else {
      b.removeAt(index);
    }
    b.insert(0, item);
    a.addAll(b);
    looksList = a;
    var c = jsonEncode(a).toString();
    prefs.setString('looksList', c);
    notifyListeners();
  }

  void getRemmenberForumList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('remmenberForumList') != null) {
      remmenberForumList =
          json.decode(prefs.getString('remmenberForumList').toString());
    }
    notifyListeners();
  }

  void setRemmenberForumList(item) async {
    if (remmenberForumList.length > 0) {
      var has = false;
      var index = 0;
      for (var i = 0; i < remmenberForumList.length; i++) {
        if (remmenberForumList[i]['id'] == item['id']) {
          has = true;
          index = i;
        } else {}
      }
      if (has) {
        remmenberForumList.removeAt(index);
        remmenberForumList.insert(0, item);
      } else {
        remmenberForumList.insert(0, item);
      }
    } else {
      remmenberForumList.add(item);
    }
    var dos = remmenberForumList.take(10).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var c = jsonEncode(dos).toString();
    prefs.setString('remmenberForumList', c);
    notifyListeners();
  }
}
