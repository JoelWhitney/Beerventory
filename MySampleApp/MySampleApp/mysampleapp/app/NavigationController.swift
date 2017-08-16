//
//  NavigationController.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift
import RxCocoa

class NavigationController: UINavigationController {
    var mainBeerStore = BeerStore(storage_type: "main")
    var scanResultsBeerStore = BeerStore(storage_type: "scanresults")
    let navBarAppearance = UINavigationBar.appearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //createTempData()
        self.toolbar.isTranslucent = false
        self.toolbar.barTintColor = UIColor(red: 235/255, green: 171/255, blue: 28/255, alpha: 1)
        self.toolbar.tintColor = UIColor.white
        
    }
    
    func createTempData() {
        if mainBeerStore.allBeers.value.count == 0 {
            print(" NO BEERS HEREYAHH --- LET's FAKE SOME OUT")
            if let asset = NSDataAsset(name: "data", bundle: Bundle.main) {
                let json = JSON(data: asset.data)
                if let results = json["data"].array {
                    let tempResults: Variable<[Beer]> = Variable([])
                    for beerResult in results {
                        print("           " + beerResult["name"].string! )
                        let beerResultObject = Beer(brewerydb_id: beerResult["id"].string! ,
                                                    upc_code: "11111111" ,
                                                    name: beerResult["name"].string ?? "" ,
                                                    beer_description: beerResult["description"].string ?? "",
                                                    abv: beerResult["abv"].string ?? "--" ,
                                                    label: beerResult["labels"]["large"].string ?? "" ,
                                                    gravity: beerResult["style"]["ogMin"].string ?? "--" ,
                                                    availability: beerResult["available"]["name"].string ?? "" ,
                                                    availability_desc: beerResult["available"]["description"].string ?? "" ,
                                                    style_name: beerResult["style"]["shortName"].string ?? "" ,
                                                    style_desc: beerResult["style"]["description"].string ?? "" ,
                                                    style_id: beerResult["style"]["id"].string ?? "")
                        beerResultObject.brewery_name = "Orono Brewing Company"
                        tempResults.value.append(beerResultObject)
                    }
                    self.mainBeerStore.allBeers = tempResults
                    print("####### STEP 3: BEERSTORE CONTENTS #######") // STEP 3 HERE
                    print(self.mainBeerStore.allBeers.value)
                    generateRandomQuantities()
                } else {
                    print("No beers in data file")
                }
            } else {
                print("Invalid filename/path.")
            }
        }
    }
    func generateRandomQuantities(){
        for beer in mainBeerStore.allBeers.value {
            let random_quantity = Int(arc4random_uniform(6) + UInt32(1))
            print(random_quantity)
            beer.quantity = random_quantity
            mainBeerStore.saveChanges()
        }
    }
}
