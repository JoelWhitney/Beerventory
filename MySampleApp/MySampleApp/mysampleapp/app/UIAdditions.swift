//
//  UIAdditions.swift
//  MySampleApp
//
//  Created by Joel Whitney on 8/22/17.
//

import Foundation
import UIKit

extension UIView {
    
    static func springAnimate(withDuration duration: TimeInterval, animations: @escaping (()->Void)) {
        UIView.springAnimate(withDuration: duration, animations: animations, completion: nil)
    }
    
    static func springAnimate(withDuration duration: TimeInterval, animations: @escaping (()->Void), completion: ((Bool) ->Void)? = nil) {
        UIView.animate(withDuration: duration * 2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .curveEaseInOut], animations: animations, completion: completion)
    }
}
