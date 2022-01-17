import 'package:flutter/material.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/widget/common/addForum_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(234, 234, 234, 1),
      body: Container(
        alignment: Alignment.center,
        height: ScreenUtil().setHeight(1334),
        child: AddForumWidget(
          height: ScreenUtil().setHeight(1334),
          callBack: () {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(builder: (context) => IndexPage()),
                (route) => route == null,
              );
            });
          },
        ),
      ),
    );
  }
}
