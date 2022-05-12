import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chaofan/config/color.dart';
import 'package:flutter_chaofan/api/api.dart';
import 'package:flutter_chaofan/config/index.dart';
import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_chaofan/pages/index_page.dart';
import 'package:flutter_chaofan/pages/post_detail/chao_fun_webview.dart';
import 'package:flutter_chaofan/pages/user/at_user_list.dart';
import 'package:flutter_chaofan/provide/current_index_provide.dart';
import 'package:flutter_chaofan/provide/user.dart';
import 'package:flutter_chaofan/service/home_service.dart';
import 'package:flutter_chaofan/utils/http_utils.dart';
import 'package:flutter_chaofan/utils/utils.dart';
import 'package:flutter_chaofan/widget/image/image_scrollshow_wiget.dart';
import 'package:flutter_chaofan/widget/items/bottom_widget.dart';
import 'package:flutter_chaofan/widget/items/comment_widget.dart';
import 'package:flutter_chaofan/widget/items/predict_widget.dart';
import 'package:flutter_chaofan/widget/items/video_widget.dart';
import 'package:flutter_chaofan/widget/items/vote_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:flutter_umeng_plugin/flutter_umeng_plugin.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chaofan/widget/items/link_widget.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostItemWidget extends StatelessWidget {
  String imgurl;
  Map data;
  Map postInfo;
  PostItemWidget({Key key, this.imgurl, this.data, this.postInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(10),
        right: ScreenUtil().setWidth(10),
      ),
      child: (data['article'].trim().startsWith('<p') ||
            data['article'].trim().startsWith('<ol') ||
            data['article'].trim().startsWith('<br') ||
            data['article'].trim().startsWith('<a') ||
            data['article'].trim().startsWith('<ul') ||
            data['article'].trim().startsWith('<div') ||
            data['article'].trim().startsWith('<block') ||
            data['article'].trim().startsWith('<h'))
          ? Html(
              data: data['article'],
              style: {
                'p': Style(
                  fontSize: FontSize.large,
                  lineHeight: LineHeight(1.5),
                  whiteSpace: WhiteSpace.PRE,
                ),
              },
              onImageTap: (src, _, __, ___) {
                Navigator.of(context).push(
                  FadeRoute(
                    page: JhPhotoAllScreenShow(
                      imgDataArr: [src],
                      index: 0,
                    ),
                  ),
                );
                print(src);
              },
              onLinkTap: (src, _, __, ___) {
                Utils.toNavigate(context, src, null);
                print(src);
              },
            )
          : Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 5),
              child: Text(
                data['article'],
                style: TextStyle(
                  height: 1.6,
                  fontSize: ScreenUtil().setSp(32),
                ),
              ),
            ),
    );
  }

}
