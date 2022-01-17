import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter_chaofan/utils/shared_preferences_util.dart';
import 'package:package_info/package_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

var dio;
var pref;
String version = '2.34.0';
void inits() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
}

class HttpUtil {
  // 工厂模式
  static HttpUtil get instance => _getInstance();

  static HttpUtil _httpUtil;
  var v;

  static HttpUtil _getInstance() {
    if (_httpUtil == null) {
      _httpUtil = HttpUtil();
    }
    return _httpUtil;
  }

// Platform
  HttpUtil() {
    print('-----------------------8');
    print(version);
    BaseOptions options = BaseOptions(
      connectTimeout: 10000,
      receiveTimeout: 10000,
      headers: {
        'fun-device': Platform.isAndroid ? 'app-android' : 'app-ios',
        'fun-app-version': version
      },
    );
    dio = new Dio(options);

    // 抓包工具
//    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) {
//        return "PROXY 192.168.1.6:8888";
//      };
//    };

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var tCookie = prefs.getString("cookie");
      if (tCookie != null) {
        options.headers.addAll({
          "cookie": "$tCookie"
        }); //此处在请求前配置了存储在SharedPreferences里面的token，没需要可以不加
      }

      print('---------------------');
      print("========================请求数据1===================");
      dio.lock();
      // await SharedPreferencesUtils.getToken().then((token) {
      //   // options.headers[Strings.TOKEN] = token;
      // });
      dio.unlock();
      return options;
    }, onResponse: (Response response) async {
      print("========================接收数据2===================");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var tCookie = prefs.getString("cookie");

      if (response.headers['set-cookie'] != null) {
        print(response.headers['set-cookie']);
        print(response.headers['set-cookie'][0]);
        print(response.headers.toString());
        print('响应头');
        var target = '';

        var fun_ticket = '';
        var session = '';

        // 提取历史
        if (tCookie != null && tCookie != '') {
          var tCookieList = tCookie.split(';');
          for (var value in tCookieList) {
            if (value.contains('fun_ticket=')) {
              fun_ticket = value;
            }

            if (value.contains('SESSION=')) {
              session = value;
            }
          }
        }

        // 替换历史
        for (var i = 0; i < response.headers['set-cookie'].length; i++) {
          if (response.headers['set-cookie'][i].contains('fun_ticket=')) {
            fun_ticket = response.headers['set-cookie'][i].split(';')[0];
          }
          if (response.headers['set-cookie'][i].contains('SESSION=')) {
            session = response.headers['set-cookie'][i].split(';')[0];
          }
        }

        if (fun_ticket != '') {
          target += fun_ticket + ';';
        }

        if (session != '') {
          target += session + ';';
        }

        prefs.setString('cookie', target);
      }
    }, onError: (DioError error) {
      print("========================请求错误3===================");
      // print("message =${error.message}");
    }));
  }

  Future get(String url,
      {Map<String, dynamic> parameters, Options options}) async {
    Response response;
    if (parameters != null && options != null) {
      response =
          await dio.get(url, queryParameters: parameters, options: options);
    } else if (parameters != null && options == null) {
      response = await dio.get(url, queryParameters: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.get(url, options: options);
    } else {
      response = await dio.get(url);
    }
    try {
      return response.data;
    } catch (e) {
      return response;
    }
  }

  Future post(String url,
      {Map<String, dynamic> parameters,
      Options options,
      queryParameters}) async {
    Response response;
    if (parameters != null && options != null) {
      var formdata;
      // if(){

      // }
      // FormData formdata = FormData.fromMap({
      //   'forumId': 6,
      //   'title': '111',
      //   'articleType': 'richtext',
      //   'article': '222'
      // });
      response =
          await dio.post(url, data: parameters['data'], options: options);
    } else if (parameters != null && options == null) {
      response = await dio.post(url, data: parameters);
    } else if (parameters == null && options != null) {
      response = await dio.post(url, options: options);
    } else {
      response = await dio.post(url, queryParameters: queryParameters);
    }
    return response.data;
  }
}
