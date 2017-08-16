//
//  Category.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/18/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation

class Category {
    let category_id: String
    let category_name: String
    var styles = [Style]()
    
    init(category_id: String, category_name: String) {
        self.category_id = category_id
        self.category_name = category_name
    }
    
}
