//
//  ModelController.swift
//  MyLocations
//
//  Created by 123 on 03.12.17.
//  Copyright © 2017 123. All rights reserved.
//

import UIKit

struct Category {
    var name: String
    var isChecked = false
}

class ModelController: NSObject {
    
    var categories: [Category] = [Category(name: "No Category", isChecked: false),
                                  Category(name: "Apple Store", isChecked: false),
                                  Category(name: "Bar", isChecked: false),
                                  Category(name: "Bookstore", isChecked: false),
                                  Category(name: "Club", isChecked: false),
                                  Category(name: "Grocery Store", isChecked: false),
                                  Category(name: "Histoic Building", isChecked: false),
                                  Category(name: "House", isChecked: false),
                                  Category(name: "Icecreame Vendor", isChecked: false),
                                  Category(name: "Landmark", isChecked: false),
                                  Category(name: "Park", isChecked: false)]
}



















