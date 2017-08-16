//
//  AddBeerDetailsController.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/9/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit

class AddBeerDetailsController: UIViewController {
    // MARK: - variables/constants
    let tabControllerIndex = 3
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
    
    // MARK: Outlets
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var shadowLayer: UIView!
    @IBOutlet var mainBackground: UIView!
    // details outlets
    @IBOutlet var beerDescription: UITextView!
    @IBOutlet var beerAbv: UITextField!
    @IBOutlet var beerUPC: UITextField!
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
        beerDescription.delegate = self
        beerAbv.delegate = self
        beerUPC.delegate = self
        // status bar
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor(red: 235/255, green: 171/255, blue: 28/255, alpha: 1)
        continueButton.addTarget(self, action: #selector(AddBeerDetailsController.tabControllerContinue), for: .touchUpInside)
        // other crap
        fillKnownDetails()
        formatSummaryCell()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    func checkRequirements() -> Bool {
        var result = false
        // if requirements satisfied result = true
        return result
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
            beerAbv.placeholder = "[abv]"
        } else {
            abvLabel.text = "\(newBeer.abv)%"
            beerAbv.text = newBeer.abv
        }
        if newBeer.upc_code == "" {
            beerUPC.placeholder = "[upc_code]"
        } else {
            beerUPC.text = newBeer.upc_code
        }
        beerDescription.text = newBeer.beer_description
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

extension AddBeerDetailsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddBeerDetailsController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
