//
//  ScanBeerTableCell.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit

class ScanBeerTableCell: UITableViewCell {

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
