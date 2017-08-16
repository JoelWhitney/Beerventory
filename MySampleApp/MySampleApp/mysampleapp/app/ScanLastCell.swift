//
//  ScanLastCell.swift
//  Beerventory
//
//  Created by Joel Whitney on 3/5/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit

class ScanLastCell: UITableViewCell {
    
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
