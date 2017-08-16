//
//  BeerDetailsController.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit

class BeerDetailsController: UIViewController {
    
    @IBOutlet var beerDetails: UITextView!
    var beer: Beer!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        beerDetails.text = beer.beerObjectDescription()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
    }
    override func viewWillAppear(_ animated: Bool) {
        print("BeerDetailsController will appear")
    }
}
