


import 'package:flutter_chaofan/config/set.dart';
import 'package:flutter_screenutil/screen_util.dart';

// 用来把图片裁剪以后放到合适的框内的
class ImageUtils {

  // static DateTime now = new DateTime.now();
  static String ossUrl(String imageName, imageWidth, imageHeight, containerWidth, containerHeight) {
    var screenUtil = ScreenUtil();

    String imageUrl = imageName;

    if (!imageName.startsWith("https://chaofun.oss-cn-hangzhou.aliyuncs.com")) {
      imageUrl =  KSet.imgOrigin + imageUrl;
    }

    if (imageWidth == null || imageHeight == null) {
      if (containerWidth == null || containerHeight == null) {
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,h_500,w_500/format,webp/quality,q_75';
      } else {
        var actualContainerHeight = (containerHeight * screenUtil.pixelRatio).round();
        var actualContainerWidth = (containerWidth * screenUtil.pixelRatio).round();
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,w_$actualContainerWidth,h_$actualContainerHeight/format,webp/quality,q_75';
      }
    } else {
      if (containerWidth == null || containerHeight == null) {
        imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,h_500,w_500/format,webp/quality,q_75';
      } else {
        var actualContainerHeight = (containerHeight * screenUtil.pixelRatio).round();
        var actualContainerWidth = (containerWidth * screenUtil.pixelRatio).round();
        if (longImage(imageWidth, imageHeight)) {
          // 长图
          var tureHeight = (imageWidth * 1.0 * actualContainerHeight / actualContainerWidth).round() * 2;
          imageUrl = imageUrl + '?x-oss-process=image/crop,h_$tureHeight/format,webp/quality,q_75';
        } else {
          imageUrl = imageUrl + '?x-oss-process=image/resize,m_fill,w_$actualContainerWidth,h_$actualContainerHeight/format,webp/quality,q_75';
        }
      }
    }

    return imageUrl;
  }

  static bool longImage(imageWidth, imageHeight) {
    if (imageWidth == null || imageHeight == null) {
      return false;
    }

    if (imageHeight * 1.0 /  imageWidth > 2.5) {
      return true;
    }

    return false;
  }
}