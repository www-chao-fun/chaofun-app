import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/index.dart';

Future request(url, {formData}) async {
  try {
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = 'application/x-www-form-urlencoded';
    dio.options.headers['x-csrf-token'] = "s2515454514521";
    // dio.options.contentType =
    //     ContentType.parse('application/x-www-form-urlencoded');
    if (formData == null) {
      response = await dio.post(servicePath[url]);
    } else {
      response = await dio.post(servicePath[url], data: formData);
    }
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('接口异常');
    }
  } catch (e) {
    return print('error:::${e}');
  }
}
