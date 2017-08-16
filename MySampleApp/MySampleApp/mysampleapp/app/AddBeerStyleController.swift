//
//  AddBeerStyleController.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/9/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class AddBeerStyleController: UIViewController {
    // MARK: - variables/constants
    let tabControllerIndex = 2
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
    var categories: [Category] {
        let tabController = self.tabBarController as? TabBarController
        return tabController!.categories
    }
    var filterResults = [Category]()
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
        definesPresentationContext = true
        searchDispCont.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchDispCont.searchBar
        searchDispCont.searchBar.backgroundColor = UIColor(red: 235/255, green: 171/255, blue: 28/255, alpha: 1)
        searchDispCont.searchBar.searchBarStyle = .minimal
        searchDispCont.searchBar.placeholder = "Filter"
        searchDispCont.searchBar.returnKeyType = UIReturnKeyType.done
        // other crap
        fillKnownDetails()
        formatSummaryCell()
        continueButton.addTarget(self, action: #selector(AddBeerStyleController.tabControllerContinue), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fillKnownDetails()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchDispCont.searchBar.text = ""
        self.searchDispCont.isActive = false
        self.tableView.reloadData()
    }
    // MARK: Additional views
    
    // MARK: Imperative methods
    func tabControllerContinue() {
        self.tabBarController?.selectedIndex = tabControllerIndex + 1
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "beersAdded") {
            let yourNextViewController = (segue.destination as! MainViewController)
            //yourNextViewController alert here about added beers
        }
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
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        if self.categories.count == 0 {
            self.filterResults = [Category]()
            return
        } else {
            for category in categories {
                let newCategory = category
                var filteredStyles = category.styles.filter( {( style: Style) -> Bool in
                    // to start, let's just search by name
                    return style.style_name.lowercased().range(of: searchText.lowercased()) != nil
                })
                newCategory.styles = filteredStyles
                self.filterResults.append(newCategory)
            }
        }
        print(filterResults)
    }
}

// MARK: - tableView data source
extension AddBeerStyleController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            return self.filterResults[section].category_name
        } else {
            return self.categories[section].category_name
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            return self.filterResults.count
        } else {
            return self.categories.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            tableView.isScrollEnabled = false
            return self.filterResults[section].styles.count
        } else {
            tableView.isScrollEnabled = false
            return self.categories[section].styles.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let style: Style!
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            style = self.filterResults[indexPath.section].styles[indexPath.row]
        } else {
            style = self.categories[indexPath.section].styles[indexPath.row]
        }
        
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "AddBeerDetailsCell", for: indexPath) as! AddBeerDetailsCell
        cell.detailsLabel.text = style.style_name
        cell.secondaryDetailsLabel.text = style.category_name
        return cell
    }
}

// MARK: - tableView delegate
extension AddBeerStyleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchDispCont.isActive {
            if searchDispCont.searchBar.text != "" && self.filterResults[section].styles.count != 0 {
                return 20
            } else if searchDispCont.searchBar.text == "" {
                return 20
            }
        } else if !searchDispCont.isActive && searchDispCont.searchBar.text == "" {
            if self.categories[section].styles.count != 0 {
                return 20
            }
        }
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchDispCont.isActive && searchDispCont.searchBar.text != "" {
            let style = filterResults[indexPath.section].styles[indexPath.row]
            newBeer.style_name = style.style_name
            newBeer.style_id = style.style_id
            fillKnownDetails()
            self.searchDispCont.isActive = false
            self.tableView.reloadData()
        } else {
            let style = categories[indexPath.section].styles[indexPath.row]
            newBeer.style_name = style.style_name
            newBeer.style_id = style.style_id
            fillKnownDetails()
            self.searchDispCont.isActive = false
            self.tableView.reloadData()
        }
        configureSummaryButton()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension AddBeerStyleController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        self.tableView.isScrollEnabled = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        //self.searchDispCont.isActive = false
        self.filterResults = [Category]()
        self.tableView.reloadData()
    }
}

extension AddBeerStyleController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchDispCont.searchBar.text != "" {
            let searchString = searchDispCont.searchBar.text!
            print("text changed to: \(searchString)")
            filterContentForSearchText(searchText: searchString)
            tableView.reloadData()
        } else {
            filterResults = [Category]()
            self.tableView.reloadData()
        }
    }
}

