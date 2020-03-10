//
//  Item.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct Item {
    let itemName: String
    let price: Double
    let itemId: String //documentID
    let listedDate: Date
    let sellerName: String
    let sellerID: String
    let categoryName: String
    let imageURL: String
}

extension Item {
    init(_ dictionary: [String:Any]) {
        //bnasic dictionary query i am looking for a key that has the value
        self.itemName = dictionary["itemName"] as? String ?? " no item name"
        self.price = dictionary["price"] as? Double ?? 0.0
        self.itemId = dictionary["itemId"] as? String ?? " no item here"
        self.listedDate = dictionary["listedDate"] as? Date ?? Date()
        self.sellerName = dictionary["sellerName"] as? String ?? " no seller name"
        self.sellerID = dictionary["sellerID"] as? String ?? " no seller ID"
        self.categoryName = dictionary["categoryName"] as? String ?? " no category name"
        self.imageURL = dictionary["imageURL"] as? String ?? "no image URL"
    }
}
