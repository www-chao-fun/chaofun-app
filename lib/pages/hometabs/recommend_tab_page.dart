import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/common/loading_widget.dart';

import 'package:flutter_chaofan/widget/items/index_widget.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
// 图片缓存
import 'package:cached_network_image/cached_network_image.dart';
// 刷新组件

import 'package:provider/provider.dart';
import 'package:flutter_chaofan/provide/user.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';

class PageRecommendTab extends StatefulWidget {
  List<Map> pageData;
  _PageRecommendTabState createState() => _PageRecommendTabState();
}

class _PageRecommendTabState extends State<PageRecommendTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  EasyRefreshController _controller;

  HomeService homeService = HomeService();

  var btnToTop = false;
  bool isLoading = true;

  List<Map> pageData = [
    {'name': 'sort'}
  ];
  var params = {
    "pageSize": '30',
    "marker": '',
    "order": 'new',
    'forumId': 'recommend'
  };
  bool canload = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  delays() async {
    print('延迟');
    await Future.delayed(Duration(milliseconds: 1000));
    print('加载');
    setState(() {
      isLoading = false;
    });
  }

  void getDatas(type) async {
    var data = await HttpUtil().get(Api.HomeListCombine, parameters: params);
    // response = response['data'];
    if (type == 'refresh') {
      pageData = [
        {'name': 'sort'}
      ];
    }
    List<Map> res = (data['data']['posts'] as List).cast();
    // pageData.addAll(res);
    List<Map> arr = [];
    if (res.length > 0) {
      res.forEach((v) {
        if (v['type'] == 'image' ||
            v['type'] == 'link' ||
            v['type'] == 'article' ||
            v['type'] == 'gif' ||
            v['type'] == 'video') {
          arr.addAll([v]);
        }
      });
    }

    setState(() {
      // print('recommend pagedata的数据长度是: ${pageData.length}');
      // pageData.addAll(arr);
      if (pageData.length < 1000) {
        pageData.addAll(arr);
      } else {
        pageData = arr;
      }
      params["marker"] = data['data']['marker'];
      params['key'] = data['data']['key'];
      isLoading = false;
      canload = true;
    });
  }

  void refreshData() async {
    setState(() {
      // if (tabs == 'home') {
      params['marker'] = '';
      params['key'] = '';
      if (btnToTop) {
        pageData = [
          {'name': 'sort'}
        ];
        btnToTop = false;
      }
      Provider.of<UserStateProvide>(context).setDisabledPostList();
      Provider.of<UserStateProvide>(context).setDisabledUserList();
      getDatas('refresh');
    });
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    refreshData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        canload = false;
      });
      getDatas('');
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? LoadingWidget()
          : Container(
              margin: EdgeInsets.only(top: 90),
              child: EasyRefresh.custom(
                enableControlFinishRefresh: false,
                enableControlFinishLoad: true,
                controller: _controller,
                header: ClassicalHeader(),
                footer: ClassicalFooter(),
                onRefresh: _onRefresh,
                onLoad: _onLoading,
                slivers: <Widget>[
                  ListView.builder(
                    primary: true,
                    cacheExtent: 1000,
                    itemBuilder: (c, i) => ItemIndex(
                      item: pageData[i],
                      type: 'forum',
                    ),
                    // itemExtent: 100.0,
                    itemCount: pageData.length,
                  ),
                ],
              ),
            ),
    );
  }
}
