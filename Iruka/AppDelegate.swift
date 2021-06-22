//
//  AppDelegate.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/10.
//

import UIKit
import UserNotifications
import Firebase
import GoogleMobileAds
import FirebaseAnalytics
import AppTrackingTransparency
import AdSupport

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
        
        // 初回起動かどうかのBool値をキーとともにUserDefaultsへセット
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        let firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        
        // 広告表示の設定
        // Firebaseに広告をリンクさせているためFirebaseを設定
        FirebaseApp.configure()
        // GoogleAdMobSDKの初期化。ios14以降はユーザーの許可が必要。
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization() { status in
                switch status {
                case .authorized:
                    Analytics.setAnalyticsCollectionEnabled(true)
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                default:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                }
            }
        } else {
            Analytics.setAnalyticsCollectionEnabled(true)
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        
        
        return true
    }
    // SceneDelegateを使わないため関連するメソッドを削除
}

