//
//  BrewerydbAPI.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/27/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift

typealias ServiceResponse = (JSON, NSError?) -> Void

class BrewerydbAPI: NSObject {
    static let sharedInstance = BrewerydbAPI()
    let api_key = "4b9b7710e0d75b9b4416a4450312eeff"
    let baseURL = "https://api.brewerydb.com/v2/"
    
    // MARK: - GET METHODS
    // Beers
    func search_barcode(barCode: String, onCompletion: @escaping (JSON) -> Void) {
        let upc_search = "search/upc?"
        let parameters = [["name": "code", "value": barCode],
                          ["name": "key", "value": api_key]] // example_upc_code = "0705105321561"
        makeHTTPGetRequest(url: baseURL + upc_search, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    func search_beer_name(beerName: String, onCompletion: @escaping (JSON) -> Void){
        let beer_name_search = "search?" // search?q=Goosinator&type=beer
        let parameters = [["name": "q", "value": beerName],
                          ["name": "type", "value": "beer"],
                          ["name": "withBreweries", "value": "Y"],
                          ["name": "key", "value": api_key]] // example_beer_name = "Goosinator"
        makeHTTPGetRequest(url: baseURL + beer_name_search, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    // Beer brewery details after calling above
    func get_beers_breweries(beers: [Beer], onCompletion: @escaping ([Beer]) -> Void) {
        var updatedBeers = [Beer]()
        for beer in beers {
            let beer_brewery_search = "beer/\(beer.brewerydb_id)?"
            let parameters = [["name": "withBreweries", "value": "Y"],
                              ["name": "key", "value": api_key]]
            makeHTTPGetRequest(url: baseURL + beer_brewery_search, parameters: parameters, onCompletion: { json, err in
                if let beer_json = json["data"].dictionary {
                    //self.beer_details_json = beer_json
                }
                if let brewery_details = json["data"]["breweries"].array {
                    beer.brewery_name = brewery_details[0]["name"].string!
                    print("    " + beer.brewery_name + " (" + beer.brewerydb_id + ")")
                    beer.brewery_id = brewery_details[0]["id"].string!
                }
                updatedBeers.append(beer)
                onCompletion(updatedBeers)
            })
        }
        onCompletion(updatedBeers)
    }
    // Breweries
    func search_brewery_name(breweryName: String, onCompletion: @escaping (JSON) -> Void){
        let brewery_name_search = "breweries?"
        let parameters = [["name": "name", "value": breweryName + "*"],
                          ["name": "withLocations", "value": "Y"],
                          ["name": "key", "value": api_key]] // adding wild card to get anything close to it
        makeHTTPGetRequest(url: baseURL + brewery_name_search, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    // Styles
    func search_beer_styles(onCompletion: @escaping (JSON) -> Void){
        let beer_style_search = "styles?"
        let parameters = [["name": "key", "value": api_key]] // adding wild card to get anything close to it
        makeHTTPGetRequest(url: baseURL + beer_style_search, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    func search_beer_categories(onCompletion: @escaping (JSON) -> Void){
        let beer_style_search = "categories?"
        let parameters = [["name": "key", "value": api_key]] // adding wild card to get anything close to it
        makeHTTPGetRequest(url: baseURL + beer_style_search, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }

    // MARK: - POST METHODS
    // Beers
    func add_beer(beer: Beer, onCompletion: @escaping (JSON) -> Void) {
        let add_beer = "beers"
        let parameters = [["name": "name", "value": beer.name],
                    ["name": "styleId", "value": beer.style_id],
                    ["name": "description", "value": beer.beer_description],
                    ["name": "abv", "value": beer.abv],
                    ["name": "brewery", "value": beer.brewery_id], // comma seperated list?
                    ["name": "key", "value": api_key]]
        makeHTTPPostRequest(url: baseURL + add_beer, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    func add_beer_upc(beer: Beer, onCompletion: @escaping (JSON) -> Void) {
        let add_beer_upc = "beer/\(beer.brewerydb_id)/upcs"  // beer/N101SS/upcs
        let parameters = [["name": "upcCode", "value": beer.upc_code],
                    ["name": "key", "value": api_key]]
        makeHTTPPostRequest(url: baseURL + add_beer_upc, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // Breweries
    func add_brewery(breweryName: String, onCompletion: @escaping (JSON) -> Void) {
        let add_brewery = "breweries"
        let parameters = [["name": "name", "value": breweryName],
                    ["name": "key", "value": api_key]]
        makeHTTPPostRequest(url: baseURL + add_brewery, parameters: parameters, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    // MARK: - MAIN GET REQUEST
    private func makeHTTPGetRequest(url: String, parameters: [[String: String]], onCompletion: @escaping ServiceResponse) {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = []
        for parameter in parameters {
            urlComponents.queryItems?.append(URLQueryItem(name: parameter["name"]!, value: parameter["value"]!))
        }
        let requestURL = urlComponents.url
        print("       API request: " + (requestURL?.absoluteString ?? ""))
        let request = NSMutableURLRequest(url: requestURL!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
    
    // MARK: - MAIN POST REQUEST
    private func makeHTTPPostRequest(url: String, parameters: [[String: String]], onCompletion: @escaping ServiceResponse) {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = []
        for parameter in parameters {
            urlComponents.queryItems?.append(URLQueryItem(name: parameter["name"]!, value: parameter["value"]!))
        }
        let requestURL = urlComponents.url
        print("       API request: " + (requestURL?.absoluteString ?? ""))
        let request = NSMutableURLRequest(url: requestURL!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json = JSON(data: jsonData)
                onCompletion(json, nil)
            } else {
                onCompletion(JSON.null, error! as NSError)
            }
        })
        task.resume()
    }
}
