//
//  PushNotificationHandler.swift
//  PushNotificationTemplate
//
//  Created by Junio Moquiuti on 05/06/19.
//  Copyright © 2019 Junio Moquiuti. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

/**
 https://developer.apple.com/documentation/uikit/uiapplication/state
 UIApplication.State
 active      - App in foreground and received a new push
 background  - Enter in the app and have a new pending notification center
 inactive    - Enter notification outside the app
 **/

extension Notification.Name {

    static let didReceiveRemoteNotification = Notification.Name("didReceiveRemoteNotification")
}

protocol PushNotificationHandlerProtocol {

    func requestPushNotification()
    func removeAllDeliveredNotifications()
    func removeDeliveredNotifications(withIdentifiers: [String])
    func managePushNotificationWith(userInfo: [AnyHashable: Any], applicationState: UIApplication.State)
}

class PushNotificationHandler: NSObject {

    static let shared: PushNotificationHandlerProtocol = PushNotificationHandler()
}

// MARK: PushNotificationHandlerProtocol
extension PushNotificationHandler: PushNotificationHandlerProtocol {

    func requestPushNotification() {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, _) in }

        UIApplication.shared.registerForRemoteNotifications()
    }

    func removeAllDeliveredNotifications() {

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func removeDeliveredNotifications(withIdentifiers: [String]) {

        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: withIdentifiers)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: withIdentifiers)
    }

    func managePushNotificationWith(userInfo: [AnyHashable: Any], applicationState: UIApplication.State) {
        guard let notificationData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted) else { return }
        guard let notification = try? JSONDecoder().decode(PushNotification.self, from: notificationData) else { return }

        NotificationCenter.default.post(name: .didReceiveRemoteNotification, object: notification)
    }
}

// MARK: UNUserNotificationCenterDelegate
extension PushNotificationHandler: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        managePushNotificationWith(userInfo: notification.request.content.userInfo, applicationState: UIApplication.shared.applicationState)

        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if UIApplication.shared.applicationState == .active {
            // MARK: - Force send correct state, bacause user did tap in alert when banner is showing with app in background.
            managePushNotificationWith(userInfo: response.notification.request.content.userInfo, applicationState: .inactive)

        } else {
            managePushNotificationWith(userInfo: response.notification.request.content.userInfo, applicationState: UIApplication.shared.applicationState)

        }

        completionHandler()
    }
}
