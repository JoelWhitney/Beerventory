//
//  SlidingPanelSegue.swift
//  MySampleApp
//
//  Created by Joel Whitney on 11/24/17.
//

import UIKit

class SlidingPanelSegue: UIStoryboardSegue {
    override func perform() {
        guard let slidingPanelViewController = source.parent as? SlidingPanelViewController else {
            return
        }
        
        slidingPanelViewController.add(panel: destination)
    }
}

class SlidingPanelUnwindSegue: UIStoryboardSegue {
    override func perform() {
        guard let slidingPanelViewController = source.parent as? SlidingPanelViewController,
            let index = slidingPanelViewController.childViewControllers.index(of: destination) else {
                return
        }
        
        let startIndex = index.advanced(by: 1)
        let viewControllersToBeRemoved = slidingPanelViewController.childViewControllers[startIndex...]
        viewControllersToBeRemoved.forEach { slidingPanelViewController.remove(panel: $0) }
    }
}
