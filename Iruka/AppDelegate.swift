//
//  AppDelegate.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/10.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // notification center
        let center = UNUserNotificationCenter.current()
        
        // ユーザに通知の許可を求める
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Allowd")
            } else {
                print("Didn't allowed")
            }
        }
        
        return true
    }
    
    // SceneDelegateを使わないため関連するメソッドを削除
}

