//
//  Order.swift
//  Restaurant
//
//  Created by Wessel Mel on 05/12/2018.
//

import UIKit

struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
