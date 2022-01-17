import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotoViewPage extends StatelessWidget {
  final Lists = [
    'http://oss.meibbc.com/BeautifyBreast/file/images/bd8afefecfe0479fbd2998fbf16bb57a.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/4a4af9f4b5cf47e782e3a35c5b9d6400.PNG?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/aec54777d2f74843803d4a5956ccb153.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/bd8afefecfe0479fbd2998fbf16bb57a.png?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/4a4af9f4b5cf47e782e3a35c5b9d6400.PNG?x-oss-process=style/800x800',
    'http://oss.meibbc.com/BeautifyBreast/file/images/aec54777d2f74843803d4a5956ccb153.png?x-oss-process=style/800x800',
  ];
  @override
  Widget build(BuildContext context) {
    // if (Lists.length > 6) {
    //   Lists.removeRange(6, Lists.length);
    // }
    return Scaffold(
      appBar: AppBar(title: Text('图片预览')),
      body: Container(
        padding: EdgeInsets.all(4.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            childAspectRatio: 1.0,
          ),
          itemCount: Lists.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/preview',
                  arguments: {"index": 1},
                );
                // support.mycJumpPage(
                //   context: context,
                //   page: PhotpGalleryPage(
                //     index: index,
                //     photoList: list,
                //   ),
                // );
              },
              child: Container(
                child: Image.network(Lists[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
