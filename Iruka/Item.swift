//
//  ItemData.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/18.
//

import UIKit
import RealmSwift

class Item: Object {
    
    @objc dynamic var registrationTime = ""
    @objc dynamic var photoImage = Data()
    @objc dynamic var name = ""
    @objc dynamic var price = ""
    @objc dynamic var impression = ""
    @objc dynamic var rating = 0
    
    
    /*
    struct PropertyKey {
        static let registrationTime = "registrationTime"
        static let photoImage = "photoImage"
        static let name = "name"
        static let price = "price"
        static let impression = "impression"
        static let rating = "rating"
    }
     */
    
    
}

