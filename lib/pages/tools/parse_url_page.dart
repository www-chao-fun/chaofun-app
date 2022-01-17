import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParseUrlPage extends StatefulWidget {
  final Function callBack;
  ParseUrlPage({Key key, this.callBack}) : super(key: key);
  _ParseUrlPageState createState() => _ParseUrlPageState();
}

class _ParseUrlPageState extends State<ParseUrlPage> {
  TextEditingController _contentController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('我的工具'),
        // ),
        body: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                TextField(
                  // focusNode: _focusNode2,
                  controller: _contentController,
                  maxLines: 6,
                  // decoration: InputDecoration.collapsed(hintText: "请输入标题"),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(34),
                  ),
                  decoration: InputDecoration(
                    hintText: "请输入链接地址",
                    contentPadding: EdgeInsets.fromLTRB(14, 8, 10, 8),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: KColor.defaultGrayColor, width: 0.5)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: KColor.defaultGrayColor, width: 1)),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  color: KColor.primaryColor,
                  textColor: Colors.white,
                  minWidth: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setWidth(80),
                  child: Text('解析地址'),
                  onPressed: () {
                    print('开始解析');
                    print(_contentController.text);
                    Navigator.pushNamed(
                      context,
                      '/dropWaterPage',
                      arguments: {'url': _contentController.text},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
