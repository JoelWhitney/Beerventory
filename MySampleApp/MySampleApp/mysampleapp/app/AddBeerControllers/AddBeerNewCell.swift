//
//  AddBeerNewCell.swift
//  Beerventory
//
//  Created by Joel Whitney on 7/18/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit

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
