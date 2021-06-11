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
    @objc dynamic var date = Item.createDateObject(year: 2020, month: 6, day: 11)
    @objc dynamic var dateSecond = Item.createDateObject(year: 2020, month: 6, day: 11).timeIntervalSince1970
    @objc dynamic var photoImage = Data()
    @objc dynamic var name = ""
    @objc dynamic var price = ""
    @objc dynamic var beforeImpression = ""
    @objc dynamic var afterImpression = ""
    @objc dynamic var beforeRating = 0
    @objc dynamic var afterRating = 0
    @objc dynamic var isReEvaluation = false
    @objc dynamic var isCompletedEvaluation = false
    
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
    
    // テスト用。日付を指定したDateオブジェクトを作成
    static func createDateObject(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let comp = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: comp)!
    }
}

