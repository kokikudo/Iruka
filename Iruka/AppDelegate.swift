//
//  AppDelegate.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/10.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // SceneDelegateを使わないためAppDelegateにwindowを定義し、SceneDelegateファイルを削除
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // notification center
        let center = UNUserNotificationCenter.current()
        center.delegate = self // デリゲート指定
        
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("通知がタップされました。")
        let oneYearAgoRegistereditem = Implementor()
        let results = oneYearAgoRegistereditem.select()
        
        let tableViewController = ItemTableViewController()
        tableViewController.itemList = results
        
        print(tableViewController.itemList ?? "からのリスト")
        
        completionHandler()
    }
    
    // SceneDelegateを使わないため関連するメソッドを削除
}

