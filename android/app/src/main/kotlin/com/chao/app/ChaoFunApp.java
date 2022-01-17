package com.chao.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;
import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;
import com.alibaba.sdk.android.push.register.MiPushRegister;
import com.alibaba.sdk.android.push.register.OppoRegister;
import com.alibaba.sdk.android.push.register.VivoRegister;
import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.socialize.PlatformConfig;

/**
 * @Author 此间
 * @Email zhangyue.zhangyue@alibaba-inc.com
 * @Description
 * @Date 2020/9/29 11:23 PM
 **/

public class ChaoFunApp extends io.flutter.app.FlutterApplication {

    private static final String TAG = "FApp";

    @Override
    public void onCreate() {
        super.onCreate();
        //////注意，下面是小米华为的辅助通道，是一种黑科技，可以在进程杀死的情况下，收到推送消息，所谓的离线推送，
        /////如果需要，注意读一下下面一节，服务端代码那块，如果不需要，直接注释2行，可以满足app在线收到通知
        // 注册方法会自动判断是否支持小米系统推送，如不支持会跳过注册。

        // 注册方法会自动判断是否支持华为系统推送，如不支持会跳过注册。
//        HuaWeiRegister.register(this);
        //GCM/FCM辅助通道注册，这个地方打开的情况我没测试，不过，GCM你懂的。
        //        GcmRegister.register(this, sendId, applicationId); //sendId/applicationId为步骤获得的参数
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            // 通知渠道的id。
            String id = "chaofun";
            // 用户可以看到的通知渠道的名字。
            CharSequence name = "ChaoFun Notification Channel";
            // 用户可以看到的通知渠道的描述。
            String description = "ChaoFun Notification Channel";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(id, name, importance);

            // 配置通知渠道的属性。
            mChannel.setDescription(description);
            // 设置通知出现时的闪灯（如果Android设备支持的话）。
            mChannel.enableLights(true);
            mChannel.setLightColor(Color.RED);
            // 设置通知出现时的震动（如果Android设备支持的话）。
            mChannel.enableVibration(true);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            // 最后在notificationmanager中创建该通知渠道。
            mNotificationManager.createNotificationChannel(mChannel);

        }


        UMConfigure.init(this, "5f7382d880455950e49c6195", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "");
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO);
        PlatformConfig.setWeixin("wx301447e1e7833b29", "d108db12d305e28f9aa8e40396a4a14b");
        PlatformConfig.setQQZone("101935770", "85fda2250376ca4a7a778a3be0088e53");
        PlatformConfig.setDing("dingoaas7n1scswrel4kyq");
        PlatformConfig.setSinaWeibo("1791909991","bdf690e90dab45bc2fa832417edd3762", "https://chao.fun");
        PlatformConfig.setQQFileProvider("com.chao.app.fileprovider");
        PlatformConfig.setWXFileProvider("com.chao.app.fileprovider");
        PlatformConfig.setSinaFileProvider("com.chao.app.fileprovider");


        initCloudChannel(this);

    }

    /**
     * 初始化云推送通道
     *
     * @param applicationContext
     */
    private void initCloudChannel(ChaoFunApp applicationContext) {
        PushServiceFactory.init(applicationContext);
        CloudPushService pushService = PushServiceFactory.getCloudPushService();
        
        pushService.register(applicationContext, new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                Log.i(TAG, "init cloudchannel success");
//                pushService.
            }

            @Override
            public void onFailed(String errorCode, String errorMessage) {
                Log.i(TAG, "init cloudchannel failed -- errorcode:" + errorCode + " -- errorMessage:" + errorMessage);
            }

        });

        String version = null;

        try {
            version = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
        } catch (Exception e) {
            e.printStackTrace();
        }

//        pushService.setDebug(true);
        pushService.bindTag(1, new String[] {
                version
        }, null,  new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                Log.i(TAG, "bind version success");
//                pushService.
            }

            @Override
            public void onFailed(String errorCode, String errorMessage) {
                Log.i(TAG, "bind version failed -- errorcode:" + errorCode + " -- errorMessage:" + errorMessage);
            }

        });

        OppoRegister.register(applicationContext, "75de6e89c3274bbfae3116137dd3ccb1", "3702fbd06f9f416b9c188441bedb7b91");
        HuaWeiRegister.register(applicationContext);
        MiPushRegister.register(this, "2882303761518919904", "5261891975904");
        VivoRegister.register(applicationContext);
    }
}
