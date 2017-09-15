//
//  AddBeerStyleController.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/9/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AddBeerStyleController: UIViewController {
    // MARK: - variables/constants
    var currentBeer: Beer!
    var categories: [Category]!
    var filterHandler: ((String?) -> Void)?
    var styles = [Style]() {
        didSet {
            applyFilter()
        }
    }
    var filteredStyles = [Style]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedIndexPath: IndexPath!
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

    // MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!


    // MARK: Actions

    // MARK: Initializers

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildStyleList()
    }
    // MARK: Additional views

    // MARK: Imperative methods
    func buildStyleList() {
        BrewerydbAPI.sharedInstance.search_beer_categories(onCompletion: { (json: JSON) in
            self.fetchCategories(categoryJSON: json, onCompletion: {
                BrewerydbAPI.sharedInstance.search_beer_styles(onCompletion: { (json: JSON) in
                    self.fetchStyles(styleJSON: json)
                })
            })
        })
    }
    
    func fetchCategories(categoryJSON: JSON, onCompletion: () -> Void) {
        categories = []
        guard let results = categoryJSON["data"].array else {
            return
        }
        print(results)
        self.categories = results.map { Category(categoryJSON: $0) }
        print(self.categories)
        onCompletion()
    }

    func fetchStyles(styleJSON: JSON){
        let styles: [Style]
        guard let results = styleJSON["data"].array else {
            return
        }
        print(results)
        self.styles = results.map { Style(styleJSON: $0) }
        print(self.styles)
    }
    
    func applyFilter() {
        guard let searchText = searchBar.text?.lowercased(), !searchText.isEmpty, styles.count > 0 else {
            filteredStyles = styles.sorted(by: { $0.style_name < $1.style_name })
            filterHandler?(nil)
            return
        }
        filteredStyles = styles.filter { $0.style_name.lowercased().contains(searchText)}
            .sorted(by: { $0.style_name < $1.style_name })
        filterHandler?(searchText)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addBeerViewController = segue.destination as? AddBeerViewController {
            let replacementBeer = currentBeer
            let selectedStyle = filteredStyles[selectedIndexPath.row]
            replacementBeer?.style_name = selectedStyle.style_name
            replacementBeer?.style_id = selectedStyle.style_id
            addBeerViewController.beer = replacementBeer!
        }
    }
}

// MARK: - tableView data source
extension AddBeerStyleController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStyles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentStyle = filteredStyles[indexPath.row]
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerDetailsCell", for: indexPath) as! AddBeerDetailsCell
        cell.detailsLabel.text = currentStyle.style_name
        cell.secondaryDetailsLabel.text = currentStyle.category_name
        return cell
        
    }
}

// MARK: - tableView delegate
extension AddBeerStyleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "unwindToAddBeer", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search bar delegate
extension AddBeerStyleController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.applyFilter), object: nil)
        self.perform(#selector(self.applyFilter), with: nil, afterDelay: 0.5)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



