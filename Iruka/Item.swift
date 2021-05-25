//
//  ItemData.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/18.
//

import UIKit
import RealmSwift

class Item: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var date = ""
    @objc dynamic var dateSecond: Double = 0
    @objc dynamic var photoImage = Data()
    @objc dynamic var name = ""
    @objc dynamic var price = ""
    @objc dynamic var impression = ""
    @objc dynamic var rating = 0
    @objc dynamic var isReEvaluation = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // 日付を時間なしの文字列に変換
    static func convertDateIntoString(date: Date) -> String {
        let datefomatter = DateFormatter()
        datefomatter.dateStyle = .long
        datefomatter.timeStyle = .none
        datefomatter.locale = Locale(identifier: "ja_JP")
        return datefomatter.string(from: date)
    }
    // 日付を1970年からの経過時間（秒）に変換
    static func convertDateIntoDouble(date: Date) -> Double {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let truncateDay = calendar.date(from: comps)
        return truncateDay!.timeIntervalSince1970
    }
}

