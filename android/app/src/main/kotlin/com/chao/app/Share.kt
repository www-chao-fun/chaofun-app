package com.chao.app

import android.app.Activity
import android.graphics.Bitmap
import com.umeng.socialize.ShareAction
import com.umeng.socialize.bean.SHARE_MEDIA
import com.umeng.socialize.media.*
import com.umeng.socialize.utils.ShareBoardlistener

class Share {
    companion object {
        private val CHANNEL = "app.chao.fun/main_channel"

        private val imageBaseUrl = "https://i.chao.fun/"

        private val baseUrl = "https://chao.fun/p/"

        private val miniProgramBaseUrl = "/pages/detail/detail?postId="


        fun umengShare(activity: Activity, argMap: Map<String, Any>, baseMediaObject: BaseMediaObject, shareAction: ShareAction) {

            val shareBoardlistener = ShareBoardlistener { snsPlatform, share_media ->

                if (share_media == SHARE_MEDIA.WEIXIN && (argMap["type"]!!.equals("image") ||  argMap["type"]!!.equals("forward") || argMap["type"]!!.equals("gif") ||  argMap["type"]!!.equals("article") || argMap["type"]!!.equals("vote") || argMap["type"]!!.equals("inner_video")) ) {

                    var ummin = UMMin("https://chao.fun/p/" + (argMap["postId"] as java.lang.Integer))

                    ummin.path = miniProgramBaseUrl + (argMap["postId"] as java.lang.Integer);

                    ummin.userName = "gh_41eb4fc2a95b"
                    ummin.title = argMap["title"] as String;

                    var umImage = getUMImage(activity, argMap);
                    if (umImage != null) {
                        ummin.setThumb(umImage);
                    }

                    ShareAction(activity)
                            .withText(argMap["title"] as String)
                            .withSubject("分享奇趣、发现世界")
                            .withMedia(ummin)
                            .setPlatform(share_media)
                            .setCallback(null)
                            .share()

                    //根据key来区分自定义按钮的类型，并进行对应的操作
                } else if (share_media == SHARE_MEDIA.SINA && argMap["type"]!!.equals("image")) {
                    var umImage = getUMImage(activity, argMap);

                    shareAction
                            .withText(argMap["title"] as String)
                            .withSubject(" ")
                            .withMedia(umImage)
                            .setPlatform(share_media)
                            .setCallback(null)
                            .share();


                } else { //社交平台的分享行为
                    shareAction
                            .withText(argMap["title"] as String)
                            .withSubject(" ")
                            .setPlatform(share_media)
                            .setCallback(null)
                            .share();
                }

            }

            ShareAction(activity)
                    .withText(argMap["title"] as String)
                    .withSubject(" ")
                    .setCallback(null)
                    .setShareboardclickCallback(shareBoardlistener)
                    .setDisplayList(SHARE_MEDIA.WEIXIN, SHARE_MEDIA.WEIXIN_CIRCLE, SHARE_MEDIA.WEIXIN_FAVORITE, SHARE_MEDIA.QQ, SHARE_MEDIA.QZONE, SHARE_MEDIA.DINGTALK, SHARE_MEDIA.SINA)
                    .open();
        }

        fun shareWeb(activity: Activity, argMap: Map<String, Any>) {
            var umWeb = UMWeb(argMap["link"] as String);
            umWeb.title = argMap["title"] as String
            umWeb.description = " ";

            if (argMap["cover"] != null) {
                umWeb.setThumb(UMImage(activity, imageBaseUrl + (argMap["cover"] as String)))
            }

            umengShare(activity, argMap, umWeb, ShareAction(activity).withMedia(umWeb));
        }

        fun shareOutLink(activity: Activity, argMap: Map<String, Any>) {
            var umWeb = UMWeb(baseUrl + (argMap["postId"] as java.lang.Integer))
            umWeb.title = argMap["title"] as String
            umWeb.description = " ";

            var umImage: UMImage? = null;
            if (argMap["cover"] != null) {
                umImage = UMImage(activity, imageBaseUrl + (argMap["cover"] as String) + "?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            } else if (argMap["imageName"] != null) {
                umImage = UMImage(activity, imageBaseUrl + (argMap["imageName"] as String) + "?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            } else {
                umImage = UMImage(activity, imageBaseUrl + "9563cdd828d2b674c424b79761ccb4c0.png?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            }
            if (umImage != null) {
                umWeb.setThumb(umImage);
            }

            umengShare(activity, argMap, umWeb, ShareAction(activity).withMedia(umWeb));
        }

        fun share(activity: Activity, argMap: Map<String, Any>) {
            if (argMap["type"] != null && argMap["type"]!!.equals("link") ) {
                shareWeb(activity, argMap);
            } else {
                shareOutLink(activity, argMap)
            }
        }

        fun getUMImage(activity: Activity, argMap: Map<String, Any>) : UMImage {
            var umImage: UMImage? = null;

            if (argMap["cover"] != null) {
                umImage = UMImage(activity, imageBaseUrl + (argMap["cover"] as String) + "?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            } else if (argMap["imageName"] != null) {
                umImage = UMImage(activity, imageBaseUrl + (argMap["imageName"] as String) + "?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            } else {
                umImage = UMImage(activity, imageBaseUrl + "9563cdd828d2b674c424b79761ccb4c0.png?x-oss-process=image/resize,h_408,w_300/format,webp/quality,q_75")
            }

            return umImage
        }
    }
}
