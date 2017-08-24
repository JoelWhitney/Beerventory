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
        scanViewController?.scanResultFound = { beers in
            self.panelPosition = .full
            print(beers)
            self.searchResultsViewController?.updateWithScanResults(beers: beers) {
                DispatchQueue.main.async(execute: {
                    print("reload searchResultsController tableview")
                    self.searchResultsViewController?.tableView.reloadData()
                    print(self.searchResultsViewController?.scanBeerStore)
                })
            }
        }
        searchResultsViewController?.searchResultTapped = { beer in
            self.searchResultBeer = beer
            self.performSegue(withIdentifier: "detailsViewController", sender: self)
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
