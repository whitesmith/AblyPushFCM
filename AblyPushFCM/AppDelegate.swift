//
//  AppDelegate.swift
//  AblyPushFCM
//
//  Created by Ricardo Pereira on 06/06/2019.
//  Copyright © 2019 Whitesmith. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import Ably

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realtime: ARTRealtime!

    #if DEBUG
    static let AblyKey = "<key>"
    #else
    static let AblyKey = "<key>"
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options = ARTClientOptions(key: AppDelegate.AblyKey)
        options.clientId = UIDevice.current.identifierForVendor!.uuidString
        realtime = ARTRealtime(options: options)

        FirebaseApp.configure()
        Firebase.Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        requestPushNotificationPermissions()

        realtime.push.activate()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexString = deviceToken.map({ String(format: "%02.2hhx", $0) }).joined()
        print("RemoteNotificationsWithDeviceToken", hexString, deviceToken.base64EncodedString())

        // Firebase (disable method swizzling by adding the flag 'FirebaseAppDelegateProxyEnabled' in the app’s Info.plist file and setting it to NO (boolean value).)
        Firebase.Messaging.messaging().apnsToken = deviceToken

        // Ably
        ARTPush.didRegisterForRemoteNotifications(withDeviceToken: deviceToken, realtime: realtime)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("RegisterForRemoteNotificationsWithError", error)

        // Ably
        ARTPush.didFailToRegisterForRemoteNotificationsWithError(error, realtime: realtime)
    }

    private func requestPushNotificationPermissions() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
        UNUserNotificationCenter.current().requestAuthorization(
            options: options,
            completionHandler: { granted, error in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        )
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Tell the app that we have finished processing the user’s action (eg: tap on notification banner) / response
        // Handle received remoteNotification: 'response.notification.request.content.userInfo'
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification alert (banner)
        completionHandler([.alert, .sound])
    }

}

extension AppDelegate: MessagingDelegate {

    /**
     This method is called generally once per app start with registration token. When this method is called, it is the ideal time to:

     ● If the registration token is new, send it to your application server.
     ● Subscribe the registration token to topics.

     This is required only for new subscriptions or for situations where the user has re-installed the app.

     Alternatively, you can listen for an NSNotification named kFIRMessagingRegistrationTokenRefreshNotification rather than supplying a delegate method.
     */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("ReceiveRegistrationToken", fcmToken)
    }

}

extension AppDelegate: ARTPushRegistererDelegate {

    func didActivateAblyPush(_ error: ARTErrorInfo?) {
        print("Ably Push Activation:", error ?? "no error")
    }

    func didDeactivateAblyPush(_ error: ARTErrorInfo?) {
        print("Ably Push Deactivation:", error ?? "no error")
    }

}
