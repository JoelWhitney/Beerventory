//
//  MainScanViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/22/17.
//

import Foundation
import UIKit

class MainScanViewController: SlidingPanelViewController {

    var searchResultBeer: Beer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.panelPosition = .partial
        scanViewController2?.scanResultsFound = { beers in
            self.panelPosition = .full
            print(beers)
            self.searchResultsViewController?.updateWithScanResults(beers: beers)
        }
    }
    
    override var slidingPanelFullHeight: CGFloat {
        return super.slidingPanelFullHeight
    }
    
    override var slidingPanelPartialHeight: CGFloat {
        return super.slidingPanelPartialHeight
    }
    
    override func updateSlidingPanelPosition() {
        super.updateSlidingPanelPosition()
    }

    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
    }
    
    var scanViewController2: ScanViewController2? {
        return childViewControllers.first(where: { $0 is ScanViewController2 }) as? ScanViewController2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailsViewController") {
            let yourNextViewController = (segue.destination as! DetailsController)
            yourNextViewController.beer = searchResultBeer
        }
        
    }
    var searchResultsViewController: SearchResultsViewController? {
        return childViewControllers.first(where: { $0 is SearchResultsViewController }) as? SearchResultsViewController
    }
    
}
