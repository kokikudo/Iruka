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
    @objc dynamic var registrationTime = ""
    @objc dynamic var photoImage = Data()
    @objc dynamic var name = ""
    @objc dynamic var price = ""
    @objc dynamic var impression = ""
    @objc dynamic var rating = 0
    @objc dynamic var isReEvaluation = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct Implementor {
    let realm = try! Realm()
    let itemObject: Results<Item>
    
    init() {
        itemObject = realm.objects(Item.self)
    }
    
    func select() -> Results<Item> {
        let dateBefore1Year = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        
        let datefomatter = DateFormatter()
        datefomatter.dateStyle = .long
        datefomatter.timeStyle = .none
        datefomatter.locale = Locale(identifier: "ja_JP")
        let formattedDateBefore1Year = datefomatter.string(from: dateBefore1Year)
        let result = itemObject.filter("registrationTime == %@", formattedDateBefore1Year)
        return result
    }
}
