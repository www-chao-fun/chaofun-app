package com.chao.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.JsonReader;
import android.util.Log;
import android.widget.RemoteViews;
import androidx.core.app.NotificationCompat;
import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodChannel;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * @Author 此间
 * @Email zhangyue.zhangyue@alibaba-inc.com
 * @Description
 * @Date 2020/9/30 12:19 AM
 **/

public class MyMessageReceiver extends MessageReceiver {

    private  FlutterEngine flutterEngine;

    // 消息接收部分的LOG_TAG
    public static final String REC_TAG = "receiver";

    @Override
    protected void onNotification(Context context, String s, String s1, Map<String, String> map) {
        Log.e("MyMessageReceiver", "onMessage, messageId:");
//        buildNotification(context, cPushMessage);
    }

    @Override
    public void onMessage(Context context, CPushMessage cPushMessage) {
//        Log.e("MyMessageReceiver", "onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());
//        buildNotification(context, cPushMessage);
    }
    @Override
    public void onNotificationOpened(Context context, String title, String summary, String extraMap) {
        Log.e("MyMessageReceiver", "onNotificationOpened, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);

        MethodChannel channel = new MethodChannel(FlutterEngineCache.getInstance().get("chaofun").getDartExecutor().getBinaryMessenger(), "app.chao.fun/main_channel");
        channel.invokeMethod("push", getMap(extraMap));
    }

    @Override
    public void onNotificationOpened(Context var1, String var2, String var3, String var4, int var5) {
        if (var5 == 4) {
            this.onNotificationClickedWithNoAction(var1, var2, var3, var4);
        } else {
            this.onNotificationOpened(var1, var2, var3, var4);
        }

    }

    public static Map<String, Object> getMap(String jsonString) {
        JSONObject jsonObject;
        try
        {
            jsonObject = new JSONObject(jsonString);   @SuppressWarnings("unchecked")
        Iterator<String> keyIter = jsonObject.keys();
            String key;
            Object value;
            Map<String, Object> valueMap = new HashMap<String, Object>();
            while (keyIter.hasNext())
            {
                key = (String) keyIter.next();
                value = jsonObject.get(key);
                valueMap.put(key, value);
            }
            return valueMap;
        }
        catch (JSONException e)
        {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    protected void onNotificationClickedWithNoAction(Context context, String title, String summary, String extraMap) {
        Log.e("MyMessageReceiver", "onNotificationClickedWithNoAction, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
        MethodChannel channel = new MethodChannel(FlutterEngineCache.getInstance().get("chaofun").getDartExecutor().getBinaryMessenger(), "app.chao.fun/main_channel");
        channel.invokeMethod("push", getMap(extraMap));
    }
    @Override
    protected void onNotificationReceivedInApp(Context context, String title, String summary, Map<String, String> extraMap, int openType, String openActivity, String openUrl) {
        Log.e("MyMessageReceiver", "onNotificationReceivedInApp, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap + ", openType:" + openType + ", openActivity:" + openActivity + ", openUrl:" + openUrl);
    }
    @Override
    protected void onNotificationRemoved(Context context, String messageId) {
        Log.e("MyMessageReceiver", "onNotificationRemoved");
    }

    public void buildNotification(Context context, CPushMessage message) {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.toast_custom);
//        remoteViews.setImageViewResource(R.id, R.mipmap.ic_launcher);
//        remoteViews.setTextViewText(R.id.tv_custom_title, message.getTitle());
//        remoteViews.setTextViewText(R.id.tv_custom_content, message.getContent());
//        remoteViews.setTextViewText(R.id.tv_custom_time, new SimpleDateFormat("HH:mm").format(new Date()));
//

        Notification notification = new NotificationCompat.Builder(context, "chaofun")
                .setContent(remoteViews)
                .setChannelId("chaofun")
                .setContentTitle(message.getTitle())
                .setContentText(message.getContent())
                .setSmallIcon(R.mipmap.ic_launcher)
                .setDefaults(Notification.DEFAULT_VIBRATE)
                .setPriority(Notification.PRIORITY_DEFAULT)
                .build();


//        notification.contentIntent = buildClickContent(context, message);
//        notification.deleteIntent = buildDeleteContent(context, message);
        notificationManager.notify(message.hashCode(), notification);
    }

//    public PendingIntent buildClickContent(Context context, CPushMessage message) {
//        Intent clickIntent = new Intent();
//        clickIntent.setAction("your notification click action");
//        //添加其他数据
//        clickIntent.putExtra("message key",  message);//将message放入intent中，方便通知自建通知的点击事件
//        return PendingIntent.getService(context, clickNotificationCode, clickIntent, PendingIntent.FLAG_UPDATE_CURRENT);
//    }
//    public PendingIntent buildDeleteContent(Context context, CPushMessage message) {
//        Intent deleteIntent = new Intent();
//        deleteIntent.setAction("your notification click action");
//        //添加其他数据
//        deleteIntent.putExtra("message key",  message);//将message放入intent中，方便通知自建通知的点击事件
//        return PendingIntent.getService(context, clickNotificationCode, deleteIntent, PendingIntent.FLAG_UPDATE_CURRENT);
//    }

}