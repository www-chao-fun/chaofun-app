import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/store/index.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/widget/items/top_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class FocusedPage extends StatefulWidget {
  _FocusedPageState createState() => _FocusedPageState();
}

class _FocusedPageState extends State<FocusedPage> {
  var item;
  var memberInfoFuture;
  HomeService homeService = HomeService();
  var params = {'marker': '', 'pageSize': 40};
  ScrollController _scrollController = ScrollController();
  bool canload = true;

  List<Map> pageData = [];
  bool hasMore = true;
  @override
  void initState() {
    // TODO: implement initState

    memberInfoFuture = homeService.listTrends(params, (response) {
      List<Map> res = (response['trends'] as List).cast();
      params['marker'] = response['marker'];
      pageData.addAll(res);
      print('获取listTrends');
      print(response);
    }, (message) {
      print('失败了');
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('加载更多');
        _onLoading();
      }
    });
    super.initState();
  }

  _onLoading() async {
    print('kiiii');
    // monitor network fetch
    print('88888888888888888888888888888888888888');
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
    if (canload) {
      setState(() {
        canload = false;
      });
      getDatas('');
    }
  }

  void getDatas(type) async {
    // params['marker'] = '';
    if (type == 'refresh') {
      params['marker'] = '';
    }
    var data = await HttpUtil().get(Api.listTrends, parameters: params);
    // response = response['data'];
    print('获取listTrends2233');
    print(data);
    if (type == 'refresh') {
      pageData = [];
    }
    List<Map> res = (data['data']['trends'] as List).cast();
    setState(() {
      // print('pagedata的数据长度是: ${pageData.length}');
      pageData.addAll(res);
      canload = true;
      if (data['data']['marker'] != null) {
        params['marker'] = data['data']['marker'];
      }

      if (res.length < 20) {
        hasMore = false;
      }
    });
  }

  Widget _loadMoreWidget() {
    if (hasMore) {
      return new Padding(
        padding: const EdgeInsets.all(30.0),
        child: new Center(child: new CupertinoActivityIndicator()),
      );
    } else if (pageData.length > 2) {
      return new Padding(
        padding: const EdgeInsets.all(30.0),
        child: new Center(
            child: Text(
          '没有更多数据了-',
          style: TextStyle(color: Colors.grey),
        )),
      );
    } else {
      return new Padding(
        padding: const EdgeInsets.all(50.0),
        child: new Center(
          child: Container(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/_icon/nocontent.png',
                  width: ScreenUtil().setWidth(300),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('暂无更多数据~')
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<UserStateProvide>(context, listen: true).changeTag !=
        null) {
      var ps = Provider.of<UserStateProvide>(context, listen: false).changeTag;
      pageData.forEach((element) {
        if (ps['postId'] == element['postId']) {
          element['tags'] = [ps['tags']];
          print('ccccccccccccccc');
          print(element);
        }
      });
    }
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: PreferredSize(
        child: AppBar(
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
            '关注',
            style: TextStyle(
                color: Colors.black, fontSize: ScreenUtil().setSp(34)),
          ),
          backgroundColor: Colors.white,
        ),
        preferredSize: Size.fromHeight(40),
      ),
      body: FutureBuilder(
          //防止刷新重绘
          future: memberInfoFuture,
          builder: (context, AsyncSnapshot asyncSnapshot) {
            switch (asyncSnapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(254, 149, 0, 100)),
                  ),
                );
              default:
                print('77777');
                print(asyncSnapshot.connectionState);
                print(asyncSnapshot.hasError);
                if (asyncSnapshot.hasError) {
                  return new Text('error');
                } else {
                  return Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(top: 0),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        CupertinoSliverRefreshControl(
                          //CupertinoSliverRefreshControl
                          onRefresh: () async {
                            print('刷新了');
                            // await Future.delayed(Duration(milliseconds: 1000));
                            getDatas('refresh');
                            await Future.delayed(Duration(seconds: 1), () {});
                            //结束刷新
                            return Future.value(true);
                          },
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (content, index) {
                              if (index == (pageData.length - 1)) {
                                return _loadMoreWidget();
                              } else {
                                return Container(
                                  padding: EdgeInsets.all(0),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(20),
                                          right: ScreenUtil().setWidth(20),
                                        ),
                                        child: ItemsTop(
                                          item: pageData[index]['postInfo'],
                                          type: 'trends',
                                          pageSource: 'trends',
                                          source: pageData[index],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(20),
                                          right: ScreenUtil().setWidth(20),
                                          bottom: ScreenUtil().setWidth(20),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/postdetail',
                                              arguments: {
                                                "postId": pageData[index]
                                                        ['postInfo']['postId']
                                                    .toString()
                                              },
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: ScreenUtil()
                                                      .setWidth(156),
                                                  color: Color.fromRGBO(
                                                      245, 245, 245, 1),
                                                  // padding: EdgeInsets.all(
                                                  //     ScreenUtil().setWidth(20)),
                                                  child:
                                                      _doCons(pageData[index]),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: _postType(
                                                      pageData[index]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: ScreenUtil().setWidth(14),
                                        color: Color.fromRGBO(240, 240, 240, 1),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            childCount: pageData.length,
                          ),
                        )
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  Widget _postType(item) {
    switch (item['postInfo']['type']) {
      case 'image':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.image_outlined,
            color: Colors.white,
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.play_circle_outline_outlined, color: Colors.white),
        );
        break;
      case 'link':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.link_rounded, color: Colors.white),
        );
        break;
      case 'vote':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.assessment,
            color: Colors.white,
            // size: 20,
          ),
        );
        break;
      case 'article':
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(
            Icons.article,
            color: Colors.white,
            // size: 20,
          ),
        );
        break;
      default:
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          child: Icon(Icons.language, color: Colors.white),
        );
    }
  }

  Widget _doCons(item) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(10)),
            constraints: BoxConstraints(
              minHeight: ScreenUtil().setWidth(80),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              item['postInfo']['title'],
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: ScreenUtil().setSp(30)),
            ),
          ),
        ),
        _getImageUrl(item),
      ],
    );
  }

  _getImageUrl(item) {
    switch (item['postInfo']['type']) {
      case 'image':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: CachedNetworkImage(
            imageUrl: KSet.imgOrigin +
                item['postInfo']['imageName'] +
                '?x-oss-process=image/resize,w_450/format,webp/quality,q_75',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
        break;
      case 'inner_video':
      case 'gif':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: CachedNetworkImage(
            imageUrl: (KSet.imgOrigin +
                    (item['postInfo']['type'] == 'inner_video'
                        ? item['postInfo']['video']
                        : item['postInfo']['imageName'])) +
                '?x-oss-process=video/snapshot,t_100000,m_fast,ar_auto,w_128',
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
        break;
      case 'link':
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: item['postInfo']['cover'] != null
              ? CachedNetworkImage(
                  imageUrl: (KSet.imgOrigin +
                      item['postInfo']['cover'] +
                      '?x-oss-process=image/resize,w_450/format,webp/quality,q_75'),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : Image.asset('assets/images/_icon/link.png'),
        );
        break;
      case 'article':
        return Container(
          width: 0,
        );
        break;
      default:
        return Container(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(150),
            minHeight: ScreenUtil().setWidth(120),
          ),
          width: ScreenUtil().setWidth(180),
          child: Text('不支持的类型'),
        );
    }
  }

  Widget _default() {
    return Container(
      height: ScreenUtil().setWidth(150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
        width: 0.5,
        color: Color.fromRGBO(235, 235, 235, 1),
      )),
      child: Text(
        '当前版本不支持的类型，请尝试升级版本查看',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
