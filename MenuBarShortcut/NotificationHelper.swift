//
//  NotificationHelper.swift
//  MenuBarShortcut
//
//  Created by Lucas Eiji Saito on 03/03/21.
//  Copyright © 2021 Lucas Eiji Saito. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationHelper {
    
    static func sendNotification(_ text: String) {
        checkAuthorization(allowed: {
            let content = UNMutableNotificationContent()
            content.title = "MenuBarShortcut"
            content.subtitle = text
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("[MenuBarShortcut] NOTIFICATION ERROR - \(error)")
                }
            }
        }) {
            print("[MenuBarShortcut] NOTIFICATION DENIED - \(text)")
        }
    }
    
    static func checkAuthorization(allowed: @escaping () -> Void, failure: (() -> Void)?) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                notificationCenter.requestAuthorization(options: .alert) { (granted, error) in
                    if granted {
                        allowed()
                    } else {
                        failure?()
                    }
                }
            case .authorized:
                allowed()
            default:
                failure?()
            }
        }
    }
}
