import 'package:fluro/fluro.dart';
import 'package:flutter_chaofan/AppState.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/widget/common/customNavgator.dart';
import './routers/router.dart';
// import './config/application.dart';

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import './config/index.dart';
import './provide/current_index_provide.dart';
import './pages/index_page.dart';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:provider/single_child_widget.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme.dart';

void main() {
  List<SingleChildStatelessWidget> providers = [
    ChangeNotifierProvider<CurrentIndexProvide>(
      create: (_) => CurrentIndexProvide(),
    ),
    ChangeNotifierProvider<UserStateProvide>(
      create: (_) => UserStateProvide(),
    )
  ];


  runApp(
    AppStateContainer(child:   MultiProvider(
      providers: providers,
      child: MyApp(),
    ))
  ,
  );
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ); //Colors.black38
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  } else {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ); //Colors.black38
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

final RouteObserver<Route<dynamic>> routeObserver = RouteObserver();

List<Locale> an = [
  const Locale('zh', 'CH'),
  const Locale('en', 'US'),
];
List<Locale> ios = [
  const Locale('en', 'US'),
  const Locale('zh', 'CH'),
];

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  MyApp() {
    //初始化路由
    // final router = new Router();
    // Routers.configureRoutes(router);
    // Application.router = router;
  }
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    return ScreenUtilInit(
      designSize: Size(750, 1334),
      allowFontScaling: false,
      builder: () {
        return MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations
                .delegate, //一定要配置,否则iphone手机长按编辑框有白屏卡着的bug出现
          ],
          supportedLocales: [
            Locale('zh', 'CN'), //设置语言为中文
          ],
          navigatorObservers: [routeObserver],
          title: KString.mainTitle,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: onGenerateRoute,
          // 主题
          theme: AppStateContainer.of(context).theme,
          darkTheme: darkThemeData(),
          home: IndexPage(),
        );
      },
    );
  }
}
