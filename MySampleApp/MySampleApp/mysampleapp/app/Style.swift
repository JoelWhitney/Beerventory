//
//  Style.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/14/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

class Style {
    let style_id: String
    let style_name: String
    let category_id: String
    let category_name: String
    
    init(style_id: String, style_name: String, category_id: String, category_name: String) {
        self.style_id = style_id
        self.style_name = style_name
        self.category_id = category_id
        self.category_name = category_name
    }
    
}
