////
////  AWSBeerStore.swift
////  MySampleApp
////
////  Created by Joel Whitney on 8/16/17.
////
//
//import UIKit
//import SwiftyJSON
//import RxSwift
//import RxCocoa
//import AWSDynamoDB
//import AWSMobileHubHelper
//import Foundation
//
//class AWSBeerStore: NSObject, Table {
//    
//    var tableName: String
//    var partitionKeyName: String
//    var partitionKeyType: String
//    var sortKeyName: String?
//    var sortKeyType: String?
//    var model: AWSDynamoDBObjectModel
//    var indexes: [Index]
//    var orderedAttributeKeys: [String] {
//        return produceOrderedAttributeKeys(model)
//    }
//    var tableDisplayName: String {
//        
//        return "Beers"
//    }
//    
//    override init() {
//        
//        model = Beers()
//        
//        tableName = model.classForCoder.dynamoDBTableName()
//        partitionKeyName = model.classForCoder.hashKeyAttribute()
//        partitionKeyType = "String"
//        indexes = [
//            
//            BeersPrimaryIndex()
//        ]
//        if let sortKeyNamePossible = model.classForCoder.rangeKeyAttribute?() {
//            sortKeyName = sortKeyNamePossible
//            sortKeyType = "String"
//        }
//        super.init()
//    }
//    
//    /**
//     * Converts the attribute name from data object format to table format.
//     *
//     * - parameter dataObjectAttributeName: data object attribute name
//     * - returns: table attribute name
//     */
//    
//    func tableAttributeName(_ dataObjectAttributeName: String) -> String {
//        return Beers.jsonKeyPathsByPropertyKey()[dataObjectAttributeName] as! String
//    }
//    
//    func insertBeerWithCompletionHandler(beer: Beer, _ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        var errors: [NSError] = []
//        let group: DispatchGroup = DispatchGroup()
//        
//        // let numberOfObjects = 20
//        
//        let itemForGet: AWSBeer! = AWSBeer()
//        itemForGet._userId = AWSIdentityManager.default().identityId!
//        itemForGet._beerEntryId = "demo-beerEntryId-500000"
//        itemForGet._beer = beer
//        
//        
//        group.enter()
//        
//        
//        objectMapper.save(itemForGet, completionHandler: {(error: Error?) -> Void in
//            if let error = error as? NSError {
//                DispatchQueue.main.async(execute: {
//                    errors.append(error)
//                })
//            }
//            group.leave()
//        })
//        
//        for _ in 1..<numberOfObjects {
//            
//            let item: Beers = Beers()
//            item._userId = AWSIdentityManager.default().identityId!
//            item._beerEntryId =
//                item._beer = NoSQLSampleDataGenerator.randomSampleMap()
//            
//            group.enter()
//            
//            objectMapper.save(item, completionHandler: {(error: Error?) -> Void in
//                if error != nil {
//                    DispatchQueue.main.async(execute: {
//                        errors.append(error! as NSError)
//                    })
//                }
//                group.leave()
//            })
//        }
//        
//        group.notify(queue: DispatchQueue.main, execute: {
//            if errors.count > 0 {
//                completionHandler(errors)
//            }
//            else {
//                completionHandler(nil)
//            }
//        })
//    }
//    
//    
//    func updateItem(_ item: AWSDynamoDBObjectModel, completionHandler: @escaping (_ error: NSError?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        let itemToUpdate: AWSBeer = item as! AWSBeer
//        itemToUpdate._beer =
//        
//        objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
//            DispatchQueue.main.async(execute: {
//                completionHandler(error as? NSError)
//            })
//        })
//    }
//    
//    func removeItem(_ item: AWSDynamoDBObjectModel, completionHandler: @escaping (_ error: NSError?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        
//        objectMapper.remove(item, completionHandler: {(error: Error?) in
//            DispatchQueue.main.async(execute: {
//                completionHandler(error as? NSError)
//            })
//        })
//    }
//}
//
//class BeersPrimaryIndex: NSObject, Index {
//    
//    var indexName: String? {
//        return nil
//    }
//    
//    func supportedOperations() -> [String] {
//        return [
//            QueryWithPartitionKey
//        ]
//    }
//    
//    func queryWithPartitionKeyDescription() -> String {
//        let partitionKeyValue = AWSIdentityManager.default().identityId!
//        return "Find all items with userId = \(partitionKeyValue)."
//    }
//    
//    func queryWithPartitionKeyWithCompletionHandler(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
//        let objectMapper = AWSDynamoDBObjectMapper.default()
//        let queryExpression = AWSDynamoDBQueryExpression()
//        
//        queryExpression.keyConditionExpression = "#userId = :userId"
//        queryExpression.expressionAttributeNames = ["#userId": "userId",]
//        queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!,]
//        
//        objectMapper.query(Beers.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
//            DispatchQueue.main.async(execute: {
//                completionHandler(response, error as? NSError)
//            })
//        }
//    }
//    
//}
//
//
