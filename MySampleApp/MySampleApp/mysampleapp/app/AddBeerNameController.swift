//
//  AddBeerNameController.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/9/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SwiftyJSON

class AddBeerNameController: UIViewController {
    // MARK: - variables/constants
    let tabControllerIndex = 0
    var newBeer: Beer {
        get {
            let tabController = self.tabBarController as? TabBarController
            return tabController!.newBeer
        }
        set {
            let tabController = self.tabBarController as? TabBarController
            print("SETTING!!!")
            print(tabController!.newBeer)
            tabController!.newBeer = newValue
            print(newValue.beer_description)
        }
    }
    var summaryRequirements: Bool {
        let required = [newBeer.upc_code, newBeer.name, newBeer.brewery_name, newBeer.style_name]
        var bool = true
        for param in required {
            if param == "" {
                bool = false
            }
        }
        return bool
    }
    var searchResultsBeer: Variable<[Beer]> = Variable([])
    let searchDispCont = UISearchController(searchResultsController: nil)
    
    
    // MARK: Outlets
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var shadowLayer: UIView!
    @IBOutlet var mainBackground: UIView!
    // summary card outlets
    @IBOutlet var beerNameLabel: UILabel!
    @IBOutlet var beerStyle: UILabel!
    @IBOutlet var breweryNameLabel: UILabel!
    @IBOutlet var abvLabel: UILabel!
    
    // MARK: Actions
    
    // MARK: Initializers
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSummaryButton()
        // tableview
        tableView.delegate = self
        tableView.dataSource = self
        // status bar
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor(red: 235/255, green: 171/255, blue: 28/255, alpha: 1)
        // search results tableview
        searchDispCont.searchResultsUpdater = self
        searchDispCont.searchBar.delegate = self
        searchDispCont.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchDispCont.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchDispCont.searchBar
        searchDispCont.searchBar.backgroundColor = UIColor(red: 235/255, green: 171/255, blue: 28/255, alpha: 1)
        searchDispCont.searchBar.searchBarStyle = .minimal
        searchDispCont.searchBar.placeholder = "Beer Name"
        searchDispCont.searchBar.returnKeyType = UIReturnKeyType.search
        // other crap
        fillKnownDetails()
        formatSummaryCell()
        continueButton.addTarget(self, action: #selector(AddBeerNameController.tabControllerContinue), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillKnownDetails()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchDispCont.searchBar.text = ""
        self.searchDispCont.isActive = false
        self.tableView.reloadData()
    }
    // MARK: Additional views
    
