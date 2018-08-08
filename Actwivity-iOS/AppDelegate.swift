//
//  AppDelegate.swift
//  Actwivity-iOS
//
//  Created by Tommy Yang on 7/23/18.
//  Copyright © 2018 tOmMyanG. All rights reserved.
//

import os.log
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        self.registerForPushNotifications()
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleNotification(notification)
        }
        return true
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

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            guard granted else {
                os_log(.error, "Permission not granted: %{public}@", error?.localizedDescription ?? "")
                return }

            // let quoteCat = UNNotificationCategory(identifier: "QUOTE", actions: [], intentIdentifiers: [], options: [])

            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            os_log(.info, "Notification settings: %{public}@", settings.description)
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        let token = tokenParts.joined()
        os_log(.info, "Device Token: %@", token)
        ActwivityCore.sendDeviceTokenToServer(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log(.error, "Failed to register: %{public}@", error.localizedDescription)
    }

    func handleNotification(_ userInfo: [String : Any]) {
        let action_type = userInfo["action_type"] as? String
        let source_user = userInfo["source_user"] as? String
        let target_user = userInfo["target_user"] as? String
        guard let actionType = action_type else {
            os_log(.error, "failed to unwrap actionType")
            return
        }
        guard let sourceUser = source_user else {
            os_log(.error, "failed to unwrap sourceUser")
            return
        }
        guard let targetUser = target_user else {
            os_log(.error, "failed to unwrap targetUser")
            return
        }
        let tweet_id = userInfo["tweet_id"] as? String
        switch actionType {
        case ActionType.QUOTE.rawValue, ActionType.REPLY.rawValue:
            guard let tweetID = tweet_id else {
                os_log(.error, "failed to unwrap tweetID")
                return
            }
            TweetbotLauncher.openToStatus(id: tweetID, from: targetUser)
        case ActionType.REPLY.rawValue, ActionType.FAV.rawValue, ActionType.FOLLOW.rawValue:
            TweetbotLauncher.openToProfile(of: sourceUser, from: targetUser)
        case ActionType.DM.rawValue:
            TweetbotLauncher.openToDirectMessagesScreen(of: targetUser)
        default:
            os_log(.error, "unknown action type %{public}@", actionType)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            self.handleNotification(userInfo)
        }
        completionHandler()
    }
}
