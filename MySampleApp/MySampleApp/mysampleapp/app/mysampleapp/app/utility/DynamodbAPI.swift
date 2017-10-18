//
//  DynamodbAPI.swift
//  MySampleApp
//
//  Created by Joel Whitney on 9/10/17.
//

import Foundation
import SwiftyJSON
import AWSDynamoDB
import AWSMobileHubHelper

//typealias ServiceResponse = (JSON, NSError?) -> Void

class DynamodbAPI: NSObject {
    static let sharedInstance = DynamodbAPI()
    
    // MARK: - Methods
    func queryWithPartitionKeyDescription() -> String {
        let partitionKeyValue = AWSIdentityManager.default().identityId!
        return "Find all items with userId = \(partitionKeyValue)."
    }
    
    func queryWithPartitionKeyWithCompletionHandler(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        if let userId = AWSIdentityManager.default().identityId {
            let objectMapper = AWSDynamoDBObjectMapper.default()
            let queryExpression = AWSDynamoDBQueryExpression()
            
            queryExpression.keyConditionExpression = "#userId = :userId"
            queryExpression.expressionAttributeNames = ["#userId": "userId",]
            queryExpression.expressionAttributeValues = [":userId": userId,]
            
            objectMapper.query(AWSBeer.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
                DispatchQueue.main.async(execute: {
                    completionHandler(response, error as? NSError)
                })
            }
        }
    }

    func updateBeer(awsBeer: AWSBeer, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(awsBeer, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }
    
    func removeBeer(awsBeer: AWSBeer, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.remove(awsBeer, completionHandler:  {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
        })
        completioHandler()
    }
    
    func insertBeer(awsBeer: AWSBeer, completioHandler: () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = awsBeer.beer().brewerydb_id
        itemToCreate._beer = awsBeer.beer().beerData
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        completioHandler()
    }
    
    func removeAllBeers(onCompletion: @escaping () -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        queryWithPartitionKeyWithCompletionHandler { (response, error) in
            if let erro = error {
                print("error: \(erro)")
            } else if response?.items.count == 0 {
                print("No items")
            } else {
                print("success: \(response!.items.count) items")
                for item in response!.items {
                    let awsBeer = item as! AWSBeer
                    DynamodbAPI.sharedInstance.removeBeer(awsBeer: awsBeer, completioHandler: {
                        print("item deleted")
                    })
                }
                onCompletion()
            }
        }
    }
}
