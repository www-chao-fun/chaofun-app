import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToolsPage extends StatelessWidget {
  final Function callBack;
  ToolsPage({Key key, this.callBack}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('我的工具'),
        // ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/parseUrlPage',
                    arguments: {'type': 1},
                  );
                },
                child: Container(
                  color: Colors.grey,
                  height: ScreenUtil().setWidth(100),
                  alignment: Alignment.center,
                  child: Text('去水印'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
