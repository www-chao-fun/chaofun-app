import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleWidget extends StatelessWidget {
  Map item;
  ArticleWidget({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = item['article'].replaceAll('</p>', '</p> \n');
    a = a
        .replaceAll('</ol>', '</ol> \n')
        .replaceAll('</ul>', '</ul> \n')
        .replaceAll('</div>', '</div> \n')
        .replaceAll('<p/>', '</p> \n')
        .replaceAll('</h1>', '</h1> \n')
        .replaceAll('</h2>', '</h2> \n')
        .replaceAll('</h3>', '</h3> \n');
    var document = HtmlParser.parseHTML(a);
    var b = document.body.text.split('\n');
    var c;
    bool hasMore = false;
    if (b.length > 10) {
      c = b.sublist(0, 10).join('\n');
      hasMore = true;
    } else {
      c = b.join('\n');
    }
    // print(a);
    // print(b);
    // print('document');
    // print(document.outerHtml);

    print(123);
    print(item['article'].toString().trim());
    return Container(
      alignment: Alignment.topLeft,
      // 设置盒子最大或最小高度宽度
      // color: Colors.blue,
      // constraints: BoxConstraints(
      //   // maxHeight: ScreenUtil().setWidth(450),
      //   minHeight: 70,
      //   maxHeight: 200,
      // ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/postdetail',
            arguments: {"postId": item['postId'].toString()},
          );
        },

        child: (item['article'].trim().startsWith('<p') ||
                item['article'].trim().startsWith('<ol') ||
                item['article'].trim().startsWith('<ul') ||
                item['article'].trim().startsWith('<a') ||
                item['article'].trim().startsWith('<div') ||
                item['article'].trim().startsWith('<block') ||
                item['article'].trim().startsWith('<h'))
            // ? Html(
            //     data:
            //         '<div style="height:250px;overflow:hidden;display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 1; overflow: hidden;">' +
            //             item['article'] +
            //             '</div>',
            //     style: {
            //       "div": Style(
            //         // height: ScreenUtil().setHeight(200),
            //         alignment: Alignment.topLeft,
            //         // backgroundColor: Colors.red,
            //       ),
            //     },
            //   )
            ? Text(
                c,
                style: TextStyle(height: 1.6),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                item['article'],
                style: TextStyle(height: 1.6),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
        // child: Html(
        //   data:
        //       '<div style="height:250px;overflow:hidden;display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 1; overflow: hidden;">' +
        //           item['article'] +
        //           '</div>',
        //   style: {
        //     "div": Style(
        //       // height: ScreenUtil().setHeight(200),
        //       alignment: Alignment.topLeft,
        //       // backgroundColor: Colors.red,
        //     ),
        //   },
        // ),
      ),
    );
  }
}
