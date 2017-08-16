//
//  AWSBeer.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/15/17.
//

import Foundation
import UIKit
import AWSDynamoDB

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
}
