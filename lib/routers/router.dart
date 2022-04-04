import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/collect/collect_add_page.dart';
import 'package:flutter_chaofan/pages/collect/collect_detail_page.dart';
import 'package:flutter_chaofan/pages/collect/collect_list_page.dart';
import 'package:flutter_chaofan/pages/discover.dart';
import 'package:flutter_chaofan/pages/focus_page.dart';
import 'package:flutter_chaofan/pages/forum/all_page.dart';
import 'package:flutter_chaofan/pages/forum/focused_page.dart';
import 'package:flutter_chaofan/pages/forum/forum_page.dart';
import 'package:flutter_chaofan/pages/forum/prediction_page.dart';
import 'package:flutter_chaofan/pages/forum/recommend_page.dart';
import 'package:flutter_chaofan/pages/forum/test_page.dart';
import 'package:flutter_chaofan/pages/forum_followers_page.dart';
import 'package:flutter_chaofan/pages/history_page.dart';
import 'package:flutter_chaofan/pages/login/accoutLogin.dart';
import 'package:flutter_chaofan/pages/login/register.dart';
import 'package:flutter_chaofan/pages/message_page.dart';

import 'package:flutter_chaofan/pages/post_detail/post_detail_page.dart';
import 'package:flutter_chaofan/pages/publish/article_publish_page.dart';
import 'package:flutter_chaofan/pages/publish/forumList.dart';
import 'package:flutter_chaofan/pages/publish/link_publish_page.dart';
import 'package:flutter_chaofan/pages/publish/image_publish_page.dart';
import 'package:flutter_chaofan/pages/publish/submit.dart';
import 'package:flutter_chaofan/pages/publish/vote_publish_page.dart';
import 'package:flutter_chaofan/pages/search/search_page.dart';
import 'package:flutter_chaofan/pages/search/search_result_page.dart';
import 'package:flutter_chaofan/pages/set/contact_page.dart';
import 'package:flutter_chaofan/pages/set/push_set_page.dart';
import 'package:flutter_chaofan/pages/set/set_theme_page.dart';
import 'package:flutter_chaofan/pages/tools/drop_water_page.dart';
import 'package:flutter_chaofan/pages/tools/parse_url_page.dart';
import 'package:flutter_chaofan/pages/tools/tools_page.dart';
import 'package:flutter_chaofan/pages/user/app_version_page.dart';
import 'package:flutter_chaofan/pages/user/at_user_list.dart';
import 'package:flutter_chaofan/pages/user/bind_phone_page.dart';
import 'package:flutter_chaofan/pages/set/set_page.dart';
import 'package:flutter_chaofan/pages/user/set_info_page.dart';
import 'package:flutter_chaofan/pages/user/user_member_page.dart';
import 'package:flutter_chaofan/pages/user/user_post_page.dart';
import 'package:flutter_chaofan/pages/user/user_save_page.dart';
import 'package:flutter_chaofan/pages/user/user_ups_page.dart';
import 'package:flutter_chaofan/pages/login/addForum_page.dart';

// 图片视频选择
// import '../pages/test/photoView/picker_image_page.dart';
// 视频播放
// import '../pages/test/videoplay/video_page.dart';
// 我的订单
import '../pages/order/order_page.dart';
import '../pages/home_page.dart';

import '../pages/test/test.dart';
import '../pages/test/photoView/preview_page.dart';
import '../pages/login/login.dart';

//配置路由
final routes = {
  '/': (context, {arguments}) => HomePage(arguments: arguments),
  '/discoverPage': (context, {arguments}) => DiscoverPage(),
  '/home': (context, {arguments}) => HomePage(arguments: arguments),
  '/message': (context, {arguments}) => MessagePage(),
  // '/test': (context) => TestPage(),
  '/preview': (context) => PreviewPage(),
  // '/photoapp': (context) => PhotoApp(),
  // '/videopage': (context, {arguments}) => ListPage(),
  '/orderpage': (context, {arguments}) => OrderPage(orderState: arguments),
  // '/goodDetailPage': (context, {arguments}) =>
  //     GoodsDetailPage(arguments: arguments),
  '/postdetail': (context, {arguments}) => PostDetailPage(arguments: arguments),
  '/focus_user': (context, {arguments}) => FocusPage(arguments: arguments),
  '/followers_user': (context, {arguments}) => ForumFollowersPage(arguments: arguments),
  '/login': (context) => LoginPage(), //选择登录
  '/accoutlogin': (context, {arguments}) =>
      AccoutLoginPage(arguments: arguments), //账号密码登录
  '/register': (context, {arguments}) => RegisterPage(), //注册
  '/linkpublish': (context, {arguments}) =>
      LinkPublishPage(arguments: arguments), //发布链接
  '/imagepublish': (context, {arguments}) =>
      ImagePublishPage(arguments: arguments), //发布图片
  '/articlepublish': (context, {arguments}) =>
      ArticlePublishPage(arguments: arguments), //发布文章
  '/votepublish': (context, {arguments}) =>
      VotePublishPage(arguments: arguments),
  '/forumlist': (context) => ForumListPage(),
  '/forumpage': (context, {arguments}) => ForumPage(arguments: arguments),
  '/userpostpage': (context, {arguments}) => UserPostPage(arguments: arguments),
  '/userupspage': (context, {arguments}) => UserUpsPage(arguments: arguments),
  '/usersavepage': (context, {arguments}) => UserSavePage(arguments: arguments),
  '/appversion': (context, {arguments}) => AppVersionPage(),
  '/search': (context, {arguments}) => SearchPage(arguments: arguments),
  '/allpage': (context, {arguments}) => AllPage(),
  // '/allpage': (context, {arguments}) => CustomSliverHeaderDemo(),
  '/recommendpage': (context, {arguments}) => RecommendPage(),
  '/focusedpage': (context, {arguments}) => FocusedPage(),
  '/userMemberPage': (context, {arguments}) =>
      UserMemberPage(arguments: arguments),
  '/contact': (context, {arguments}) => ContactPage(), // 联系我们
  '/searchResultPage': (context, {arguments}) =>
      SearchResultPage(arguments: arguments), // 联系我们
  '/addForumPage': (context, {arguments}) => AddForumPage(), // 联系我们
  '/toolsPage': (context, {arguments}) => ToolsPage(),
  '/dropWaterPage': (context, {arguments}) =>
      DropWaterPage(arguments: arguments),
  '/parseUrlPage': (context, {arguments}) => ParseUrlPage(),
  '/setpage': (context, {arguments}) => SetPage(),
  '/history': (context)=> HistoryPage(),
  '/setThemePage': (context, {arguments}) => SetThemePage(),
  '/bindphonepage': (context, {arguments}) => BindPhonePage(),
  '/pushSet': (context, {arguments}) => PushSetPage(),
  '/collectlist': (context, {arguments}) =>
      CollectListPage(arguments: arguments),
  '/collectdetail': (context, {arguments}) =>
      CollectDetailPage(arguments: arguments),
  '/collectadd': (context, {arguments}) => CollectAddPage(),
  '/predictionpage': (context, {arguments}) =>
      PredictionPage(arguments: arguments),
  '/submitpage': (context, {arguments}) => SubmitPage(arguments: arguments),
  '/setinfopage': (context, {arguments}) => SetInfoPage(),
  // '/atuserpage': (context, {arguments}) => AtUserListPage(),
  // '/imagescrollview': (context, {arguments}) =>
  //     JhPhotoAllScreenShow(arguments: arguments),
};

//固定写法
var onGenerateRoute = (RouteSettings settings) {
// 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
