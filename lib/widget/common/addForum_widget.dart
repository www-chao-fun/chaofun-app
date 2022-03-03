import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddForumWidget extends StatefulWidget {
  var height;
  Function callBack;
  AddForumWidget({Key key, this.height, this.callBack}) : super(key: key);

  @override
  _AddForumWidgetState createState() => _AddForumWidgetState();
}

class _AddForumWidgetState extends State<AddForumWidget> {
  List<Map> forums = [
    {
      "id": 2,
      "followers": 750,
      "posts": 280226,
      "name": "全网热门",
      "desc": "我们炒饭的爬虫辛辛苦苦，踏遍中文互联网，给你找来的最热。",
      "imageName": "01b465af196546ac5b021105fd80a5eb.png",
      "tag": 1
    },
    {
      "id": 3,
      "followers": 568,
      "posts": 33586,
      "name": "无聊图",
      "desc": "大部分是从 Reddit 抓的图...",
      "imageName": "990cf5792a356642fe46e7dbe577ebab.png",
      "tag": 1
    },
    {
      "id": 84,
      "followers": 1090,
      "posts": 2133,
      "name": "网络迷踪",
      "desc": "发帖前请看版规，本版块探究互联网时代下信息安全及如何防范个人隐私泄露的问题。QQ交流群：973423233",
      "imageName": "biz/b53f1c1ce135a855a69503259078f6f2.png",
      "tag": null
    },
    {
      "id": 65,
      "followers": 545,
      "posts": 1997,
      "name": "妹子",
      "desc": "窈窕淑女君子好逑~ ",
      "imageName": "biz/f5c7b3cb56346113a8e315991cce8efd.png",
      "tag": null
    },
    {
      "id": 80,
      "followers": 4,
      "posts": 4,
      "name": "王者荣耀",
      "desc": null,
      "imageName": "biz/e64766d436b9c8c468fe2eb2230ace60.jpg",
      "tag": 3
    },
    {
      "id": 41,
      "followers": 1060,
      "posts": 113,
      "name": "冷知识",
      "desc": "这个版块的内容不会太绝对的，饭友们，稍微跟冷知识搭边的就随便发哈。\n",
      "imageName": "biz/b74d14edb2db03280e97f22ba3a02b28.png",
      "tag": 4,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 17,
      "followers": 998,
      "posts": 52075,
      "name": "AB站",
      "desc": "自从上了AB站，爸妈再也不用担心我的屏幕太脏了，目前只支持提取A站的视频",
      "imageName": "biz/d08841421005660734775f289f27c7a3.png",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 10,
      "followers": 962,
      "posts": 3518,
      "name": "二次元",
      "desc": "此生无悔二次元，二次元版块交流群号665210056",
      "imageName": "ee8b84d1b3c4f8f51e26a6215190040c.png",
      "tag": 2,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 71,
      "followers": 920,
      "posts": 729,
      "name": "段子",
      "desc": "无论哪里来的有趣的段子，都可以分享出来，让大家欢乐一笑",
      "imageName": "biz/c52eb07731dbb00544ed6cababe7c479.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 1,
      "followers": 906,
      "posts": 33215,
      "name": "RSS技术文章",
      "desc": "我们炒饭的爬虫辛辛苦苦，踏遍中文互联网，给你找来的 RSS 文章。",
      "imageName": "670c39858799669cee8726499ed2f7b6.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 5,
      "followers": 879,
      "posts": 40325,
      "name": "游戏",
      "desc": "Just For Fun",
      "imageName": "f6b139f5280cffa5afd07727bbcbf135.png",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 22,
      "followers": 852,
      "posts": 1818,
      "name": "炒饭日常",
      "desc": null,
      "imageName": "biz/097b352092a352efdc585d5d012b8b3e.png",
      "tag": 1,
      "openChat": true,
      "joined": true,
      "admin": false
    },
    {
      "id": 6,
      "followers": 826,
      "posts": 39659,
      "name": "风景",
      "desc": "生活不止眼前的苟且，还有诗和远方的田野",
      "imageName": "biz/1d0dba41ae7a4c51988df0f054d57524.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 11,
      "followers": 763,
      "posts": 13946,
      "name": "老照片",
      "desc": "回溯时光",
      "imageName": "56112abefca9e1f0d4d682558425c23c.png",
      "tag": 9,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 8,
      "followers": 731,
      "posts": 37931,
      "name": "艺术",
      "desc": "我们都是一条鱼，在冰上行走，想找到属于自己的洞......",
      "imageName": "biz/eb6a4cad39299bd2ea7f02b14a705052.gif",
      "tag": 5,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 14,
      "followers": 725,
      "posts": 16533,
      "name": "极客",
      "desc": "“Stay hungry,Stay foolish”",
      "imageName": "df43bd95dad05ed213cdb891ec19b230.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 25,
      "followers": 716,
      "posts": 10451,
      "name": "摄影",
      "desc": null,
      "imageName": "biz/fcdbb176de4fca05b233d52051039ceb.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 53,
      "followers": 695,
      "posts": 2385,
      "name": "数码",
      "desc": "数码",
      "imageName": "biz/f79b28240ad64ce838e7e36356ae25af.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 70,
      "followers": 631,
      "posts": 306,
      "name": "沙雕表情",
      "desc": null,
      "imageName": "biz/86afaee4bf7990a095900f54131c7383.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 75,
      "followers": 618,
      "posts": 419,
      "name": "历史",
      "desc": "以史为鉴，可以知兴替",
      "imageName": "biz/629e11135224068ea85c52b77533f11b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 60,
      "followers": 590,
      "posts": 2025,
      "name": "照片",
      "desc": null,
      "imageName": "biz/3e0379aaf099840ceab4be5cd55d7a90.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 67,
      "followers": 582,
      "posts": 21,
      "name": "新鲜事",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 21,
      "followers": 580,
      "posts": 270,
      "name": "滑稽",
      "desc": "明日复明日，明月几时有？\n",
      "imageName": "biz/bf349a6275028347f0e7114a7512f860.jpg",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 16,
      "followers": 578,
      "posts": 398,
      "name": "炒饭发布",
      "desc": "发布公告的地方，正在慢慢利用!",
      "imageName": "biz/4fa7710fab1efd11b1d1cba66e062e59.jpg",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": true
    },
    {
      "id": 40,
      "followers": 571,
      "posts": 548,
      "name": "短句",
      "desc": "人生飘忽百年内，且须酣畅万古情。",
      "imageName": "biz/83d5ae9e06088643af00429c7a5f9c7c.png",
      "tag": 9,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 30,
      "followers": 560,
      "posts": 134,
      "name": "故事会",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 9,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 23,
      "followers": 555,
      "posts": 47479,
      "name": "旅行",
      "desc": "跨过山川，跨过海",
      "imageName": "biz/5779346414be007b053244e61e5d3be3.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 47,
      "followers": 551,
      "posts": 81,
      "name": "自拍",
      "desc": null,
      "imageName": "biz/e6ade467266dce272d65f3d653b4ad12.jpg",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 54,
      "followers": 533,
      "posts": 5979,
      "name": "随手拍",
      "desc": "随手拍",
      "imageName": "biz/cd4837625a723f1d35379adf7555c327.jpg",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 61,
      "followers": 533,
      "posts": 684,
      "name": "美食",
      "desc": "哈喽，各位吃货粉们，让我们印象深刻的特色美食回忆，全都保留在这美食版块小天地吧",
      "imageName": "biz/5e1cb437f532a55438f08fe10e5743c3.jpg",
      "tag": 12,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 9,
      "followers": 521,
      "posts": 32784,
      "name": "动物园",
      "desc": "融化你的心",
      "imageName": "b6691537d8d4901e583b4784683ac59d.png",
      "tag": 8,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 39,
      "followers": 498,
      "posts": 3310,
      "name": "车",
      "desc": null,
      "imageName": "biz/c6106e6db93e312bffed6e00247d0017.png",
      "tag": 11,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 32,
      "followers": 493,
      "posts": 130,
      "name": "问答",
      "desc": "问答的灵魂在于饭友之间共同交流探讨对问题的看法",
      "imageName": "biz/94d65c0b4bfa2f8a7f711634eb4b4d47.jpg",
      "tag": 4,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 78,
      "followers": 462,
      "posts": 63,
      "name": "设计",
      "desc": "分享与探索灵感⑧",
      "imageName": "biz/d394259ad2cd4e7618777a47f1f8afb1.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 15,
      "followers": 434,
      "posts": 2817,
      "name": "电影",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 4,
      "followers": 404,
      "posts": 30919,
      "name": "HackerNews中文",
      "desc": "",
      "imageName": "4afbd8e34e028dd79eb2f24429c70950.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 42,
      "followers": 354,
      "posts": 8559,
      "name": "涂鸦",
      "desc": "随时随地，随性随心",
      "imageName": "biz/c2981eaf49778f390ac27a7b20d53601.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 62,
      "followers": 330,
      "posts": 120,
      "name": "黑暗料理",
      "desc": "一起制毒吧～",
      "imageName": "biz/9a9cb0f4438a1d978db61241a73b0d9a.jpg",
      "tag": 12,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 18,
      "followers": 321,
      "posts": 95165,
      "name": "科技",
      "desc": null,
      "imageName": "biz/7cc90fb3f16b394f510dfd96ecce4df7.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 57,
      "followers": 270,
      "posts": 242,
      "name": "Cosplay",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 2,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 80,
      "followers": 231,
      "posts": 157,
      "name": "王者荣耀",
      "desc": "加入王者贴，和我们一起在王者峡谷中快乐玩耍",
      "imageName": "biz/e64766d436b9c8c468fe2eb2230ace60.jpg",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 24,
      "followers": 224,
      "posts": 58,
      "name": "互联网考古",
      "desc": null,
      "imageName": "biz/a12b6bbe80943d67fa18fa66dfc237df.png",
      "tag": 9,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 12,
      "followers": 205,
      "posts": 865,
      "name": "星尘大海",
      "desc": "我们的征途是星辰大海",
      "imageName": "393af52f118e59d9f2563398df8598b6.png",
      "tag": 11,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 58,
      "followers": 198,
      "posts": 389,
      "name": "音乐",
      "desc": "音乐起源与生活,生活因音乐而精彩\n",
      "imageName": "biz/e7a3889792bca11beafeee5d2d1532d4.jpeg",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 59,
      "followers": 165,
      "posts": 45,
      "name": "书",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 4,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 97,
      "followers": 165,
      "posts": 414,
      "name": "我的世界",
      "desc": "MINECRAFT & CHAOFUN",
      "imageName": "biz/2093893da449b4a572ffe785666f96b9.webp",
      "tag": 3,
      "openChat": true,
      "joined": true,
      "admin": false
    },
    {
      "id": 36,
      "followers": 164,
      "posts": 159,
      "name": "树洞",
      "desc": "有问题可留言版主，版主经常不在线",
      "imageName": "biz/fd43dfc2960516619d43d08377a23b5b.jpg",
      "tag": 9,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 20,
      "followers": 157,
      "posts": 4992,
      "name": "财经",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 4,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 49,
      "followers": 147,
      "posts": 217,
      "name": "小说",
      "desc": null,
      "imageName": "biz/98b62d49c1089ffb75e0a5236826f874.png",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 56,
      "followers": 132,
      "posts": 30,
      "name": "苹果",
      "desc": null,
      "imageName": "biz/0ebee64c5acda2df38bb797c19b96707.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 7,
      "followers": 125,
      "posts": 17804,
      "name": "体育",
      "desc": "更高更快更强",
      "imageName": "31e1bb256e5f4c816edf1ca60dd16691.png",
      "tag": 7,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 43,
      "followers": 122,
      "posts": 245,
      "name": "活在当下",
      "desc": "且行且珍惜",
      "imageName": "biz/53a9165f6c75c7eb7f5a30f88c0c48ab.jpg",
      "tag": 11,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 74,
      "followers": 118,
      "posts": 62,
      "name": "互联网",
      "desc": null,
      "imageName": "biz/e4bdcf7338b9b64519b8d8084ffdf474.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 55,
      "followers": 116,
      "posts": 284,
      "name": "军事",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 76,
      "followers": 109,
      "posts": 353,
      "name": "学习",
      "desc": "来了解点课本上没有的知识",
      "imageName": "biz/20e6042fe6081d1fd9de38a428a931a8.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 31,
      "followers": 99,
      "posts": 25,
      "name": "技术思考",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 6,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 77,
      "followers": 95,
      "posts": 17,
      "name": "哲学",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 86,
      "followers": 73,
      "posts": 182,
      "name": "壁纸",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 10,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 82,
      "followers": 66,
      "posts": 964,
      "name": "交通事故",
      "desc": "【减少事故，预防为主】本版块收录各种交通事故、突发意外及灾难现场，时刻警醒我们在工作和生活中要珍爱生命，平安出行",
      "imageName": "biz/812916254a18327bf15ff4807a841544.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 83,
      "followers": 58,
      "posts": 4992,
      "name": "摸鱼视频",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 89,
      "followers": 40,
      "posts": 5,
      "name": "每日一笑",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 91,
      "followers": 40,
      "posts": 150,
      "name": "NSFW",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 81,
      "followers": 32,
      "posts": 234,
      "name": "英雄联盟",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 93,
      "followers": 32,
      "posts": 88,
      "name": "原神",
      "desc": "我们终将相遇",
      "imageName": "biz/71ef41dcb9eeeb4ce6ef27c5014d3f5d.jpg",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 79,
      "followers": 30,
      "posts": 41,
      "name": "赛博朋克",
      "desc": null,
      "imageName": "biz/c1318855d222f88efd8d8a1930dc3c97.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 87,
      "followers": 28,
      "posts": 19,
      "name": "头像",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 64,
      "followers": 26,
      "posts": 48,
      "name": "求嘲",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 1,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 90,
      "followers": 25,
      "posts": 26,
      "name": "普通的生活",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 88,
      "followers": 20,
      "posts": 1,
      "name": "手势舞",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 85,
      "followers": 16,
      "posts": 61,
      "name": "帅哥",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 100,
      "followers": 15,
      "posts": 25,
      "name": "乐高",
      "desc": "分享乐高资讯和大神们的作品~",
      "imageName": "biz/34fc93c6d806add39d8ee37f9891c347.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 99,
      "followers": 14,
      "posts": 23,
      "name": "职言",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 92,
      "followers": 13,
      "posts": 2,
      "name": "光遇",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 102,
      "followers": 13,
      "posts": 69,
      "name": "书法",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 5,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 95,
      "followers": 12,
      "posts": 22,
      "name": "进击的巨人",
      "desc": "自由吧！！！",
      "imageName": "biz/3ea12b91f1b5aff348d6afdca1def3c2.jpg",
      "tag": 2,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 96,
      "followers": 11,
      "posts": 3,
      "name": "元气骑士",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 2,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 112,
      "followers": 11,
      "posts": 5,
      "name": "贴吧",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 94,
      "followers": 10,
      "posts": 3,
      "name": "畅玩空间怀旧游戏",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 105,
      "followers": 10,
      "posts": 139,
      "name": "装饰",
      "desc": "斯是陋室，惟吾德馨！",
      "imageName": "biz/bcab9cc27de897d13716054d8812007f.gif",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 107,
      "followers": 9,
      "posts": 12,
      "name": "名侦探柯南",
      "desc": "真相永远只有一个！",
      "imageName": "biz/c27cd074776335d3c5c02addf41cf02b.jpg",
      "tag": null,
      "openChat": true,
      "joined": true,
      "admin": false
    },
    {
      "id": 114,
      "followers": 9,
      "posts": 101,
      "name": "化妆",
      "desc": "各位客官，快来看看吧！走过路过不要错过，看不了吃亏看不了上当！",
      "imageName": "biz/7ab4059ef151d2c5e34c9b1efb2d304c.jpg",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 98,
      "followers": 8,
      "posts": 37,
      "name": "钓鱼",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 101,
      "followers": 8,
      "posts": 2,
      "name": "魔兽争霸3",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 103,
      "followers": 8,
      "posts": 21,
      "name": "恋爱",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 111,
      "followers": 8,
      "posts": 2,
      "name": "英语",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 109,
      "followers": 6,
      "posts": 2,
      "name": "泰拉瑞亚",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 113,
      "followers": 4,
      "posts": 3,
      "name": "CSGO",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 104,
      "followers": 3,
      "posts": 13,
      "name": "明日方舟",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 106,
      "followers": 3,
      "posts": 2,
      "name": "魔兽世界怀旧服",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": 3,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 110,
      "followers": 3,
      "posts": 1,
      "name": "刺客信条",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 108,
      "followers": 1,
      "posts": 1,
      "name": "传说之下",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": true,
      "admin": false
    },
    {
      "id": 115,
      "followers": 1,
      "posts": 1,
      "name": "密码",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": false,
      "admin": false
    },
    {
      "id": 116,
      "followers": 0,
      "posts": 0,
      "name": "考研",
      "desc": null,
      "imageName": "79f9ffc02d3d7b8fac52208fba3ee07b.png",
      "tag": null,
      "openChat": false,
      "joined": false,
      "admin": false
    }
  ];

