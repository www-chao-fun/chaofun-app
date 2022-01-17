#Flutter Wrapper 混淆压缩规则
#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.xiaomi.** {*;}
-dontwarn com.xiaomi.**
-keepclasseswithmembernames class ** {
    native <methods>;
}
-keep class com.android.dingtalk.share.ddsharemodule.** { *; }
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }
-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-keep class com.alipay.** {*;}
-keep class com.ut.** {*;}
-keep class com.ta.** {*;}
-keep class anet.**{*;}
-keep class anetwork.**{*;}
-keep class org.android.spdy.**{*;}
-keep class org.android.agoo.**{*;}
-keep class android.os.**{*;}
-keep class org.json.**{*;}
-dontwarn com.taobao.**
-dontwarn com.alibaba.**
-dontwarn com.alipay.**
-dontwarn anet.**
-dontwarn org.android.spdy.**
-dontwarn org.android.agoo.**
-dontwarn anetwork.**
-dontwarn com.ut.**
-dontwarn com.ta.**

-keep class com.sina.**{*;}
-dontwarn com.sina.**

-keep class com.huawei.** {*;}
-dontwarn com.huawei.**

-keep public class * extends android.app.Service

-keep class com.vivo.** {*;}
-dontwarn com.vivo.**

