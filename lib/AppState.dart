import 'package:flutter/material.dart';
import 'package:flutter_chaofan/theme.dart';
import 'package:flutter_chaofan/utils/const.dart';
import 'package:flutter_chaofan/utils/converters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateContainer extends StatefulWidget {
  final Widget child;

  AppStateContainer({@required this.child});

  @override
  _AppStateContainerState createState() => _AppStateContainerState();

  static _AppStateContainerState of(BuildContext context) {
    var widget =
    context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>();
    print(widget);


    return  widget.data;
  }
}

class _AppStateContainerState extends State<AppStateContainer> {


  ThemeData _theme = Themes.getTheme(Themes.DARK_THEME_CODE);
  int themeCode = Themes.DARK_THEME_CODE;
  TemperatureUnit temperatureUnit = TemperatureUnit.celsius;


  @override
  initState() {
    super.initState();

    SharedPreferences.getInstance().then((sharedPref) {
      setState(() {
        themeCode = sharedPref.getInt(CONSTANTS.SHARED_PREF_KEY_THEME) ??
            Themes.DARK_THEME_CODE;
        temperatureUnit = TemperatureUnit.values[
        sharedPref.getInt(CONSTANTS.SHARED_PREF_KEY_TEMPERATURE_UNIT) ??
            TemperatureUnit.celsius.index];
        this._theme = Themes.getTheme(themeCode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(theme.accentColor);
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  ThemeData get theme => _theme;

  updateTheme(int themeCode) {
    setState(() {
      _theme = Themes.getTheme(themeCode);
      this.themeCode = themeCode;
    });
    SharedPreferences.getInstance().then((sharedPref) {
      sharedPref.setInt(CONSTANTS.SHARED_PREF_KEY_THEME, themeCode);
    });
  }

  updateTemperatureUnit(TemperatureUnit unit) {
    setState(() {
      this.temperatureUnit = unit;
    });
    SharedPreferences.getInstance().then((sharedPref) {
      sharedPref.setInt(CONSTANTS.SHARED_PREF_KEY_TEMPERATURE_UNIT, unit.index);
    });
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _AppStateContainerState data;

  const _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer oldWidget) => true;
}
