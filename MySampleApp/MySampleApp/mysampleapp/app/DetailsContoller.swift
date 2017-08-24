//
//  DetailsContoller.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/22/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit



class DetailsController: UIViewController {
    // MARK: - variables/constants
    var beer: Beer!
    
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = gradiantView.bounds
        gradiantView.layer.insertSublayer(gradientLayer, at: 0)
        beerLabel.downloadedFrom(link: beer.label)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        beerDescription.setContentOffset(CGPoint.zero, animated: false)
    }
    // MARK: Additional views
    
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
}
