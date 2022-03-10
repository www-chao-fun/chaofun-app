import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/AppState.dart';
import 'package:flutter_chaofan/config/color.dart';

import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_chaofan/provide/user.dart';
import 'package:provider/provider.dart';

class SetThemePage extends StatefulWidget {
  _PushSetPageState createState() => _PushSetPageState();
}

class _PushSetPageState extends State<SetThemePage> {
  String version;
  var appVersionInfo;

  bool ifdown = false;
  bool loopGif;
  var plat;
  var downpercent = 0.0;
  var hasSet;
  String selectTheme = "system";

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loopGif = Provider.of<UserStateProvide>(context, listen: false).loopGif;
  }

  int theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          '设置主题',
          style: Theme.of(context).textTheme.headline6

        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RadioListTile(
            value: 1,
            onChanged: (value) {
              setState(() {
                this.theme=value;
                AppStateContainer.of(context).updateTheme(Themes.DARK_THEME_CODE);
              });
            },
            groupValue: this.theme,
            title: Text("暗黑"),
            secondary: Icon(Icons.dark_mode),
            selected: this.theme == 1,
          ),
          RadioListTile(
            value: 2,
            onChanged: (value) {
              setState(() {
                this.theme=value;
                AppStateContainer.of(context).updateTheme(Themes.LIGHT_THEME_CODE);
              });
            },
            groupValue: this.theme,
            title: Text("明亮"),
            secondary: Icon(Icons.light_mode),
            selected: this.theme == 2,
          ),
        ],
      ),
    );
  }
}
