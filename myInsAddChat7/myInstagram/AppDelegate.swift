//
//  AppDelegate.swift
//  myInstagram
//
//  Created by XIN LIU on 1/6/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Crashlytics
import Fabric
import UserNotifications
import TWMessageBarManager


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        Fabric.sharedSDK().debug = true
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]){ (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        return true
    }
    
    
    //MARK --> push notification delegate method
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //device token will not change. not
        let varAvgvalue = String(format: "%@", deviceToken as CVarArg)
        let token = varAvgvalue.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        print(token)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
    
        guard let uid = userInfo["gcm.notification.sender"] as? String
            else { return }
        
        let state = UIApplication.shared.applicationState.rawValue
        if state == 1{
            //background
            goToChat(receiveId: uid)
        }else{
            //foreground
            
            let alertController = UIAlertController(title: "News", message: "You got a new message", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Go to chat screen", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.goToChat(receiveId: uid)
            }
            let cancelAction = UIAlertAction(title: "Stay in current screen", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
           // window?.rootViewController = mainTabCont
            window?.windowLevel = UIWindowLevelAlert + 1
            DispatchQueue.main.async {
                self.window?.makeKeyAndVisible()
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    func goToChat(receiveId : String){
        window = UIWindow(frame: UIScreen.main.bounds)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainTabCont = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabViewController
        
        let newSb = UIStoryboard(name: "Reusable", bundle: nil)
        let controller = newSb.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        controller?.receiverId = receiveId
        let nav = sb.instantiateViewController(withIdentifier: "ChatNavigation") as? ChatNavViewController
        nav?.pushViewController(controller!, animated: true)
        mainTabCont?.selectedIndex = 4
        
        var controllers = mainTabCont?.viewControllers
        controllers![4] = nav!
        mainTabCont?.viewControllers = controllers
        window?.rootViewController = mainTabCont
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

