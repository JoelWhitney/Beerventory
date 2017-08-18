//
//  Beer.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit
import SwiftyJSON
import AWSDynamoDB
import AWSMobileHubHelper

class Beer: NSObject, NSCoding {
    // MARK: - variables/constants
    // my shit
    let dateAdded: Date
    let itemKey: String
    //let expiration_days: Int
    
    // brewerydb info
    //var beer_details_json = [String: JSON]()
    var brewerydb_id: String
    var upc_code: String
    var name: String
    var beer_description: String
    var abv: String
    var label: String
    var gravity: String
    var availability: String
    var availability_desc: String
    var style_name: String
    var style_desc: String
    
    // extra call info
    var brewery_id = ""
    var brewery_name = ""
    var style_id = ""
    
    // inventory info
    var quantity = 0

    // MARK: - initializers
    // used from scan
    init(brewerydb_id: String, upc_code: String, name: String, beer_description: String, abv: String,
        label: String, gravity: String, availability: String, availability_desc: String,
        style_name: String, style_desc: String, style_id: String) {
        // my shit
        self.dateAdded = Date()
        self.itemKey = UUID().uuidString
        // brewerydb info
        self.brewerydb_id = brewerydb_id
        self.upc_code = upc_code
        self.name = name
        self.beer_description = beer_description
        self.abv = abv
        self.label = label
        self.gravity = gravity
        self.availability = availability
        self.availability_desc = availability_desc
        self.style_name = style_name
        self.style_desc = style_desc
        self.style_id = style_id
        super.init()
    }
    convenience override init() {
        self.init(brewerydb_id: "", upc_code: "", name: "", beer_description: "", abv: "",
                  label: "", gravity: "", availability: "", availability_desc: "",
                  style_name: "", style_desc: "", style_id: "")
    }
    required init(coder aDecoder: NSCoder) {
        // my shit
        dateAdded = aDecoder.decodeObject(forKey: "dateAdded") as! Date
        itemKey = aDecoder.decodeObject(forKey: "itemKey") as! String
        // brewerydb info
        //beer_details_json = aDecoder.decodeObject(forKey: "beer_details_json") as! [String: JSON]
        brewerydb_id = aDecoder.decodeObject(forKey: "brewerydb_id") as! String
        upc_code = aDecoder.decodeObject(forKey: "upc_code") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        beer_description = aDecoder.decodeObject(forKey: "beer_description") as! String
        abv = aDecoder.decodeObject(forKey: "abv") as! String
        label = aDecoder.decodeObject(forKey: "label") as! String
        gravity = aDecoder.decodeObject(forKey: "gravity") as! String
        availability = aDecoder.decodeObject(forKey: "availability") as! String
        availability_desc = aDecoder.decodeObject(forKey: "availability_desc") as! String
        style_name = aDecoder.decodeObject(forKey: "style_name") as! String
        style_id = aDecoder.decodeObject(forKey: "style_id") as! String
        style_desc = aDecoder.decodeObject(forKey: "style_desc") as! String
        brewery_id = aDecoder.decodeObject(forKey: "brewery_id") as! String
        brewery_name = aDecoder.decodeObject(forKey: "brewery_name") as! String
        quantity = aDecoder.decodeInteger(forKey: "quantity")
        super.init()

    }
    
    // MARK: - class methods
    func encode(with aCoder: NSCoder) {
        // my shit
        aCoder.encode(dateAdded, forKey: "dateAdded")
        aCoder.encode(itemKey, forKey: "itemKey")
        // brewerydb info
        //aCoder.encode(beer_details_json, forKey: "beer_details_json")
        aCoder.encode(brewerydb_id, forKey: "brewerydb_id")
        aCoder.encode(upc_code, forKey: "upc_code")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(beer_description, forKey: "beer_description")
        aCoder.encode(abv, forKey: "abv")
        aCoder.encode(label, forKey: "label")
        aCoder.encode(gravity, forKey: "gravity")
        aCoder.encode(availability, forKey: "availability")
        aCoder.encode(availability_desc, forKey: "availability_desc")
        aCoder.encode(style_name, forKey: "style_name")
        aCoder.encode(style_id, forKey: "style_id")
        aCoder.encode(style_desc, forKey: "style_desc")
        aCoder.encode(brewery_id, forKey: "brewery_id")
        aCoder.encode(brewery_name, forKey: "brewery_name")
        aCoder.encode(quantity, forKey: "quantity")
    }
    
    func beerObjectMap() -> [String: String] {
        let mirrored_object = Mirror(reflecting: self)
        var beerMap = [String: String]()
        for (index, attr) in mirrored_object.children.enumerated() {
            if attr.label != "dateAdded" && attr.label != "itemKey" {
                let key = attr.label
                var value = "\(attr.value)"
                if value == "" {
                    value = "null"
                }
                beerMap[key!] = value
            }
        }
        return beerMap
    }
    
    func awsBeer() -> AWSBeer {
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = self.brewerydb_id
        itemToCreate._beer = self.beerObjectMap()
        return itemToCreate
    }
    
    func beerObjectDescription() -> String {
        let mirrored_object = Mirror(reflecting: self)
        var attrStrings = [String]()
        for (index, attr) in mirrored_object.children.enumerated() {
            let str:NSMutableString = NSMutableString()
            if let property_name = attr.label as String! {
                str.append("* Attr \(index): \(property_name) = \(attr.value)")
                attrStrings.append(str as String)
            }
        }
        return attrStrings.joined(separator: "\n\n")
    }
    
}



