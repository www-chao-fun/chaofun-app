import 'package:flutter/material.dart';
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
}