    // MARK: Imperative methods
    func handleJSON(beerJSON: JSON, maxResults: Int, onCompletion: () -> Void) {
        if let results = beerJSON["data"].array {
            var showMaxResults = maxResults
            if results.count < maxResults { showMaxResults = results.count }
            for i in 0..<showMaxResults {
                let beerResult = results[i]
                print("           " + beerResult["name"].string! )
                let beerResultObject = Beer(brewerydb_id: beerResult["id"].string! ,
                                            upc_code: "" ,
                                            name: beerResult["name"].string ?? "" ,
                                            beer_description: beerResult["description"].string ?? "",
                                            abv: beerResult["abv"].string ?? "--" ,
                                            label: beerResult["labels"]["large"].string ?? "" ,
                                            gravity: beerResult["style"]["ogMin"].string ?? "--" ,
                                            availability: beerResult["available"]["name"].string ?? "" ,
                                            availability_desc: beerResult["available"]["description"].string ?? "" ,
                                            style_name: beerResult["style"]["shortName"].string ?? "" ,
                                            style_desc: beerResult["style"]["description"].string ?? "" ,
                                            style_id: beerResult["style"]["id"].string ?? "" )
                beerResultObject.brewery_id = beerResult["breweries"][0]["id"].string ?? ""
                beerResultObject.brewery_name = beerResult["breweries"][0]["name"].string ?? ""
                searchResultsBeer.value.append(beerResultObject)
            }
            print(self.searchResultsBeer.value)
        } else {
            print("   No Beers")
//            let alertController = UIAlertController(title: "Error", message: "The barcode is not in the database, consider adding it. Showing last search result", preferredStyle: UIAlertControllerStyle.alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
//            self.present(alertController, animated: true, completion: nil)
        }
        onCompletion()
    }
    func tabControllerContinue() {
        self.tabBarController?.selectedIndex = tabControllerIndex + 1
    }
    func configureSummaryButton() {
        if let arrayOfTabBarItems = tabBarController?.tabBar.items as AnyObject as? NSArray,
            let tabBarItem = arrayOfTabBarItems[4] as? UITabBarItem {
            tabBarItem.isEnabled = summaryRequirements
        }
    }
    func fillKnownDetails() {
        // get dict info and fill in
        if newBeer.name == "" {
            beerNameLabel.text = "[beer name]"
        } else {
            beerNameLabel.text = newBeer.name
        }
        if newBeer.brewery_name == "" {
            breweryNameLabel.text = "[brewery name]"
        } else {
            breweryNameLabel.text = newBeer.brewery_name
        }
        if newBeer.style_name == "" {
            beerStyle.text = "[style]"
        } else {
            beerStyle.text = newBeer.style_name
        }
        if newBeer.abv == "" {
            abvLabel.text = "[abv]"
        } else {
            abvLabel.text = "\(newBeer.abv)%"
        }
    }
    func formatSummaryCell() {
        // cell formatting
        mainBackground.layer.cornerRadius = 8
        //mainBackground.layer.masksToBounds = true
        shadowLayer.layer.masksToBounds = false
        shadowLayer.layer.shadowOffset = CGSize.zero
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.layer.shadowRadius = 2
        shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        shadowLayer.layer.shouldRasterize = false
        shadowLayer.layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - tableView data source
extension AddBeerNameController: UITableViewDataSource {
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        // not implemented
    //    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            print("search text: show search table")
            tableView.isScrollEnabled = false
            return self.searchResultsBeer.value.count + 1
        } else {
            print("empty search: show empty table")
            tableView.isScrollEnabled = false
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            if indexPath.row == 0 {
                let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerNewCell", for: indexPath) as! AddBeerNewCell
                cell.detailsLabel.text = "Add new beer name "
                cell.secondaryDetailsLabel.text = "\"" + searchDispCont.searchBar.text! + "\""
                return cell
            } else {
                let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerDetailsCell", for: indexPath) as! AddBeerDetailsCell
                let currentBeer = searchResultsBeer.value[indexPath.row - 1]
                cell.detailsLabel.text = currentBeer.name
                cell.secondaryDetailsLabel.text = currentBeer.brewery_name
                return cell
            }
        } else {
            let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerEmptyCell", for: indexPath) as! AddBeerEmptyCell
            cell.lastCellLabel.text = "Search Beer or Enter new name"
            return cell
        }
    }
}

// MARK: - tableView delegate
extension AddBeerNameController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            if indexPath.row == 0 {
                newBeer.name = searchDispCont.searchBar.text!
            } else {
                let beer = searchResultsBeer.value[indexPath.row - 1]
                beer.upc_code = newBeer.upc_code
                newBeer = beer
            }
            fillKnownDetails()
            self.searchDispCont.isActive = false
            self.tableView.reloadData()
        } else {
            //
        }
        configureSummaryButton()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension AddBeerNameController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        self.tableView.isScrollEnabled = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        //self.searchDispCont.isActive = false
        self.searchResultsBeer.value = []
        self.tableView.reloadData()
    }
}

extension AddBeerNameController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchDispCont.searchBar.text != "" {
            let searchString = searchDispCont.searchBar.text!
            print("text changed to: \(searchString)")
            searchResultsBeer = Variable([])
            BrewerydbAPI.sharedInstance.search_beer_name(beerName: searchString, onCompletion: { (json: JSON) in
                self.handleJSON(beerJSON: json, maxResults: 10, onCompletion: {
                    DispatchQueue.main.async(execute: {
                        print("reload search tableview")
                        self.tableView.reloadData()
                    })
                })
            })
        } else {
            searchResultsBeer = Variable([])
            self.tableView.reloadData()
        }
    }
}

