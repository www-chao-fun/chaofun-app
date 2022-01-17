import 'package:flutter_chaofan/config/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static String token = "";

  static Future getToken() async {
    if (token == null || token.isEmpty) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      token = sharedPreferences.getString(KString.TOKEN) ?? null;
    }
    return token;
  }

  // static Future getImageHead() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.get(Strings.HEAD_URL);
  // }

  // static Future getUserName() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.get(Strings.NICK_NAME);
  // }
}