  List choosedForums = [2, 3, 84];

  _checkForumIsChoose(id) {
    return choosedForums.contains(id);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: ScreenUtil().setWidth(1000),
      // color: Colors.grey,

      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(234, 234, 234, 1),
            border: Border.all(
              width: 1,
              color: Color.fromRGBO(234, 234, 234, 1),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          width: ScreenUtil().setWidth(690),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
          padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
          height: widget.height != null
              ? widget.height
              : ScreenUtil().setWidth(900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/_icon/hot.png',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      '推荐版块',
                      style: TextStyle(fontSize: ScreenUtil().setSp(34)),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 5, bottom: 14),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: () {
                          var id = forums[index]['id'];
                          if (_checkForumIsChoose(id)) {
                            setState(() {
                              choosedForums.remove(id);
                            });
                          } else {
                            setState(() {
                              choosedForums.add(id);
                            });
                          }
                        },
                        child: Container(
                          height: 80,
                          child: Stack(
                            children: [
                              Image.network(
                                KSet.imgOrigin +
                                    forums[index]['imageName'] +
                                    '?x-oss-process=image/resize,h_120/format,webp/quality,q_75',
                                // width: ScreenUtil().setWidth(80),
                                // height: ScreenUtil().setWidth(80),
                                // fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  width: ScreenUtil().setWidth(120),
                                  height: ScreenUtil().setWidth(30),
                                  alignment: Alignment.center,
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                  child: Text(
                                    forums[index]['name'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(24)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: Colors.white,
                                    height: 16,
                                    width: 16,
                                    child:
                                        _checkForumIsChoose(forums[index]['id'])
                                            ? Image.asset(
                                                'assets/images/_icon/choosed.png',
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                height: 0,
                                              ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          color: Colors
                              .primaries[(index) % Colors.primaries.length],
                        ),
                      ),
                    );
                  },
                  itemCount: forums.length,
                ),
              ),
              Divider(
                height: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: () async {
                    // Navigator.pushNamed(context, '/addForumPage');
                    print('加入版块1');
                    print(choosedForums);
                    for (var i = 0; i < choosedForums.length; i++) {
                      print(choosedForums[i]);
                      await HttpUtil().get(Api.joinForum,
                          parameters: {'forumId': choosedForums[i]});
                    }
                    widget.callBack();
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(690),
                    height: ScreenUtil().setWidth(80),
                    color: Color.fromRGBO(255, 147, 0, 1),
                    alignment: Alignment.center,
                    child: Text(
                      '开启炒饭之旅',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Expanded(
              //   child: GridView(
              //     physics: NeverScrollableScrollPhysics(),
              //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 5,
              //       crossAxisSpacing: 4,
              //       mainAxisSpacing: 4,
              //     ),
              //     children: _doForumList(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
