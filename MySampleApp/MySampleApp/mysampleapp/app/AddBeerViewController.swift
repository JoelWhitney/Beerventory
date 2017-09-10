//
//  AddBeerViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 9/1/17.
//

import Foundation
import UIKit
import SwiftyJSON

class AddBeerViewController: UITableViewController {
    // MARK: - Variables
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
//        guard foodTruck != nil, entryLocation != nil else {
//            let alertController = UIAlertController(title: "Error", message: "Make sure all fields have been chose.", preferredStyle: UIAlertControllerStyle.alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//            present(alertController, animated: true, completion: nil)
//            return
//        }
//        let foodTruckScheduleEntry = FoodTruckScheduleEntry(foodTruck: foodTruck, location: entryLocation,
//                                                            start: startDate, end: endDate)
//        let alertMsg = "Location: \(entryLocation.name)\r\nStart: \(returnDatePickerLabel(date: startDate))\r\nEnd: \(returnDatePickerLabel(date: endDate))"
//        let alertController = UIAlertController(title: "Add Event to Schedule",
//                                                message: alertMsg,
//                                                preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
//        let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { action in
//            FoodTruckAPI.sharedInstance.postScheduleEntry(entry: foodTruckScheduleEntry, onCompletion: { (json: JSON) in
//                print(json)
//                self.dismiss(animated: true, completion: nil)
//            })
//        }
//        alertController.addAction(add)
//        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        populateEventDetails()
    }
    
    // MARK: - Methods
    func returnDatePickerLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "MMM d, yyyy  h:mm a"
        return formatter.string(from: date)
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
        // LEFT OFF HERE!!!
//        if beer.beer_description != "" {
//            b.text = "\(beer.upc_code) >"
//        } else {
//            upcCodeLabel.text = "Scan Barcode >"
//        }
        //descriptionTextView.addTarget(self, action: #selector(startDateValueChanged), for: UIControlEvents.valueChanged)
        
    }
    
//    @objc func startDateValueChanged() {
//        beer.beer_description = descriptionTextView.text
//    }
//
//    @objc func endDateValueChanged() {
//        endDate = endDatePicker.date
//        endDateLabel.text = returnDatePickerLabel(date: endDate)
//    }
//
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell == self.descriptionTextViewCell, showDescriptionTextView == false {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            showDescriptionTextViewCell() {
                DispatchQueue.main.async(execute: {
                    tableView.reloadData()
                })
            }
        }
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

