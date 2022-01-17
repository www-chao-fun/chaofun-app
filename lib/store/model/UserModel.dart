import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../object/UserInfo.dart';

import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chaofan/api/api.dart';

export '../object/UserInfo.dart';

var sd;
// countName() async {
//   var response = await HttpUtil().get(Api.getUserInfo);
//   if (response['data'] != null) {
//     sd = '炒饭超Fun';
//   }
// }

hhh() {
  HttpUtil().get(Api.getUserInfo).then((res) {
    sd = '123123';
  });
}

class UserModel extends UserInfo with ChangeNotifier {
  var _userInfo = UserInfo(
      isLogin: false,
      userName: '1119',
      icon: '123123',
      desc: '0000000',
      ups: 100,
      userId: 2);

  bool get isLogin => _userInfo.isLogin;
  String get userName => _userInfo.userName;
  String get icon => _userInfo.icon;
  String get desc => _userInfo.desc;
  int get ups => _userInfo.ups;
  int get userId => _userInfo.userId;

  void setIsLogin(isLogin) {
    _userInfo.isLogin = isLogin;
    notifyListeners();
  }

  void setUserName(userName) {
    _userInfo.userName = userName;
    notifyListeners();
  }

  void setIcon(icon) {
    _userInfo.icon = icon;
    notifyListeners();
  }

  void setDesc(desc) {
    _userInfo.desc = desc;
    notifyListeners();
  }

  void setUps(ups) {
    _userInfo.icon = ups;
    notifyListeners();
  }

  void setUserId(userId) {
    _userInfo.userId = userId;
    notifyListeners();
  }
}
