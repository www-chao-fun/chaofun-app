import UIKit
import Flutter
import CloudPushSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let emasAppKey = "31232924"
    let emasAppSecret = "9b8f5bcfdad62aee21ce7fd6941bbe78"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerAPNs(application)
        // 初始化阿里云推送SDK
        initCloudPushSDK()
        // 监听推送通道打开动作
        listenOnChannelOpened()
        // 监听推送消息到达
        registerMessageReceive()
        // 点击通知将App从关闭状态启动时，将通知打开回执上报
//        CloudPushSDK.handleLaunching(launchOptions)(Deprecated from v1.8.1)
        CloudPushSDK.sendNotificationAck(launchOptions)

        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let pushBindChannel = FlutterMethodChannel(name: "app.chao.fun/main_channel",
                                                   binaryMessenger: controller.binaryMessenger)
        
        pushBindChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            
            if (call.method == "getDeviceInfo") {
                var bindInfo = [String: String]()
                bindInfo["deviceId"] = CloudPushSDK.getDeviceId();
                bindInfo["appKey"] = self?.emasAppKey;
                
                result(bindInfo);
            } else if (call.method == "share") {
                self?.socialShare(shareObject: call.arguments)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        
        initUM()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func openNotification(optionsMap: [AnyHashable : Any]) {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let pushBindChannel = FlutterMethodChannel(name: "app.chao.fun/main_channel",
                                                          binaryMessenger: controller.binaryMessenger)
        
        pushBindChannel.invokeMethod("push", arguments: optionsMap);
        
    }
    
    func socialShare(shareObject: Any?) {
        
        if var newObject: NSMutableDictionary = shareObject as? NSMutableDictionary {
            
            let imageBaseUrl = "https://i.chao.fun/"
            
            let postBaseUrl = "https://chao.fun/p/"
            
            UMSocialUIManager.showShareMenuViewInWindow { (platform, dataMap) in
                var shareObject: UMShareObject? = nil;
                let  messageObject = UMSocialMessageObject();
                // 小程序
                if (platform == UMSocialPlatformType.wechatSession  && (newObject["type"] as? String == "image" || newObject["type"] as? String == "gif" || newObject["type"] as? String == "article" || newObject["type"] as? String == "forward" || newObject["type"] as? String == "vote")) {
                    shareObject = UMShareMiniProgramObject.shareObject(withTitle: newObject["title"] as? String, descr: "炒饭 - 分享奇趣、发现世界", thumImage: "") as! UMShareObject
                    (shareObject as! UMShareMiniProgramObject).path = "/pages/detail/detail?postId=" + String(newObject["postId"] as! Int);
                    (shareObject as! UMShareMiniProgramObject).webpageUrl = "https://chao.fun/p/" + String(newObject["postId"] as! Int);
                    (shareObject as! UMShareMiniProgramObject).userName = "gh_41eb4fc2a95b";
                    (shareObject as! UMShareMiniProgramObject).miniProgramType = UShareWXMiniProgramType.release;
                    
                    do {
                        var urlString: String? = nil;
                        if (!(newObject["cover"] is NSNull)) {
                            urlString = imageBaseUrl + (newObject["cover"] as! String)
                        } else if (!(newObject["imageName"] is NSNull)) {
                            (shareObject as! UMShareMiniProgramObject).thumbImage =  imageBaseUrl + (newObject["imageName"] as! String)
                            urlString = imageBaseUrl + (newObject["imageName"] as! String)
                        } else { 
                            urlString = imageBaseUrl + "9563cdd828d2b674c424b79761ccb4c0.png"
                        }
                        let url = URL(string: urlString!)
                        let data = try Data(contentsOf: url!)
                        (shareObject as! UMShareMiniProgramObject).hdImageData = self.compressImageTo(image: UIImage.init(data: data)!, expectedSizeInKB: 120)
                    } catch {
                        print(error)
                    }
                } else {
                    
                    var title = ""
                    
                    if (!(newObject["title"] is NSNull)) {
                        title = newObject["title"] as! String;
                    }
                    if (platform == UMSocialPlatformType.sina) {
                        shareObject = UMShareImageObject.shareObject(withTitle: newObject["title"] as? String, descr: "", thumImage: "")
                    
                        if (!(newObject["imageName"] is NSNull)) {
                            (shareObject as! UMShareImageObject).shareImage = imageBaseUrl + (newObject["imageName"] as! String);
                        }
                        if (!(newObject["postId"] is NSNull)) {
                            messageObject.text =  title.prefix(100) + " 分享自炒饭: " + postBaseUrl + String(newObject["postId"] as! Int)  + " @炒饭社区"
                        }
                    } else if (newObject["type"] as? String == "link") {
                        shareObject = UMShareWebpageObject.shareObject(withTitle: newObject["title"] as! String, descr: "", thumImage:  nil);
                        
                        (shareObject as! UMShareWebpageObject).webpageUrl = newObject["link"] as? String;
                    }  else {
                        shareObject = UMShareWebpageObject.shareObject(withTitle: newObject["title"] as! String, descr: "", thumImage:  nil);
                             
                        if (!(newObject["cover"] is NSNull)) {
                            (shareObject as! UMShareWebpageObject).thumbImage  = imageBaseUrl + (newObject["cover"] as! String)
                        } else if (!(newObject["imageName"] is NSNull)) {
                            (shareObject as! UMShareWebpageObject).thumbImage = imageBaseUrl + (newObject["imageName"] as! String)
                        } else {
                            (shareObject as! UMShareWebpageObject).thumbImage = imageBaseUrl + "9563cdd828d2b674c424b79761ccb4c0.png"
                        }
                        
                        (shareObject as! UMShareWebpageObject).webpageUrl = postBaseUrl + String(newObject["postId"] as! Int);
                    }
                    
                    
                }
                
                if (!(newObject["cover"] is NSNull)) {
                    shareObject?.thumbImage = imageBaseUrl + (newObject["cover"] as! String);
                }
                    
            
                messageObject.shareObject = shareObject;
               
                    
                UMSocialManager.default()?.share(to: platform, messageObject: messageObject, currentViewController: nil, completion: { (data, error) in
                    print(error);
                });
            }
            
        }
        
        print("123");
        
    }
    
    func initUM() {
        UMCommonLogManager.setUp()
        UMAnalyticsSwift.init();

        UMSocialGlobal.shareInstance()?.universalLinkDic = [UMSocialPlatformType.QQ.rawValue : "https://chao.fun/qq_conn/101935770"]
        UMSocialGlobal.shareInstance()?.universalLinkDic = [UMSocialPlatformType.wechatSession.rawValue : "https://chao.fun/"]
        UMSocialGlobal.shareInstance()?.universalLinkDic = [UMSocialPlatformType.sina.rawValue : "https://chao.fun/"]

        UMCommonSwift.setLogEnabled(bFlag: true)
        UMCommonSwift.initWithAppkey(appKey: "5f7ea1ae80455950e49e063d", channel: "App Store")

        WXApi.registerApp("wx301447e1e7833b29", universalLink: "https://chao.fun/")

        UMSocialManager.default()?.setPlaform(UMSocialPlatformType.wechatSession, appKey: "wx301447e1e7833b29", appSecret: "d108db12d305e28f9aa8e40396a4a14b", redirectURL: "https://www.umeng.com/social")

        UMSocialManager.default()?.setPlaform(UMSocialPlatformType.QQ, appKey: "101935770", appSecret: "85fda2250376ca4a7a778a3be0088e53", redirectURL: "https://chao.fun/qq_conn/101935770")

        UMSocialManager.default()?.setPlaform(UMSocialPlatformType.dingDing, appKey: "dingoaas7n1scswrel4kyq", appSecret: "10DpFvqEBWY2IjkBqUEGFWZaTKXrvQW_ghjPmGB9qgfbNCxWftLsLAXiVG5bGnaR", redirectURL: "https://chao.fun/")

        UMSocialManager.default()?.setPlaform(UMSocialPlatformType.sina, appKey: "1791909991", appSecret: "bdf690e90dab45bc2fa832417edd3762", redirectURL: "https://chao.fun/")
//
//        print("123");
    }
    
    // 向APNs注册，获取deviceToken用于推送
    func registerAPNs(_ application: UIApplication) {
        if #available(iOS 10, *) {
            // iOS 10+
            let center = UNUserNotificationCenter.current()
            // 创建category，并注册到通知中心
            createCustomNotificationCategory()
            center.delegate = self
            // 请求推送权限
            center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                if (granted) {
                    // User authored notification
                    print("User authored notification.")
                    // 向APNs注册，获取deviceToken
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    // User denied notification
                    print("User denied notification.")
                }
            })
        } else if #available(iOS 8, *) {
            // iOS 8+
            application.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            // < iOS 8
            application.registerForRemoteNotifications(matching: [.alert,.badge,.sound])
        }
    }
    
    // 创建自定义category，并注册到通知中心
    @available(iOS 10, *)
    func createCustomNotificationCategory() {
        let action1 = UNNotificationAction.init(identifier: "action1", title: "test1", options: [])
        let action2 = UNNotificationAction.init(identifier: "action2", title: "test2", options: [])
        let category = UNNotificationCategory.init(identifier: "test_category", actions: [action1, action2], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // 初始化推送SDK
    func initCloudPushSDK() {
        // 打开Log，线上建议关闭
        CloudPushSDK.turnOnDebug()
        
        CloudPushSDK.asyncInit(emasAppKey, appSecret: emasAppSecret) { (res) in
            if (res!.success) {
                print("Push SDK init success, deviceId: \(CloudPushSDK.getDeviceId()!)")
            } else {
                print("Push SDK init failed, error: \(res!.error!).")
            }
        }
    }
    
    // 监听推送通道是否打开
    func listenOnChannelOpened() {
        let notificationName = Notification.Name("CCPDidChannelConnectedSuccess")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(channelOpenedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    
    @objc func channelOpenedFunc(notification : Notification) {
        print("Push SDK channel opened.")
    }
    
    // 注册消息到来监听
    func registerMessageReceive() {
        let notificationName = Notification.Name("CCPDidReceiveMessageNotification")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMessageReceivedFunc(notification:)),
                                               name: notificationName,
                                               object: nil)
    }
    
    // 处理推送消息
    @objc func onMessageReceivedFunc(notification : Notification) {
        print("Receive one message.")
        let pushMessage: CCPSysMessage = notification.object as! CCPSysMessage
        let title = String.init(data: pushMessage.title, encoding: String.Encoding.utf8)
        let body = String.init(data: pushMessage.body, encoding: String.Encoding.utf8)
        print("Message title: \(title!), body: \(body!).")
    }
    
    // App处于启动状态时，通知打开回调（< iOS 10）
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive one notification.")
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        let alert = aps["alert"] ?? "none"
        let badge = aps["badge"] ?? 0
        let sound = aps["sound"] ?? "none"
        let extras = userInfo["Extras"]
        // 设置角标数为0
        application.applicationIconBadgeNumber = 0;
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, alert: \(alert), badge: \(badge), sound: \(sound), extras: \(String(describing: extras)).")
    }
    
    // 处理iOS 10通知(iOS 10+)
    @available(iOS 10.0, *)
    func handleiOS10Notification(_ notification: UNNotification) {
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo
        // 通知时间
        let noticeDate = notification.date
        // 标题
        let title = content.title
        // 副标题
        let subtitle = content.subtitle
        // 内容
        let body = content.body
        // 角标
        let badge = content.badge ?? 0
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        let extras = userInfo["Extras"]
        // 设置角标数为0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        // 通知打开回执上报
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, date: \(noticeDate), title: \(title), subtitle: \(subtitle), body: \(body), badge: \(badge), extras: \(String(describing: extras)).")
    }
    
    // App处于前台时收到通知(iOS 10+)
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Receive a notification in foreground.")
        handleiOS10Notification(notification)
        // 通知不弹出
//        completionHandler([])
        // 通知弹出，且带有声音、内容和角标
        completionHandler([.alert, .badge, .sound])
    }
    
    // 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    @available(iOS 10, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userAction = response.actionIdentifier
        if userAction == UNNotificationDefaultActionIdentifier {
            print("User opened the notification.")
            // 处理iOS 10通知，并上报通知打开回执
            handleiOS10Notification(response.notification)
            
            // 打开通知
            
            
            openNotification(optionsMap: response.notification.request.content.userInfo);
        }
        
        if userAction == UNNotificationDismissActionIdentifier {
            print("User dismissed the notification.")
        }
        
        let customAction1 = "action1"
        let customAction2 = "action2"
        if userAction == customAction1 {
            print("User touch custom action1.")
        }
        
        if userAction == customAction2 {
            print("User touch custom action2.")
        }
        
        completionHandler()
    }
    
    /* 同步角标数到服务端 */
    func syncBadgeNum(_ badgeNum: UInt) {
        CloudPushSDK.syncBadgeNum(badgeNum) { (res) in
            if (res!.success) {
                print("Sync badge num: [\(badgeNum)] success")
            } else {
                print("Sync badge num: [\(badgeNum)] failed, error: \(String(describing: res?.error))")
            }
        }
    }
    
    override func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let result = UMSocialManager.default()?.handleOpen(url);
        return result ?? true;
    }
    
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let result = UMSocialManager.default()?.handleUniversalLink(userActivity, options: nil);
        return result ?? true;
    }
    
    // APNs注册成功
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Get deviceToken from APNs success.")
        CloudPushSDK.registerDevice(deviceToken) { (res) in
            if (res!.success) {
                print("Upload deviceToken to Push Server, deviceToken: \(CloudPushSDK.getApnsDeviceToken()!)")
            } else {
                print("Upload deviceToken to Push Server failed, error: \(String(describing: res?.error))")
            }
        }
    }
    
    // APNs注册失败
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Get deviceToken from APNs failed, error: \(error).")
    }
    
    // 禁止横屏
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait;
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func compressImageTo(image: UIImage, expectedSizeInKB:Int) -> Data? {
        let sizeInBytes = expectedSizeInKB * 1024
        var needCompress:Bool = true
        var compressingValue:CGFloat = 0.3
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = image.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    return data;
                } else {
                    compressingValue -= 0.1;
                }
            }
        }
        return nil;
    }
}
