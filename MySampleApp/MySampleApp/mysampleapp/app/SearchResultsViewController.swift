//
//  SearchResultsViewController
//  MySampleApp
//
//  Created by Joel Whitney on 8/20/17.
//
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import SwiftyJSON

class SearchResultsViewController: UIViewController, SlidingPanelContentProvider {
    // MARK: - variables/constants
    var firstIndexPath: IndexPath!
    var beerventoryBeers: [AWSBeer] = []
    var filterHandler: ((String?) -> Void)?
    var searchResultsBeers: [Beer] = [] {
        didSet {
            //applySearch()
            print("saerch results changed")
        }
    }
    var filteredSearchResultsBeers: [Beer] = [] {
        didSet {
            print("filtered")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var currentBeer: Beer!
    var selectedIndexPath: IndexPath!
    var pickerQuantity = "1"
    var contentScrollView: UIScrollView? {
        return tableView
    }
    var summaryHeight: CGFloat = 68
    var searchResultTapped: ((Beer) -> Void)?
    
    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBeerventoryBeers() // do I really need this here?
        
    }
    
    // MARK: - Methods
    func fetchBeerventoryBeers() {
        if AWSSignInManager.sharedInstance().isLoggedIn {
            DynamodbAPI.sharedInstance.queryWithPartitionKeyWithCompletionHandler { (response, error) in
                if let erro = error {
                    print("error: \(erro)")
                } else if response?.items.count == 0 {
                    print("No items")
                } else {
                    print("success: \(response!.items.count) items")
                    self.beerventoryBeers = response!.items.map { $0 as! AWSBeer }
                        .sorted(by: { $0.beer().name < $1.beer().name })
                }
            }
        }
    }
    func searchBeerNames(searchString: String, onCompletion: @escaping () -> Void) {
        searchResultsBeers = []
        BrewerydbAPI.sharedInstance.search_beer_name(beerName: searchString, onCompletion: { (json: JSON) in
            guard let results = json["data"].array else {
                return
            }
            print(results)
            self.searchResultsBeers = results.map { Beer(beerJSON: $0) }
            print(self.searchResultsBeers)
            onCompletion()
        })
    }
    func checkButtonTapped(sender:AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        selectedIndexPath = indexPath!
    }

    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    func showPickerInActionSheet(sender: AnyObject) {
        pickerQuantity = "1"
        checkButtonTapped(sender: sender)
        currentBeer = searchResultsBeers[selectedIndexPath.row]
        var actionType: String
        var actionTitle: String
        if sender.tag == 1 {
            actionType = "add"
            actionTitle = "Add"
        } else {
            actionType = "remove"
            actionTitle = "Remove"
        }
        print("\(actionTitle) \(currentBeer.name)")
        var title = "\(actionTitle) \(currentBeer.name)"
        var message = "Enter quantity of beers to \(actionType)\n\n\n\n\n\n\n\n\n\n"
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.isModalInPopover = true
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        var pickerFrame: CGRect = CGRect(x: 17, y: 52, width: 270, height: 160); // CGRectMake(left), top, width, height) - left and top are like margins
        var picker: UIPickerView = UIPickerView(frame: pickerFrame);
        //set the pickers datasource and delegate
        picker.delegate = self
        picker.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(picker)
        //add buttons to the view
        var buttonCancelFrame: CGRect = CGRect(x: 0, y: 200, width: 100, height: 30) //size & position of the button as placed on the toolView
        //Create the cancel button & set its title
        var buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState.normal)
        buttonCancel.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(cancelSelection), for: UIControlEvents.touchDown)
        //add buttons to the view
        var buttonOkFrame: CGRect = CGRect(x: 170, y:  200, width: 100, height: 30); //size & position of the button as placed on the toolView
        //Create the Select button & set the title
        var buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        if sender.tag == 1 {
            buttonOk.addTarget(self, action: #selector(addBeers), for: UIControlEvents.touchDown);
            buttonOk.setTitle("Add", for: UIControlState.normal);
            buttonOk.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        } else {
            //
        }
        alert.view.addSubview(buttonOk)
        alert.view.addSubview(buttonCancel)
        self.present(alert, animated: true, completion: nil);
    }
    func addBeers(sender: UIButton){
        guard let quantity = Int(pickerQuantity) else {
            // handle bad no value or text entry
            return
        }
        guard let existingAWSBeer = beerventoryBeers.filter({$0._beerEntryId == currentBeer.brewerydb_id}).first else {
            // Add new beer if doesn't exist
            currentBeer.quantity = quantity
            insertAWSBeer(beer: currentBeer)
            self.dismiss(animated: true, completion: {
                let alertController2 = UIAlertController(title: "\(self.currentBeer.name) added", message: "You added \(self.currentBeer.quantity) \(self.currentBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
                alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController2, animated: true, completion: nil)
            })
            return
        }
        // Update beer quanity if exists
        let existingBeer = existingAWSBeer.beer()
        existingBeer.quantity += quantity
        existingAWSBeer._beer = existingBeer.beerData
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(existingAWSBeer, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        self.dismiss(animated: true, completion: {
            let alertController2 = UIAlertController(title: "\(self.currentBeer.name) added", message: "You now have \(existingBeer.quantity) \(self.currentBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
            alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController2, animated: true, completion: nil)
        })
    }
    func insertAWSBeer(beer: Beer) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = beer.brewerydb_id
        itemToCreate._beer = beer.beerData
        //itemToCreate._beer = ["thing": ""]
        print(itemToCreate._userId as String!)
        print(itemToCreate._beerEntryId as String!)
        print(itemToCreate._beer as [String: String]!)
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
    }
    func updateAWSBeer(beer: Beer) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = beer.brewerydb_id
        itemToCreate._beer = beer.beerData
        //itemToCreate._beer = ["thing": ""]
        print(itemToCreate._userId as String!)
        print(itemToCreate._beerEntryId as String!)
        print(itemToCreate._beer as [String: String]!)
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
    }
    func updateWithScanResults(beers: [Beer]) {
        self.searchResultsBeers = beers
    }
    
    func applySearch() {
        
        guard let searchText = searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredSearchResultsBeers = searchResultsBeers
            filterHandler?(nil)
            return
        }
        self.searchBeerNames(searchString: searchText, onCompletion: {
            self.filteredSearchResultsBeers = self.searchResultsBeers
            self.filterHandler?(nil)
        })
    }
}

