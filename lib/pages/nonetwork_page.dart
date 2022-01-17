import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoNetWorkPage extends StatelessWidget {
  final Function callBack;
  NoNetWorkPage({Key key, this.callBack}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Container(
        height: 350,
        color: Colors.white,
        child: InkWell(
          onTap: () async {
            if (this.callBack != null) {
              this.callBack(context);
            }
          },
          child: Column(
            children: [
              Image.asset(
                'assets/icon/network.png',
                width: ScreenUtil().setWidth(400),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Text(
                  '网络异常',
                  style: TextStyle(
                    color: Color.fromRGBO(158, 159, 163, 1),
                    fontSize: ScreenUtil().setSp(40),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '请检查下您的网络设置,点击页面刷新',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: Color.fromRGBO(185, 186, 187, 1)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
