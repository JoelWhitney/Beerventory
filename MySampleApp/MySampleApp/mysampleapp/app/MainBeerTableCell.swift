//
//  MainBeerTableCell.swift
//  Beerventory
//
//  Created by Joel Whitney on 6/22/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit

class MainBeerTableCell: UITableViewCell {
    
    @IBOutlet var beerNameLabel: UILabel!
    @IBOutlet var beerStyle: UILabel!
    @IBOutlet var breweryNameLabel: UILabel!
    @IBOutlet var abvLabel: UILabel!
    @IBOutlet var gravityLabel: UILabel!
    @IBOutlet var beerQuantity: UILabel!
    
    @IBOutlet var shadowLayer: UIView!
    @IBOutlet var mainBackground: UIView!
    @IBOutlet var totalBackground: UIView!

    @IBOutlet var addBeerButton: UIButton!
    @IBOutlet var removeBeerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
