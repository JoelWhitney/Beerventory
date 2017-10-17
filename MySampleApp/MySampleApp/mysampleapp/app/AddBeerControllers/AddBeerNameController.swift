//
//  AddBeerNameController.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/9/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AddBeerNameController: UIViewController {
    // MARK: - variables/constants
    var currentBeer: Beer!
//    var summaryRequirements: Bool {
//        let required = [newBeer.upc_code, newBeer.name, newBeer.brewery_name, newBeer.style_name]
//        var bool = true
//        for param in required {
//            if param == "" {
//                bool = false
//            }
//        }
//        return bool
//    }
    var selectedIndexPath: IndexPath!
    var searchHandler: ((String?) -> Void)?
    var searchResultsBeers: [Beer] = [] {
        didSet {
            print("saerch results changed")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    
    // MARK: Actions

    // MARK: Initializers

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Additional views

    // MARK: Imperative methods
    func applySearch() {
        guard let searchText = searchBar.text?.lowercased(), !searchText.isEmpty else {
            searchHandler?(nil)
            return
        }
        self.searchBeerNames(searchString: searchText, onCompletion: {
            self.searchHandler?(nil)
        })
    }
    
    func searchBeerNames(searchString: String, onCompletion: @escaping () -> Void) {
        searchResultsBeers = []
        BrewerydbAPI.sharedInstance.search_beer_name(beerName: searchString, onCompletion: { (json: JSON) in
            guard let results = json["data"].array else {
                self.searchResultsBeers = []
                return
            }
            print(results)
            var firstResults = results.prefix(10)
            self.searchResultsBeers = firstResults.map { Beer(beerJSON: $0) }
            print(self.searchResultsBeers)
            onCompletion()
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addBeerViewController = segue.destination as? AddBeerViewController {
            if selectedIndexPath.row == 0 {
                let replacementBeer = currentBeer
                replacementBeer?.name = searchBar.text!
                addBeerViewController.beer = replacementBeer!
            } else {
                let replacementBeer = searchResultsBeers[selectedIndexPath.row - 1]
                replacementBeer.upc_code = currentBeer.upc_code
                addBeerViewController.beer = replacementBeer
            }
        }
    }
}

// MARK: - tableView data source
extension AddBeerNameController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard searchResultsBeers.count != 0 else {
            return 1
        }
        return searchResultsBeers.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard searchResultsBeers.count != 0 else {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerEmptyCell", for: indexPath) as! AddBeerEmptyCell
            cell.lastCellLabel.text = "Search Beer or Enter new name"
            return cell
        }
        if indexPath.row == 0 {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerNewCell", for: indexPath) as! AddBeerNewCell
            cell.detailsLabel.text = "Add new beer name "
            cell.secondaryDetailsLabel.text = "\"" + searchBar.text! + "\""
            return cell
        } else {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerDetailsCell", for: indexPath) as! AddBeerDetailsCell
            let currentBeer = searchResultsBeers[indexPath.row - 1]
            cell.detailsLabel.text = currentBeer.name
            cell.secondaryDetailsLabel.text = currentBeer.brewery_name
            return cell
        }

    }
}

// MARK: - tableView delegate
extension AddBeerNameController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "unwindToAddBeer", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search bar delegate
extension AddBeerNameController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.applySearch), object: nil)
        self.perform(#selector(self.applySearch), with: nil, afterDelay: 0.5)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


