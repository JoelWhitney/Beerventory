////
////  BeerStore.swift
////  Beerventory
////
////  Created by Joel Whitney on 4/20/17.
////  Copyright © 2017 Joel Whitney. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//import RxSwift
//import RxCocoa
//
//class BeerStore {
//    // MARK: - variables/constants
//    var beers = [Beer]
//    var beerArchiveURL: URL
//
//    // MARK: - initializers
//    init(storage_type: String) {
//        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = documentsDirectories.first!
//        beerArchiveURL = documentDirectory.appendingPathComponent("beerstore\(storage_type).archive")
//        print("Archive location: \(beerArchiveURL.path)")
//        if let archivedBeers = NSKeyedUnarchiver.unarchiveObject(withFile: beerArchiveURL.path) as? [Beer] {
//            print("Retrieving data from File System")
//            allBeers.value = archivedBeers
//        } else {
//            print("No existing data -- creating random entries BUT THIS IS NOT IMPLEMENTED!!")
////            let beers = [["search_type": "beer_name", "value": "Substance"],
////                         ["search_type": "barcode", "value": "0705105321561"]]
////            for beer in beers {
////                let dummyBeer = Beer(coder: beer)
////                allBeers.append(dummyBeer)
////            }
//        }
//        print(allBeers.value)
//    }
//
//
//    // MARK: - class methods
//    func removeBeer(beer: Beer) {
//        let newBeers = allBeers.value.filter { $0.brewerydb_id != beer.brewerydb_id }
//        allBeers.value = newBeers
//        saveChanges()
//    }
//    func removeAllBeers() {
//        allBeers = Variable([])
//        print("ALL beer removed from BeerStore")
//        print(allBeers.value)
//        saveChanges()
//    }
//    func moveBeer(fromIndex: Int, to toIndex: Int) {
//        if fromIndex == toIndex {
//            return
//        }
//        let movedBeer = allBeers.value[fromIndex]
//        allBeers.value.remove(at: fromIndex)
//        allBeers.value.insert(movedBeer, at: toIndex)
//    }
//    func updateBeerQuantity(updatedBeer: Beer) {
//        allBeers.value.filter({$0.brewerydb_id == updatedBeer.brewerydb_id}).first?.quantity = updatedBeer.quantity
//    }
//    func addBeer(brewerydb_id: String, upc_code: String, name: String, beer_description: String, abv: String,
//                 label: String, gravity: String, availability: String, availability_desc: String,
//                 style_name: String, style_desc: String, style_id: String) {
//        print("~~~~~~~~~~~~~~ STEP 2: Adding '\(name) (\(brewerydb_id))' to BeerStore ~~~~~~~~~~~~")
//        let newBeer = Beer(brewerydb_id: brewerydb_id, upc_code: upc_code, name: name, beer_description: beer_description, abv: abv,
//                           label: label, gravity: gravity, availability: availability, availability_desc: availability_desc,
//                           style_name: style_name, style_desc: style_desc, style_id: style_id)
//        allBeers.value.insert(newBeer, at: 0)
//        print(allBeers.value)
//        print("'\(allBeers.value.count)' in BeerStore")
//    }
//    func addBeerObject(beer: Beer) {
//        allBeers.value.insert(beer, at: 0)
//        print(allBeers.value)
//        print("'\(allBeers.value.count)' in BeerStore")
//    }
//
//    func saveChanges() -> Bool {
//        print("Saving beers to: \(beerArchiveURL.path)")
//        return NSKeyedArchiver.archiveRootObject(allBeers.value, toFile: beerArchiveURL.path)
//    }
//}

