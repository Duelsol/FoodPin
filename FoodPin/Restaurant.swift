//
//  Restaurant.swift
//  FoodPin
//
//  Created by Duelsol on 15/9/13.
//  Copyright (c) 2015年 Duelsol. All rights reserved.
//

import Foundation
import CoreData

@objc(Restaurant)
class Restaurant: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var location: String
    @NSManaged var image: Data
    @NSManaged var isVisited: Bool

    static var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster", "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery", "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif", "Graham Avenue Meats And Deli", "Waffle & Wolf", "Five Leaves", "Cafe Lore", "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]

    static var restaurantImages = ["cafedeadend.jpg", "homei.jpg", "teakha.jpg", "cafeloisl.jpg", "petiteoyster.jpg", "forkeerestaurant.jpg", "posatelier.jpg", "bourkestreetbakery.jpg", "haighschocolate.jpg", "palominoespresso.jpg", "upstate.jpg", "traif.jpg", "grahamavenuemeats.jpg", "wafflewolf.jpg", "fiveleaves.jpg", "cafelore.jpg", "confessional.jpg", "barrafina.jpg", "donostia.jpg", "royaloak.jpg", "thaicafe.jpg"]

    static var restaurantLocations = ["G/F, 72 Po Hong Kong", "Shop B, G/F, 22-24A Tai Ping San Street SOHO, Sheung Wan, Hong Kong", "SHop B, 18 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", "Shop B, 20 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", "Shop J-K., 200 Hollywood Road, SOHO Shanghai", "Shanghai", "Shanghai", "Sydney", "Sydney", "Sydney", "New York", "New York", "New York", "New York", "New York", "New York", "New York", "London", "London", "London", "London"]

    static var restauranyTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian / Causual Drink", "French", "Bakery", "Bakery", "Chocolate", "Cafe", "American / Seafood", "American", "American", "Breakfast & Brunch", "Coffee & Tea", "Coffee & Tea", "Latin American", "Spanish", "Spanish", "Spanish", "British", "Thai"]

    static var restaurantIsVisited = [Bool](repeating: false, count: 21)

    func make(name: String, type: String, location: String, image: Data, isVisited: Bool) {
        self.name = name
        self.type = type
        self.location = location
        self.image = image
        self.isVisited = isVisited
    }

}
