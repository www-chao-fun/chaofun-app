import 'constants.dart';
import 'package:flutter/material.dart';

// This is our  main focus
// Let's apply light and dark theme on our app
// Now let's add dark theme on our app

ThemeData lightThemeData() {
  return ThemeData.light().copyWith(
    backgroundColor: Colors.white,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
    appBarTheme: appBarTheme,
    iconTheme: IconThemeData(color: kContentColorLightTheme),

    colorScheme: ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: kContentColorLightTheme.withOpacity(0.7),
      unselectedItemColor: kContentColorLightTheme.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: kPrimaryColor),
      showUnselectedLabels: true,
    ),
  );
}

ThemeData darkThemeData() {
  // Bydefault flutter provie us light and dark theme
  // we just modify it as our need
  return ThemeData.dark().copyWith(
    backgroundColor: Color(0xFF000000),
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kContentColorLightTheme,
    appBarTheme: appBarTheme,
    iconTheme: IconThemeData(color: kContentColorDarkTheme),
    colorScheme: ColorScheme.dark().copyWith(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kContentColorLightTheme,
      selectedItemColor: Colors.white70,
      unselectedItemColor: kContentColorDarkTheme.withOpacity(0.32),
      selectedIconTheme: IconThemeData(color: kPrimaryColor),
      showUnselectedLabels: true,
    ),
  );
}



class Themes {
  static const DARK_THEME_CODE = 0;
  static const LIGHT_THEME_CODE = 1;

  static final _dark = darkThemeData();

  static final _light = lightThemeData();

  static ThemeData getTheme(int code) {
    if(code == LIGHT_THEME_CODE){
      return _light;
    }
    return _dark;
  }

}



final appBarTheme = AppBarTheme(centerTitle: false, elevation: 0);
