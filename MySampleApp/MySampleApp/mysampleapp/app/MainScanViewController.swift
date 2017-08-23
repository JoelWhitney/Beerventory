//
//  MainScanViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/22/17.
//

import Foundation
import UIKit

class MainScanViewController: SlidingPanelViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.panelPosition = .partial
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
//        scanViewController?.beersFound = { worker in
//            if worker.location != nil {
//                self.panelPosition = .partial
//                self.mapViewController?.highlight(worker: worker)
//            }
//        }
//
//        scanViewController?.filterHandler = { filterText in
//            self.mapViewController?.applyFilter(filterText)
//        }
//
  
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
    
    var searchResultsViewController: SearchResultsViewController? {
        return childViewControllers.first(where: { $0 is SearchResultsViewController }) as? SearchResultsViewController
    }
    
}
