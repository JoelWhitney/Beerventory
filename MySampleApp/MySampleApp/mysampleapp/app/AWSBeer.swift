//
//  AWSBeer.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/15/17.
//

import Foundation
import UIKit
import AWSDynamoDB
import SwiftyJSON

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
    
    func returnBeerObject() -> Beer {
        let beerResult = JSON(self._beer)
        let beerResultObject = Beer(brewerydb_id: beerResult["brewerydb_id"].string! ,
                                    upc_code: beerResult["upc_code"].string ?? "" ,
                                    name: beerResult["name"].string ?? "" ,
                                    beer_description: beerResult["beer_description"].string ?? "",
                                    abv: beerResult["abv"].string ?? "--" ,
                                    label: beerResult["label"].string ?? "" ,
                                    gravity: beerResult["gravity"].string ?? "--" ,
                                    availability: beerResult["availability"].string ?? "" ,
                                    availability_desc: beerResult["available_desc"].string ?? "" ,
                                    style_name: beerResult["style_name"].string ?? "" ,
                                    style_desc: beerResult["style_desc"].string ?? "" ,
                                    style_id: beerResult["style_id"].string ?? "" )
        beerResultObject.brewery_id = beerResult["brewery_id"].string ?? ""
        beerResultObject.brewery_name = beerResult["brewery_name"].string ?? ""
        beerResultObject.quantity = Int(beerResult["quantity"].string!)!
        return beerResultObject
    }
}
