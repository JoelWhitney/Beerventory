//
//  Brewery.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/14/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

class Brewery {
    let brewery_id: String
    let brewery_name: String
    let region: String
    
    init(brewery_id: String, brewery_name: String, region: String) {
        self.brewery_id = brewery_id
        self.brewery_name = brewery_name
        //self.locality = locality
        self.region = region
    }
    
}
