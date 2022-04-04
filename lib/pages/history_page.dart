import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/items/index_widget.dart';


class HistoryPage extends StatefulWidget {
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {


  var params = {
    "pageNum": 1,
    "pageSize": '20',
    "marker": '',
  };
  List<Map> pageData = [];
  EasyRefreshController _controller;
  var dataFuture;
  HomeService homeService = HomeService();

  @override
  void initState() {
    params['pageNum'] = 1;
    // TODO: implement initState
    super.initState();
    dataFuture = homeService.myHistory(params, (response) {
      var data = response;
      List<Map> asd = (data as List).cast();
      // List<Map> arr = [];
      // if (asd.length > 0) {
      //   asd.forEach((v) {
      //     if (v['type'] == 'image' ||
      //         (v['type'] == 'link') ||
      //         v['type'] == 'article') {
      //       arr.addAll([v]);
      //     }
      //   });
      // }
      // setState(() {
      setState(() {
        pageData.addAll(asd);
        print('HOME pagedata的数据长度是: ${pageData.length}');
        if ( asd != null && asd.length != 0) {
          params['pageNum'] =  int.parse(params['pageNum'].toString())+ 1;
        }
      });
    }, (message) {
      print('失败了');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        elevation: 0,
        leading: Container(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        brightness: Brightness.light,
        title: Text(
          '历史记录',
          style:
          TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(34)),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        //防止刷新重绘
          future: dataFuture,
          builder: (context, AsyncSnapshot asyncSnapshot) {
            return SafeArea(
              child: Stack(children: <Widget>[
                EasyRefresh.custom(
                  enableControlFinishRefresh: false,
                  enableControlFinishLoad: false,
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
                          return ItemIndex(
                              item: pageData[index], type: 'forum');
                        },
                        childCount: pageData.length,
                      ),
                    ),
                  ],
                ),
              ]),
            );
          }),
    );
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    homeService.myHistory(params, (response) {
      var data = response;
      List<Map> asd = (data as List).cast();
      // List<Map> ar{
      setState(() {
        asd.forEach((element) {
          if (!pageData.contains(element)) {
            pageData.add(element);
          }
        });
        print('HOME pagedata的数据长度是: ${pageData.length}');
        if ( asd != null && asd.length != 0) {
          params['pageNum'] =  int.parse(params['pageNum'].toString())+ 1;
        }
      });
    }, (message) {
      print('失败了');
    });
  }

  Future<void> _onRefresh() async {
    params['pageNum'] = 1;
    homeService.myHistory(params, (response) {
      var data = response;
      List<Map> asd = (data as List).cast();
      // List<Map> ar{
      setState(() {
        pageData = [];
        pageData.addAll(asd);
        print('HOME pagedata的数据长度是: ${pageData.length}');
        if (data['marker'] != null) {
          params["marker"] = data['marker'];
        }
      });
    }, (message) {
      print('失败了');
    });
  }



}