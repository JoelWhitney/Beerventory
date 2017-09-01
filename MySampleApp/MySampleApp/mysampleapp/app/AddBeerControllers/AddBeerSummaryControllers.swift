////
////  AddBeerSummaryController.swift
////  Beerventory
////
////  Created by Joel Whitney on 7/4/17.
////  Copyright © 2017 Joel Whitney. All rights reserved.
////
//
//import Foundation
//import UIKit
//import RxSwift
//import SwiftyJSON
//
//class AddBeerSummaryController: UIViewController {
//    // MARK: - variables/constants
//    var newBeer: Beer {
//        get {
//            let tabController = self.tabBarController as? TabBarController
//            return tabController!.newBeer
//        }
//        set {
//            let tabController = self.tabBarController as? TabBarController
//            print("SETTING!!!")
//            print(tabController!.newBeer)
//            tabController!.newBeer = newValue
//            print(newValue.beer_description)
//        }
//    }
//    var pickerQuantity = "1"
//    var alertTextField = UITextField()
//    var mainBeerStore: BeerStore {
//        let tabController = self.tabBarController as? TabBarController
//        return tabController!.mainBeerStore
//    }
//
//    // MARK: Outlets
//    @IBOutlet var addBeersButton: UIButton!
//    @IBOutlet var beerNameLabel: UILabel!
//    @IBOutlet var beerStyle: UILabel!
//    @IBOutlet var breweryNameLabel: UILabel!
//    @IBOutlet var abvLabel: UILabel!
//    @IBOutlet var beerDescription: UITextView!
//    @IBOutlet var beerLabel: UIImageView!
//    @IBOutlet var gradiantView: UIView!
//    
//    // MARK: Actions
//    
//    // MARK: Initializers
//    
//    // MARK: View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fillKnownDetails()
//        
//        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
//        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9).cgColor
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [ colorTop, colorBottom]
//        gradientLayer.locations = [ 0.0, 1.0]
//        gradientLayer.frame = gradiantView.bounds
//        gradiantView.layer.insertSublayer(gradientLayer, at: 0)
//        
//        beerLabel.downloadedFrom(link: newBeer.label)
//        addBeersButton.addTarget(self, action: #selector(AddBeerSummaryController.showPickerInActionSheet), for: .touchUpInside)
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//    // MARK: Additional views
//    
//    // MARK: Imperative methods
//
//    func showPickerInActionSheet() {
//        pickerQuantity = "1"
//        let message = "Enter quantity of beers to add\n\n\n\n\n\n\n\n\n\n"
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
//        alert.isModalInPopover = true
//        //Create a frame (placeholder/wrapper) for the picker and then create the picker
//        let pickerFrame: CGRect = CGRect(x: 17, y: 52, width: 270, height: 160); // CGRectMake(left), top, width, height) - left and top are like margins
//        let picker: UIPickerView = UIPickerView(frame: pickerFrame);
//        //set the pickers datasource and delegate
//        picker.delegate = self
//        picker.dataSource = self
//        //Add the picker to the alert controller
//        alert.view.addSubview(picker)
//        //add buttons to the view
//        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 200, width: 100, height: 30) //size & position of the button as placed on the toolView
//        //Create the cancel button & set its title
//        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
//        buttonCancel.setTitle("Cancel", for: UIControlState.normal)
//        buttonCancel.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
//        //Add the target - target, function to call, the event witch will trigger the function call
//        buttonCancel.addTarget(self, action: #selector(cancelSelection), for: UIControlEvents.touchDown)
//        //add buttons to the view
//        let buttonOkFrame: CGRect = CGRect(x: 170, y:  200, width: 100, height: 30); //size & position of the button as placed on the toolView
//        //Create the Select button & set the title
//        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
//        buttonOk.addTarget(self, action: #selector(addBeers), for: UIControlEvents.touchDown);
//        buttonOk.setTitle("Add", for: UIControlState.normal);
//        buttonOk.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
//        alert.view.addSubview(buttonOk)
//        alert.view.addSubview(buttonCancel)
//        self.present(alert, animated: true, completion: nil);
//    }
//    func updateBreweryID(onCompletion: @escaping () -> Void) {
//        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
//        if newBeer.brewery_id == "" {
//            BrewerydbAPI.sharedInstance.add_brewery(breweryName: newBeer.brewery_name, onCompletion: { (json: JSON) in
//                print(json)
//                let newBreweryID = json["data"]["id"].string
//                self.newBeer.brewery_id = newBreweryID!
//                onCompletion()
//            })
//        } else {
//            onCompletion()
//        }
//    }
//    func updateBeerID(onCompletion: @escaping () -> Void) {
//        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
//        if newBeer.brewerydb_id == "" {
//            BrewerydbAPI.sharedInstance.add_beer(beer: newBeer, onCompletion: { (json: JSON) in
//                print(json)
//                let newBeerID = json["data"]["id"].string
//                self.newBeer.brewerydb_id = newBeerID!
//                onCompletion()
//            })
//        } else {
//            onCompletion()
//        }
//    }
//    func updateBeerUPC(onCompletion: @escaping () -> Void) {
//        // if brewery_id is empty -- add brewery and update newBeer with brewery_id
//        if newBeer.upc_code != "" {
//            BrewerydbAPI.sharedInstance.add_beer_upc(beer: newBeer, onCompletion: { (json: JSON) in
//                print(json)
//                onCompletion()
//            })
//        } else {
//            onCompletion()
//        }
//    }
//    func addBeers(sender: UIButton) {
//        print("Adding")
//        guard let quantity = Int(pickerQuantity) else {
//            // handle bad no value or text entry
//            return
//        }
//        // if beer exists update quantity
//        guard let existingBeer = mainBeerStore.allBeers.value.filter({$0.brewerydb_id == newBeer.brewerydb_id}).first else {
//            newBeer.quantity = quantity
//            // Make post request HERE and do the following in completion
//            self.updateBreweryID(onCompletion: {
//                // if brewerydb_id is empty -- add and update newBeer with brewerydb_id
//                self.updateBeerID(onCompletion: {
//                    // if upc is NOT empty -- update brewerdb_id with newBeer upc_code
//                    self.updateBeerUPC(onCompletion: {
//                        print("Done adding beer")
//                    })
//                })
//            })
//            mainBeerStore.addBeerObject(beer: newBeer)
//            self.dismiss(animated: true, completion: {
//                let alertController2 = UIAlertController(title: "\(self.newBeer.name) added", message: "You added \(self.newBeer.quantity) \(self.newBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
//                alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { action in
//                        // should prob go back to main view controller here
//                    })
//                self.present(alertController2, animated: true, completion: nil)
//            })
//            return
//        }
//        existingBeer.quantity += quantity
//        // add beer to mainstore
//        mainBeerStore.updateBeerQuantity(updatedBeer: existingBeer)
//        self.dismiss(animated: true, completion: {
//            let alertController2 = UIAlertController(title: "Beers added", message: "You now have \(existingBeer.quantity) \(self.newBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
//            alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { action in
//                // should prob go back to main view controller here
//            })
//            self.present(alertController2, animated: true, completion: nil)
//        })
//    }
//    func cancelSelection(sender: UIButton){
//        print("Cancel");
//        self.dismiss(animated: true, completion: nil);
//        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
//    }
//    func fillKnownDetails() {
//        // get dict info and fill in
//        if newBeer.name == "" {
//            beerNameLabel.text = "[beer name]"
//        } else {
//            beerNameLabel.text = newBeer.name
//        }
//        if newBeer.brewery_name == "" {
//            breweryNameLabel.text = "[brewery name]"
//        } else {
//            breweryNameLabel.text = newBeer.brewery_name
//        }
//        if newBeer.style_name == "" {
//            beerStyle.text = "[style]"
//        } else {
//            beerStyle.text = newBeer.style_name
//        }
//        if newBeer.abv == "" {
//            abvLabel.text = "[abv]"
//        } else {
//            abvLabel.text = "\(newBeer.abv)%"
//        }
//        if newBeer.beer_description == "" {
//            beerDescription.text = "[description]"
//        } else {
//            beerDescription.text = newBeer.beer_description
//        }
//    }
//}
//
//// MARK: - UIPicker delegate
//extension AddBeerSummaryController: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        pickerQuantity = String(row + 1)
//    }
//}
//
//// MARK: - UIPicker delegate
//extension AddBeerSummaryController: UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 30
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        print(row)
//        return String(row + 1)
//    }
//}
//
//extension UIImageView {
//    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
//        contentMode = mode
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard
//                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//                let data = data, error == nil,
//                let image = UIImage(data: data)
//                else { return }
//            DispatchQueue.main.async() { () -> Void in
//                self.image = image
//            }
//            }.resume()
//    }
//    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
//        guard let url = URL(string: link) else { return }
//        downloadedFrom(url: url, contentMode: mode)
//    }
//}

