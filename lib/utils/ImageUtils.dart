


import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_screenutil/screen_util.dart';

// 用来把图片裁剪以后放到合适的框内的
class ImageUtils {

  // static DateTime now = new DateTime.now();
  static String ossUrl(String imageName, imageWidth, imageHeight, containerWidth, containerHeight) {
    var screenUtil = ScreenUtil();

    String imageUrl = imageName;

    if (!imageName.startsWith("https://i.chao.fun")) {
      imageUrl =  KSet.imgOrigin + imageUrl;
    }

    if (imageWidth == null || imageHeight == null) {
      if (containerWidth == null || containerHeight == null) {
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,h_500,w_500';
      } else {
        var actualContainerHeight = (containerHeight * screenUtil.pixelRatio).round();
        var actualContainerWidth = (containerWidth * screenUtil.pixelRatio).round();
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,w_$actualContainerWidth,h_$actualContainerHeight';
      }
    } else {
      if (containerWidth == null || containerHeight == null) {
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,h_500,w_500';
      } else {
        var actualContainerHeight = (containerHeight * screenUtil.pixelRatio).round();
        var actualContainerWidth = (containerWidth * screenUtil.pixelRatio).round();
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,w_$actualContainerWidth,h_$actualContainerHeight';
      }
    }

    return imageUrl;
  }

  static bool longImage(String imageName, imageWidth, imageHeight, containerWidth, containerHeight) {
    return true;
  }
}