package com.chao.app

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.alibaba.sdk.android.push.CloudPushService
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory
import com.alibaba.sdk.android.push.popup.PopupNotifyClick
import com.alibaba.sdk.android.push.popup.PopupNotifyClickListener
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

    private val imageBaseUrl = "https://i.chao.fun/"

    private val baseUrl = "https://chao.fun/p/"



    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("chaofun", flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            try {
                if (call.method.equals("getDeviceInfo")) {
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
                }
            } catch (e: Exception) {
                println(e.message)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        PopupNotifyClick(PopupNotifyClickListener { title, summary, extMap ->
            run {
                runOnUiThread {
                    val channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, "app.chao.fun/main_channel")
                    channel.invokeMethod("push", extMap)
                }
            }
        }).onCreate(this, this.intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);
    }
}
