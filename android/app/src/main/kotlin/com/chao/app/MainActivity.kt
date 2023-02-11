package com.chao.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.alibaba.sdk.android.push.CloudPushService
import com.alibaba.sdk.android.push.CommonCallback
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import com.alibaba.sdk.android.push.popup.PopupNotifyClick
import com.alibaba.sdk.android.push.popup.PopupNotifyClickListener
import com.alibaba.sdk.android.push.register.MiPushRegister
import com.alibaba.sdk.android.push.register.OppoRegister
import com.alibaba.sdk.android.push.register.VivoRegister
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import com.umeng.socialize.PlatformConfig
import com.umeng.socialize.UMShareAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import org.json.JSONObject
import java.util.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.chao.fun/main_channel"

    private val imageBaseUrl = "https://i.chao-fan.com/"

    private val baseUrl = "https://choa.fun/p/"

    private var inited = false;

    private val TAG = "FApp"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("chaofun", flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            try {
                // 华为要求，必须用户同意协议以后才可以获取
                if (call.method.equals("getDeviceInfo") && inited) {
                    var pushService: CloudPushService = PushServiceFactory.getCloudPushService();
                    var resultMap = mutableMapOf<String, String>()
                    resultMap["appKey"] = "31385551";
                    resultMap["deviceId"] = pushService.deviceId
                    result.success(resultMap)

                } else if (call.method.equals("share")) {
                    Handler(Looper.getMainLooper()).post {
                        val argMap = call.arguments as Map<String, Any>
                        Share.share(this@MainActivity, argMap);
                    }
                } else if (call.method.equals("initAndroidSDK")) {
                    inited = true;
                    Handler(Looper.getMainLooper()).post {
                        init();
                    }
                }
            } catch (e: Exception) {
                println(e.message)
            }
        }

        this.applicationContext

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "onCreate push step 1")

//        PopupNotifyClick(PopupNotifyClickListener { title, summary, extMap ->
//            run {
//                runOnUiThread {
//                    Log.i(TAG, "onCreate push step 2")
//                    val channel = MethodChannel(FlutterEngineCache.getInstance()["chaofun"]!!.dartExecutor.binaryMessenger, "app.chao.fun/main_channel")
//                    channel.invokeMethod("push", extMap)
//                }
//            }
//        }).onCreate(this, this.intent)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
    }

    fun init() {

        //////注意，下面是小米华为的辅助通道，是一种黑科技，可以在进程杀死的情况下，收到推送消息，所谓的离线推送，
        /////如果需要，注意读一下下面一节，服务端代码那块，如果不需要，直接注释2行，可以满足app在线收到通知
        // 注册方法会自动判断是否支持小米系统推送，如不支持会跳过注册。

        // 注册方法会自动判断是否支持华为系统推送，如不支持会跳过注册。
//        HuaWeiRegister.register(this);
        //GCM/FCM辅助通道注册，这个地方打开的情况我没测试，不过，GCM你懂的。
        //        GcmRegister.register(this, sendId, applicationId); //sendId/applicationId为步骤获得的参数
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mNotificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            // 通知渠道的id。
            val id = "chaofun"
            // 用户可以看到的通知渠道的名字。
            val name: CharSequence = "ChaoFun Notification Channel"
            // 用户可以看到的通知渠道的描述。
            val description = "ChaoFun Notification Channel"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)

            // 配置通知渠道的属性。
            mChannel.description = description
            // 设置通知出现时的闪灯（如果Android设备支持的话）。
            mChannel.enableLights(true)
            mChannel.lightColor = Color.RED
            // 设置通知出现时的震动（如果Android设备支持的话）。
            mChannel.enableVibration(true)
            mChannel.vibrationPattern = longArrayOf(100, 200, 300, 400, 500, 400, 300, 200, 400)
            // 最后在notificationmanager中创建该通知渠道。
            mNotificationManager.createNotificationChannel(mChannel)
        }


        UMConfigure.init(this, "5f7382d880455950e49c6195", "Umeng", UMConfigure.DEVICE_TYPE_PHONE, "")
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)
        PlatformConfig.setWeixin("wx301447e1e7833b29", "d108db12d305e28f9aa8e40396a4a14b")
        PlatformConfig.setQQZone("101935770", "85fda2250376ca4a7a778a3be0088e53")
        PlatformConfig.setDing("dingoaas7n1scswrel4kyq")
        PlatformConfig.setSinaWeibo("1791909991", "bdf690e90dab45bc2fa832417edd3762", "https://chao.fan")
        PlatformConfig.setQQFileProvider("com.chao.app.fileprovider")
        PlatformConfig.setWXFileProvider("com.chao.app.fileprovider")
        PlatformConfig.setSinaFileProvider("com.chao.app.fileprovider")


        initCloudChannel(this.applicationContext as ChaoFunApp)
    }

    private fun initCloudChannel(applicationContext: ChaoFunApp) {
        PushServiceFactory.init(applicationContext)
        val pushService = PushServiceFactory.getCloudPushService()
        pushService.register(applicationContext, object : CommonCallback {
            override fun onSuccess(response: String) {
                Log.i(TAG, "init cloudchannel success")
                //                pushService.
            }

            override fun onFailed(errorCode: String, errorMessage: String) {
                Log.i(TAG, "init cloudchannel failed -- errorcode:$errorCode -- errorMessage:$errorMessage")
            }
        })
        var version: String? = null
        try {
            version = packageManager.getPackageInfo(packageName, 0).versionName
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }

//        pushService.setDebug(true);
        pushService.bindTag(1, arrayOf(
                version
        ), null, object : CommonCallback {
            override fun onSuccess(response: String) {
                Log.i(TAG, "bind version success")
                //                pushService.
            }

            override fun onFailed(errorCode: String, errorMessage: String) {
                Log.i(TAG, "bind version failed -- errorcode:$errorCode -- errorMessage:$errorMessage")
            }
        })
        OppoRegister.register(applicationContext, "75de6e89c3274bbfae3116137dd3ccb1", "3702fbd06f9f416b9c188441bedb7b91")
        HuaWeiRegister.register(applicationContext)
        MiPushRegister.register(this, "2882303761518919904", "5261891975904")
        VivoRegister.register(applicationContext)

        PopupNotifyClick(PopupNotifyClickListener { title, summary, extMap ->
            run {
                runOnUiThread {
                    Log.i(TAG, "onCreate push step 2")
                    val channel = MethodChannel(FlutterEngineCache.getInstance()["chaofun"]!!.dartExecutor.binaryMessenger, "app.chao.fun/main_channel")
                    channel.invokeMethod("push", extMap)
                }
            }
        }).onCreate(this, this.intent)

    }


}
