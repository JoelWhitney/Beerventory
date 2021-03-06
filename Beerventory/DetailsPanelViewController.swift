//
//  DetailsPanelViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 11/24/17.
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileClient
import AWSCore

class DetailsPanelViewController: UIViewController {
    // MARK: - variables/constants
    var beer: Beer!
    let gradientLayer = CAGradientLayer()
    
    // MARK: Outlets
    @IBOutlet var beerNameLabel: UILabel!
    @IBOutlet var beerStyle: UILabel!
    @IBOutlet var breweryNameLabel: UILabel!
    @IBOutlet var abvLabel: UILabel!
    @IBOutlet var beerDescription: UITextView!
    @IBOutlet var beerLabel: UIImageView!
    @IBOutlet var gradiantView: UIView!
    
    // MARK: Actions
    
    // MARK: Initializers
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fillKnownDetails()
        createTopBanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        beerDescription.setContentOffset(CGPoint.zero, animated: false)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        addTransparentBanner()
        CATransaction.commit()
    }
    
    @IBAction func close(_ sender: Any) {
        performSegue(withIdentifier: "unwindToSearchResultsViewController", sender: nil)
    }
    
    // MARK: Imperative methods
    func fillKnownDetails() {
        // get dict info and fill in
        if beer.name == "" {
            beerNameLabel.text = "[beer name]"
        } else {
            beerNameLabel.text = beer.name
        }
        if beer.brewery_name == "" {
            breweryNameLabel.text = "[brewery name]"
        } else {
            breweryNameLabel.text = beer.brewery_name
        }
        if beer.style_name == "" {
            beerStyle.text = "[style]"
        } else {
            beerStyle.text = beer.style_name
        }
        if beer.abv == "" {
            abvLabel.text = "[abv]"
        } else {
            abvLabel.text = "\(beer.abv)%"
        }
        if beer.beer_description == "" {
            beerDescription.text = "[description]"
        } else {
            beerDescription.text = beer.beer_description
        }
    }
    func createTopBanner(){
        beerLabel.downloadedFrom(link: beer.label)
    }
    
    func addTransparentBanner() {
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9).cgColor
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = gradiantView.bounds
        gradiantView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}


