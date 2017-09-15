//
//  AddBeerViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 9/1/17.
//

import Foundation
import UIKit
import SwiftyJSON
import AWSDynamoDB
import AWSMobileHubHelper

class AddBeerViewController: UITableViewController {
    // MARK: - Variables
    var beerventoryBeers: [AWSBeer] = []
    var beer = Beer() {
        didSet {
            populateEventDetails()
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    var showDescriptionTextView = false
    var beerDescription: String!
    var pickerQuantity = "1"

    // MARK: - Outlets
    @IBOutlet var beerNameLabel: UILabel!
    @IBOutlet var breweryNameLabel: UILabel!
    @IBOutlet var styleNameLabel: UILabel!
    @IBOutlet var descriptionTextViewCell: UITableViewCell!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var upcCodeLabel: UILabel!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var addButton: UIButton!
    
    // MARK: - Actions
    @IBAction func unwindToAddBeer(segue: UIStoryboardSegue) {}
    @IBAction func cancelAddSchedule () {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addBeertoInventory () {
        showPickerInActionSheet()
    }
    @IBAction func unwindToAddSchedule(segue: UIStoryboardSegue) {}
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        fetchBeerventoryBeers()
        populateEventDetails()
        self.descriptionTextView.delegate = self
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
    
    func showPickerInActionSheet() {
        pickerQuantity = "1"
        let message = "Enter quantity of beers to add\n\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.isModalInPopover = true
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame: CGRect = CGRect(x: 17, y: 52, width: 270, height: 160); // CGRectMake(left), top, width, height) - left and top are like margins
        let picker: UIPickerView = UIPickerView(frame: pickerFrame);
        //set the pickers datasource and delegate
        picker.delegate = self
        picker.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(picker)
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 200, width: 100, height: 30) //size & position of the button as placed on the toolView
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState.normal)
        buttonCancel.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(cancelSelection), for: UIControlEvents.touchDown)
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y:  200, width: 100, height: 30); //size & position of the button as placed on the toolView
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.addTarget(self, action: #selector(addBeers), for: UIControlEvents.touchDown);
        buttonOk.setTitle("Add", for: UIControlState.normal);
        buttonOk.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        alert.view.addSubview(buttonOk)
        alert.view.addSubview(buttonCancel)
        self.present(alert, animated: true, completion: nil);
    }
    
    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    
    func addBeers() {
        guard let quantity = Int(pickerQuantity) else {
            return
        }

        // handle new aws beers making sure exists in db
        guard let existingAWSBeer = beerventoryBeers.filter({$0._beerEntryId == beer.brewerydb_id}).first else {
            beer.quantity = quantity
            self.updateBreweryID(onCompletion: {
                self.updateBeerID(onCompletion: {
                    self.updateBeerUPC(onCompletion: {
                        print("Done adding beer")
                    })
                })
            })
            self.dismiss(animated: true, completion: {
                let alertController2 = UIAlertController(title: "\(self.beer.name) added", message: "You added \(self.beer.quantity) \(self.beer.name).", preferredStyle: UIAlertControllerStyle.alert)
                alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { action in
                    // should prob go back to main view controller here
                    self.insertAWSBeer(beer: self.beer)
                    self.dismiss(animated: true, completion: nil)
                })
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
            let alertController2 = UIAlertController(title: "\(self.beer.name) added", message: "You now have \(existingBeer.quantity) \(self.beer.name).", preferredStyle: UIAlertControllerStyle.alert)
            alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { action in
                self.dismiss(animated: true, completion: nil)
            })
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
    func updateBreweryID(onCompletion: @escaping () -> Void) {
        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
        if beer.brewery_id == "" {
            BrewerydbAPI.sharedInstance.add_brewery(breweryName: beer.brewery_name, onCompletion: { (json: JSON) in
                print(json)
                let newBreweryID = json["data"]["id"].string
                self.beer.brewery_id = newBreweryID!
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }
    
    func updateBeerID(onCompletion: @escaping () -> Void) {
        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
        if beer.brewerydb_id == "" {
            BrewerydbAPI.sharedInstance.add_beer(beer: beer, onCompletion: { (json: JSON) in
                print(json)
                let newBeerID = json["data"]["id"].string
                self.beer.brewerydb_id = newBeerID!
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }
    
    func updateBeerUPC(onCompletion: @escaping () -> Void) {
        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
        if beer.upc_code != "" {
            BrewerydbAPI.sharedInstance.add_beer_upc(beer: beer, onCompletion: { (json: JSON) in
                print(json)
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }
    
    func populateEventDetails() {
        if beer.name != "" {
            beerNameLabel.text = "\(beer.name) >"
        } else {
            beerNameLabel.text = "Choose Beer >"
        }
        if beer.brewery_name != "" {
            breweryNameLabel.text = "\(beer.brewery_name) >"
        } else {
            breweryNameLabel.text = "Choose Brewery >"
        }
        if beer.style_name != "" {
            styleNameLabel.text = "\(beer.style_name) >"
        } else {
            styleNameLabel.text = "Choose Style >"
        }
        if beer.upc_code != "" {
            upcCodeLabel.text = "\(beer.upc_code) >"
        } else {
            upcCodeLabel.text = "Scan Barcode >"
        }
        if beer.beer_description != "" {
            let desc = beer.beer_description
            descriptionLabel.text = "\(desc.substring(to: desc.index(desc.startIndex, offsetBy: 20)))..."
            descriptionTextView.text = beer.beer_description
        } else {
            descriptionLabel.text = "Enter Description"
            descriptionTextView.text = ""

        }
    }
    
    func showDescriptionTextViewCell(onComplete: () -> Void) {
        if showDescriptionTextView {
            showDescriptionTextView = false
            descriptionLabel.textColor = UIColor.lightGray
        }
        else {
            showDescriptionTextView = true
            descriptionLabel.textColor = UIColor.red
        }
        onComplete()
    }
    
    // MARK: - Override methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AddBeerNameController {
            viewController.currentBeer = beer
        }
        if let viewController = segue.destination as? AddBeerBreweryController {
            viewController.currentBeer = beer
        }
        if let viewController = segue.destination as? AddBeerStyleController {
            viewController.currentBeer = beer
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell == self.descriptionTextViewCell {
            if showDescriptionTextView == false {
                return 0
            } else {
                return 100
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            showDescriptionTextViewCell() {
                DispatchQueue.main.async(execute: {
                    tableView.reloadData()
                })
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddBeerViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            let desc = descriptionTextView.text!
            self.beer.beer_description = desc
            guard desc.characters.count > 20 else {
                descriptionLabel.text = "\(desc)"
                return
            }
            descriptionLabel.text = "\(desc.substring(to: desc.index(desc.startIndex, offsetBy: 20)))..."
        } else {
            descriptionLabel.text = "Enter Description"
        }
    }
}

// MARK: - UIPicker delegate
extension AddBeerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerQuantity = String(row + 1)
    }
}

// MARK: - UIPicker delegate
extension AddBeerViewController: UIPickerViewDataSource {
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

class AddBeerNewCell: UITableViewCell {
    
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var secondaryDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 10.0, *) {
            detailsLabel.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
    }
    
}

class AddBeerDetailsCell: UITableViewCell {
    
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var secondaryDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 10.0, *) {
            detailsLabel.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
    }
    
}

class AddBeerEmptyCell: UITableViewCell {
    
    @IBOutlet var lastCellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 10.0, *) {
            lastCellLabel.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
    }
    
}
