//
//  ItemData.swift
//  Iruka
//
//  Created by kudo koki on 2021/04/18.
//

import UIKit
import RealmSwift

class Item: Object {
    
    @objc dynamic var registrationTime: String
    @objc dynamic var photoImage: UIImage
    @objc dynamic var name: String
    @objc dynamic var price: String
    @objc dynamic var impression: String
    @objc dynamic var rating: Int
    
    
    struct PropertyKey {
        static let registrationTime = "registrationTime"
        static let photoImage = "photoImage"
        static let name = "name"
        static let price = "price"
        static let impression = "impression"
        static let rating = "rating"
    }
    
    init(registrationTime: String, photoImage: UIImage, name: String, price: String, impression: String, rating: Int) {
        
        self.registrationTime = registrationTime
        self.photoImage = photoImage
        self.name = name
        self.price = price
        self.impression = impression
        self.rating = rating
    }
    
    
}

