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
        print("Main LOADED")
        self.panelPosition = .partial
        scanViewController?.scanResultsFound = { beers in
            self.panelPosition = .full
            print(beers)
            self.searchResultsViewController?.updateWithScanResults(beers: beers)
        }
//        searchResultsViewController?.searchResultTapped = { beer in
//            self.searchResultBeer = beer
//            self.performSegue(withIdentifier: "detailsViewController", sender: self)
//        }
  
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
    
    var scanViewController: ScanViewController? {
        return childViewControllers.first(where: { $0 is ScanViewController }) as? ScanViewController
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
