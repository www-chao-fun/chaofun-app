



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/user/FroumListNormalView.dart';
import 'package:flutter_chaofan/pages/user/simple_user_list_view.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManagerForumsPage extends StatefulWidget {

  ManagerForumsPage({Key key});

  @override
  _ManagerForumsPage createState() => _ManagerForumsPage();
}


class _ManagerForumsPage extends State<ManagerForumsPage> {

  var forumData = [];

  var marker = null;
  var pageSize = 40;

  var userId = null;
  EasyRefreshController _controller = EasyRefreshController();

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getData();
  }

  Future<void> getData() async {
    var response = await HttpUtil.instance
          .get(Api.listManageForums);
    //
    // print(response);
    // print('1234');
    if (response != null && response['data'] != null) {
      setState(() {
          forumData = response['data'];
      });
    }
  }

  Future<void> _onRefresh() async {
    marker = null;
    getData();
    _controller.finishRefresh();
  }

  Future<void> _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      getData();
    }
    _controller.finishLoad();
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
                color: KColor.defaultGrayColor,
                size: 20,
              ),
            ),
          ),
          brightness: Brightness.light,
          title: Text(
            '我管理的版块',
            style:
            TextStyle(color: Colors.black, fontSize: ScreenUtil().setSp(38)),
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 0),
          child: EasyRefresh.custom(
            enableControlFinishRefresh: false,
            enableControlFinishLoad: false,
            controller: _controller,
            scrollController: _scrollController,
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
              // Container(
              //   height: 40,
              //   color: Colors.blue,
              // ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, int index) {
                        // return Container();
                    return ForumListNormalView(forumInfo: forumData[index]);
                  },
                  childCount: forumData.length,
                ),
              ),
            ],
          ),
        )
    );
  }


}