//
//  TabBarController.swift
//  Beerventory
//
//  Created by Joel Whitney on 6/25/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class TabBarController: UITabBarController{
    var newBeer = Beer()
    var mainBeerStore: BeerStore {
        let navController = self.navigationController as? NavigationController
        return navController!.mainBeerStore
    }
    var categories = [Category]()

    override func viewDidLoad() {
        print(newBeer)
        fetchCategories()
        super.viewDidLoad()
    }
    
    
    func fetchStyles(){
        BrewerydbAPI.sharedInstance.search_beer_styles(onCompletion: { (json: JSON) in
            self.handleStyleJSON(styleJSON: json)
        })
    }
    func fetchCategories() {
        BrewerydbAPI.sharedInstance.search_beer_categories(onCompletion: { (json: JSON) in
            self.handleCategoryJSON(categoryJSON: json, onCompletion: {
                self.fetchStyles()
            })
        })
    }
    func handleCategoryJSON(categoryJSON: JSON, onCompletion: () -> Void) {
        categories = []
        if let results = categoryJSON["data"].array {
            for categoryResult in results {
                print("           " + String(describing: categoryResult["id"]) )
                print("           " + categoryResult["name"].string! )
                let catResultObject = Category(category_id: String(describing: categoryResult["id"]) ?? "", category_name: categoryResult["name"].string! ?? "")
                categories.append(catResultObject)
            }
            print(categories)
        } else {
            print("   No Beers")
            //            let alertController = UIAlertController(title: "Error", message: "The barcode is not in the database, consider adding it. Showing last search result", preferredStyle: UIAlertControllerStyle.alert)
            //            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            //            self.present(alertController, animated: true, completion: nil)
        }
        onCompletion()
    }
    func handleStyleJSON(styleJSON: JSON) {
        if let results = styleJSON["data"].array {
            for styleResult in results {
                print("           " + String(describing: styleResult["id"]) )
                print("           " + styleResult["name"].string! )
                let styleResultObject = Style(style_id: String(describing: styleResult["id"]) ?? "", style_name: styleResult["name"].string! ?? "",
                                              category_id: String(describing: styleResult["category"]["id"]) ?? "", category_name: styleResult["category"]["name"].string! ?? "")
                let category = categories.filter {
                    $0.category_id == styleResultObject.category_id
                }
                category[0].styles.append(styleResultObject)
                print("Added to \(category[0].category_id) - \(category[0].category_name)")
            }
        } else {
            print("   No Beers")
            //            let alertController = UIAlertController(title: "Error", message: "The barcode is not in the database, consider adding it. Showing last search result", preferredStyle: UIAlertControllerStyle.alert)
            //            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            //            self.present(alertController, animated: true, completion: nil)
        }
    }
}
