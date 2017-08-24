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


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
