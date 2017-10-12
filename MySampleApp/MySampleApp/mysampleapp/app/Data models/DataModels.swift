//
//  DataModels.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/31/17.
//

import Foundation
import UIKit
import SwiftyJSON
import AWSDynamoDB
import AWSMobileHubHelper


//MARK: - AWSBeer
class AWSBeer: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _beerEntryId: String?
    var _beer: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "beerventory-mobilehub-684623376-Beers"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_beerEntryId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_beerEntryId" : "beerEntryId",
            "_beer" : "beer",
        ]
    }
    
    func beer() -> Beer {
        let beerData = self._beer
        return Beer(beerData: beerData as! [String: String])
    }
}

// MARK: - Beer
class Beer {
    // MARK: - variables/constants
    // my shit
    let dateAdded: Date!
    // brewerydb info
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
    var awsBeer: AWSBeer {
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = self.brewerydb_id
        itemToCreate._beer = self.beerData
        return itemToCreate
    }
    var beerData: [String: String] {
        let mirrored_object = Mirror(reflecting: self)
        var beerMap = [String: String]()
        var value: String!
        for (index, attr) in mirrored_object.children.enumerated() {
            if attr.label == "dateAdded" {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                value = formatter.string(from: attr.value as! Date)
            } else {
                value = "\(attr.value)"

            }
            let key = attr.label
            if value == "" {
                value = "null"
            }
            beerMap[key!] = value
            }
        return beerMap
    }
    
    // MARK: - initializers
    init(beerJSON: JSON) {
        // my shit
        self.dateAdded = Date()
        // brewerydb info
        self.brewerydb_id = beerJSON["id"].string!
        self.upc_code = beerJSON["upc_code"].string ?? ""
        self.name = beerJSON["name"].string ?? ""
        self.beer_description = beerJSON["description"].string ?? ""
        self.abv = beerJSON["abv"].string ?? "--"
        self.label = beerJSON["labels"]["large"].string ?? ""
        self.gravity = beerJSON["style"]["ogMin"].string ?? "--"
        self.availability = beerJSON["availabile"]["name"].string ?? ""
        self.availability_desc = beerJSON["available"]["description"].string ?? ""
        self.style_name = beerJSON["style"]["shortName"].string ?? ""
        self.style_desc = beerJSON["style"]["description"].string ?? ""
        self.style_id = beerJSON["style"]["id"].string ?? ""
        self.brewery_id = beerJSON["breweries"][0]["id"].string ?? ""
        self.brewery_name = beerJSON["breweries"][0]["name"].string ?? ""
    }
    
    init(beerData: [String: String]) {
        //let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        // brewerydb info
        //self.dateAdded = formatter.date(from: beerData["dateAdded"]!)
        self.dateAdded = Date()
        self.brewerydb_id = beerData["brewerydb_id"] ?? ""
        self.upc_code = beerData["upc_code"] ?? ""
        self.name = beerData["name"] ?? ""
        self.beer_description = beerData["beer_description"] ?? ""
        self.abv = beerData["abv"] ?? "--"
        self.label = beerData["label"] ?? ""
        self.gravity = beerData["gravity"] ?? "--"
        self.availability = beerData["availability"] ?? ""
        self.availability_desc = beerData["available_desc"] ?? ""
        self.style_name = beerData["style_name"] ?? ""
        self.style_desc = beerData["style_desc"] ?? ""
        self.style_id = beerData["style_id"] ?? ""
        self.brewery_id = beerData["brewery_id"] ?? ""
        self.brewery_name = beerData["brewery_name"] ?? ""
        self.quantity = Int(beerData["quantity"]!)!
    }
    init() {
        // my shit
        self.dateAdded = Date()
        // brewerydb info
        self.brewerydb_id = ""
        self.upc_code = ""
        self.name = ""
        self.beer_description = ""
        self.abv = ""
        self.label = ""
        self.gravity = ""
        self.availability = ""
        self.availability_desc = ""
        self.style_name = ""
        self.style_desc = ""
        self.style_id = ""
        self.brewery_id = ""
        self.brewery_name =  ""
    }
    
    
    // MARK: - class methods
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

// MARK: - Brewery
class Brewery {
    let brewery_id: String
    let brewery_name: String
    let region: String
    
    init(breweryJSON: JSON) {
        self.brewery_id = breweryJSON["id"].string ?? ""
        self.brewery_name = breweryJSON["name"].string ?? ""
        self.region = breweryJSON["locations"][0]["region"].string ?? ""
    }
    
    init(brewery_id: String, brewery_name: String, region: String) {
        self.brewery_id = brewery_id
        self.brewery_name = brewery_name
        //self.locality = locality
        self.region = region
    }
    
}

// MARK: - Style
class Style {
    let style_id: String
    let style_name: String
    let category_id: String
    let category_name: String
    
    init(styleJSON: JSON) {
        self.style_id = styleJSON["id"].string ?? ""
        self.style_name = styleJSON["name"].string ?? ""
        self.category_id = styleJSON["category"]["id"].string ?? ""
        self.category_name = styleJSON["category"]["name"].string ?? ""
    }
    
    init(style_id: String, style_name: String, category_id: String, category_name: String) {
        self.style_id = style_id
        self.style_name = style_name
        self.category_id = category_id
        self.category_name = category_name
    }
    
}

// MARK: - Category
class Category {
    let category_id: String
    var category_name: String
    var styles = [Style]()
    
    init(categoryJSON: JSON) {
        let category_name = categoryJSON["name"].string ?? ""
        if category_name == "\"\"" {
            self.category_name = "Other"
        } else {
            self.category_name = category_name
        }
        self.category_id = categoryJSON["id"].string ?? ""
    }
    
    init(category_id: String, category_name: String) {
        self.category_id = category_id
        self.category_name = category_name
    }
    
    init(category_id: String, category_name: String, styles: [Style]) {
        self.category_id = category_id
        self.category_name = category_name
        self.styles = styles
    }
}


