import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:intl/intl.dart';

class Utils {
  // static DateTime now = new DateTime.now();
  static String moments(time) {
    DateTime now = new DateTime.now();
    var hisTime = new DateTime.fromMillisecondsSinceEpoch(time);
    var nowTime = now;
    var difference = nowTime.difference(hisTime);
    var inDays = difference.inDays;
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;
    String res;
    if (inDays > 0) {
      // print(object)
      // String formattedDate =
      // DateFormat('yyyy/MM/dd kk:mm').format(now); //DateFormat
      return (inDays.toString() + '天前');
      // return formattedDate;
    } else if (inHours > 0) {
      return (inHours.toString() + '小时前');
    } else if (inMinutes > 0) {
      return (inMinutes.toString() + '分钟前');
    } else if (inSeconds > 0) {
      return (inSeconds.toString() + '秒前');
    } else {
      return '刚刚';
    }
  }

  static String chatTime(time) {

    if (time == null) {
      return '';
    }

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);

    String monthParse = "0${dateTime.month}";
    String dayParse = "0${dateTime.day}";
    String hourParse = "0${dateTime.hour}";
    String minuteParse = "0${dateTime.minute}";

    String month = dateTime.month.toString().length == 1
        ? monthParse
        : dateTime.month.toString();
    String day = dateTime.day.toString().length == 1
        ? dayParse
        : dateTime.day.toString();

    String hour = dateTime.hour.toString().length == 1
        ? hourParse
        : dateTime.hour.toString();
    String minute = dateTime.minute.toString().length == 1
        ? minuteParse
        : dateTime.minute.toString();

    return '$month-$day $hour:$minute';
  }

  static void toNavigate(context, url, title) {
    String u = '';

    // String url = 'https://chao.fun';
    String title = '炒饭 - 分享奇趣、发现世界';

    var nativePush = false;
    Map arguments;

    if (url.startsWith("https://chao.fun/") ||
        url.startsWith("https://www.chao.fun") ||
        url.startsWith("http://chao.fun") ||
        url.startsWith("http://www.chao.fun") ||
        url.startsWith("https://chao.fun")) {
      var newUrl = url
          .replaceAll("https://chao.fun/", "")
          .replaceAll("https://www.chao.fun/", "")
          .replaceAll("http://chao.fun", "")
          .replaceAll("http://www.chao.fun", "");

      var a = newUrl.split('/');
      print('不一样');
      print(a);
      nativePush = true;
      if (a.length >= 2 && (a[0] == 'f' || a[0] == 'p' || a[0] == 'user')) {
        String start = a[0];
        String end = a[1];
        switch (start) {
          case "f":
            u = '/forumpage';
            arguments = {'forumId': end};
            break;
          case "user":
            u = '/userMemberPage';
            arguments = {'userId': end};
            break;
          case "p":
            u = '/postdetail';
            if (end.contains("?")) {
              var postId = end.split("?")[0];
              var paramsString = end.split("?")[1];
              arguments = {'postId': postId};

              // 支持评论跳转
              try {
                if (paramsString.contains("commentId")) {
                  for (var value in paramsString.split("&")) {
                    if (value.split("=")[0] == 'commentId') {
                      arguments.putIfAbsent("targetCommentId", () => int.parse(value.split("=")[1]));
                    }
                  }
                }
              } catch (e) {

              }
            } else {
              arguments = {'postId': end};
            }
            break;
        }
//        Future.delayed(Duration(seconds: 1), () {
        if (u != '') {
          print('u');
          print(u);
          Navigator.pushNamed(context, u, arguments: arguments);
        } else {}

//        });
      } else {
        print('跳转首页');
        if (url == 'https://www.chao.fun' ||
            url == 'http://www.chao.fun' ||
            url == 'https://chao.fun' ||
            url == 'http://chao.fun' ||
            url == 'https://www.chao.fun/' ||
            url == 'http://www.chao.fun/' ||
            url == 'https://chao.fun/' ||
            url == 'http://chao.fun/') {
          Provider.of<CurrentIndexProvide>(context, listen: false)
              .currentIndex = 0;
          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) => IndexPage()),
                (route) => route == null,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChaoFunWebView(
                url: url,
                title: title,
                showHeader: true,
                cookie: true,
              ),
            ),
          );
        }
      }
    }

    if (!nativePush) {
      title = '外部链接';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChaoFunWebView(
            url: url,
            title: title,
            showHeader: true,
            cookie: true,
          ),
        ),
      );
    }
  }

}