// MARK: - UIPicker delegate
extension SearchResultsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerQuantity = String(row + 1)
    }
}

// MARK: - UIPicker delegate
extension SearchResultsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(row)
        return String(row + 1)
    }
}

// MARK: - Table view data source
extension SearchResultsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.filteredSearchResultsBeers.count == 0 {
            return "Search results"
        } else if self.filteredSearchResultsBeers.count == 1 {
            return "Last search results (\(self.filteredSearchResultsBeers.count) beer)"
        } else {
            return "Last search results (\(self.filteredSearchResultsBeers.count) beers)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSearchResultsBeers.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.filteredSearchResultsBeers.count == 0 {
            return 0.0
        } else {
            return 20.0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            firstIndexPath = indexPath
        }
        let searchResult = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableCell", for: indexPath) as! SearchResultTableCell
        let beer = filteredSearchResultsBeers[indexPath.row]
        // cell details
        searchResult.beerNameLabel.text = beer.name
        searchResult.beerStyle.text = beer.style_name
        searchResult.breweryNameLabel.text = beer.brewery_name
        searchResult.abvLabel.text = "\(beer.abv)%"
        searchResult.addBeerButton.tag = 1
        searchResult.addBeerButton.addTarget(self, action: #selector(showPickerInActionSheet), for: .touchUpInside)
        return searchResult
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let searchResult = cell as? SearchResultTableCell {
            // cell formatting
            searchResult.mainBackground.layer.cornerRadius = 8
            searchResult.mainBackground.layer.masksToBounds = true
            searchResult.shadowLayer.layer.masksToBounds = false
            searchResult.shadowLayer.layer.shadowOffset = CGSize.zero
            searchResult.shadowLayer.layer.shadowColor = UIColor.black.cgColor
            searchResult.shadowLayer.layer.shadowOpacity = 0.5
            searchResult.shadowLayer.layer.shadowRadius = 2
            searchResult.shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: searchResult.shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
            searchResult.shadowLayer.layer.shouldRasterize = false
            searchResult.shadowLayer.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentBeer = filteredSearchResultsBeers[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchResultTapped!(currentBeer)
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let slidingPanelViewController = parent as? SlidingPanelViewController {
            slidingPanelViewController.panelContentDidScroll(self, scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let slidingPanelViewController = parent as? SlidingPanelViewController {
            slidingPanelViewController.panelContentWillBeginDecelerating(self, scrollView: scrollView)
        }
    }
}

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch()
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        searchBar.text = ""
        searchResultsBeers = []
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("did begin editing")
        if let slidingPanelViewController = parent as? SlidingPanelViewController {
            slidingPanelViewController.panelPosition = .full
        }
    }
}

// MARK: - SearchResultTableCell
class SearchResultTableCell: UITableViewCell {
    
    @IBOutlet var beerNameLabel: UILabel!
    @IBOutlet var beerStyle: UILabel!
    @IBOutlet var breweryNameLabel: UILabel!
    @IBOutlet var abvLabel: UILabel!
    @IBOutlet var gravityLabel: UILabel!
    @IBOutlet var addBeerButton: UIButton!
    @IBOutlet var shadowLayer: UIView!
    @IBOutlet var mainBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

