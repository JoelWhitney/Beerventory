//
//  SlidingPanelViewController.swift
//  MySampleApp
//
//  Created by Joel Whitney on 11/7/17.
//  Copyright © 2017 JoelWhitney. All rights reserved.
//

import UIKit
import Foundation

@objc enum SlidingPanelPosition: Int {
    case hidden
    case summary
    case partial
    case full
}

class SlidingPanelViewController: UIViewController {
    
    @IBOutlet weak var primaryContainerView: UIView!
    @IBOutlet weak var panelContainerView: UIView!
    
    @IBOutlet var slidingPanelTopConstraint: NSLayoutConstraint!
    
    var lastPanPoint = CGPoint.zero
    var touchInsideScrollView = false
    let animationDuration = 0.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLayoutConstraint.deactivate(view.constraints + primaryContainerView.constraints + panelContainerView.constraints)
        
        primaryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        primaryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        primaryContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        primaryContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        panelContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        panelContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        panelContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        
        slidingPanelTopConstraint = view.bottomAnchor.constraint(equalTo: panelContainerView.topAnchor, constant: 0)
        slidingPanelTopConstraint.isActive = true
        
        updateSlidingPanelPosition()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSlidingPanelPanGesture))
        panRecognizer.delegate = self
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panelContainerView.addGestureRecognizer(panRecognizer)
        
        panelContainerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        panelContainerView.layer.borderWidth = 0.5
        panelContainerView.layer.cornerRadius = 10
        panelContainerView.layer.masksToBounds = true
        
        let shadowView = UIView(frame: panelContainerView.frame)
        shadowView.backgroundColor = .white
        shadowView.layer.shadowOpacity = 0.08
        shadowView.layer.shadowRadius = 4
        shadowView.layer.cornerRadius = 10
        shadowView.layer.masksToBounds = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(shadowView, belowSubview: panelContainerView)
        shadowView.leadingAnchor.constraint(equalTo: panelContainerView.leadingAnchor).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: panelContainerView.trailingAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: panelContainerView.topAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: panelContainerView.bottomAnchor).isActive = true
    }
    
    var panelPosition: SlidingPanelPosition = .partial {
        didSet {
            updateSlidingPanelPosition()
            
            if let scrollView = contentScrollView, panelPosition != .full {
                scrollView.setContentOffset(CGPoint.zero, animated: true)
            }
            
            let duration = animationDuration(from: heightForPosition(oldValue), to: heightForPosition(panelPosition))
            UIView.springAnimate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var slidingPanelSummaryHeight: CGFloat {
        let defaultHeight: CGFloat = 100
        
        if let provider = childViewControllers.last as? SlidingPanelContentProvider {
            return provider.summaryHeight ?? defaultHeight
        }
        
        return defaultHeight
    }
    
    var slidingPanelPartialHeight: CGFloat {
        let defaultHeight = view.frame.height / 2
        
        if let provider = childViewControllers.last as? SlidingPanelContentProvider {
            return provider.partialHeight ?? defaultHeight
        }
        
        return defaultHeight
    }
    
    var slidingPanelFullHeight: CGFloat {
        return view.frame.height - topLayoutGuide.length - 24
    }
    
    internal func updateSlidingPanelPosition() {
        
        switch panelPosition {
        case .hidden:
            slidingPanelTopConstraint.constant = 0
        case .summary:
            slidingPanelTopConstraint.constant = slidingPanelSummaryHeight
        case .partial:
            slidingPanelTopConstraint.constant = slidingPanelPartialHeight
        case .full:
            slidingPanelTopConstraint.constant = slidingPanelFullHeight
        }
    }
    
    @objc func handleSlidingPanelPanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            lastPanPoint = gestureRecognizer.translation(in: panelContainerView)
            touchInsideScrollView = contentScrollView?.point(inside: gestureRecognizer.location(in: contentScrollView), with: nil) ?? false
            
            if let top = childViewControllers.last {
                top.view.endEditing(true)
            }
        }
        
        if gestureRecognizer.state == .changed {
            let point = gestureRecognizer.translation(in: panelContainerView)
            let newTop = slidingPanelTopConstraint.constant - point.y + lastPanPoint.y
            let contentOffset = contentScrollView?.contentOffset.y ?? 0
            
            if contentOffset <= 0 || !touchInsideScrollView {
                slidingPanelTopConstraint.constant = min(max(newTop, slidingPanelPartialHeight), slidingPanelFullHeight)
            }
            lastPanPoint = point
        }
        
        if gestureRecognizer.state == .ended {
            let contentOffset = contentScrollView?.contentOffset.y ?? 0
            if contentOffset > 0 && touchInsideScrollView {
                return
            }
            
            let velocity = gestureRecognizer.velocity(in: panelContainerView).y
            let top = slidingPanelTopConstraint.constant
            
            if abs(velocity) < 100 {
                if top > (slidingPanelPartialHeight + slidingPanelFullHeight) / 2 {
                    panelPosition = .full
                    
                } else {
                    panelPosition = .partial
                }
            } else {
                if top > slidingPanelPartialHeight {
                    panelPosition = velocity > 0 ? .partial : .full
                } else {
                    panelPosition = .partial
                }
            }
            
            let duration = animationDuration(from: slidingPanelTopConstraint.constant, to: top)
            UIView.springAnimate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
            
            guard let scrollView = contentScrollView else {
                return
            }
            
            // if we aren't full, make sure we show the top of the scrollView's content
            // [BUG] before setting the final position, set an offset of -1 to work around a weird
            // issue with table views that makes them ignore the first touch following this
            // gesture ending
            //
            let offset = panelPosition == .full ? scrollView.contentOffset : CGPoint.zero
            scrollView.setContentOffset(CGPoint(x: 0, y: -1), animated: true)
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    func add(panel panelViewController: UIViewController) {
        panelViewController.loadViewIfNeeded()
        panelViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        addChildViewController(panelViewController)
        panelViewController.view.frame = panelContainerView.bounds
        panelViewController.view.transform = CGAffineTransform(translationX: 0, y: panelViewController.view.frame.height)
        
        panelContainerView.addSubview(panelViewController.view)
        panelViewController.didMove(toParentViewController: self)
        
        panelViewController.view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // prevent scrolling while animating
        //
        let scrollView = (panelViewController as? SlidingPanelContentProvider)?.contentScrollView
        scrollView?.isScrollEnabled = false
        
        
        UIView.animate(withDuration: animationDuration, animations: {
            panelViewController.view.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }) { _ in
            scrollView?.isScrollEnabled = true
        }
    }
    
    func remove(panel panelViewController: UIViewController) {
        assert(childViewControllers.contains(panelViewController))
        
        UIView.animate(withDuration: animationDuration, animations: {
            
            panelViewController.view.transform = CGAffineTransform(translationX: 0, y: panelViewController.view.frame.height)
            self.view.layoutIfNeeded()
        }) { _ in
            panelViewController.willMove(toParentViewController: nil)
            panelViewController.view.removeFromSuperview()
            panelViewController.removeFromParentViewController()
        }
    }
    
    func animationDuration(from: CGFloat, to: CGFloat) -> Double {
        if fabs(from - to) > fabs(slidingPanelFullHeight - slidingPanelPartialHeight) {
            return animationDuration
        }
        
        return animationDuration / 2
    }
    
    func heightForPosition(_ position: SlidingPanelPosition) -> CGFloat {
        switch position {
        case .full:
            return slidingPanelFullHeight
        case .partial:
            return slidingPanelPartialHeight
        case .summary:
            return slidingPanelSummaryHeight
        case .hidden:
            return 0
        }
    }
    
    var contentScrollView: UIScrollView? {
        if let provider = childViewControllers.last as? SlidingPanelContentProvider {
            return provider.contentScrollView
        }
        return nil
    }
    
    func panelContentDidScroll(_ viewController: UIViewController, scrollView: UIScrollView) {
        if slidingPanelTopConstraint.constant != slidingPanelFullHeight {
            scrollView.contentOffset = CGPoint.zero
        }
    }
    
    func panelContentWillBeginDecelerating(_ viewController: UIViewController, scrollView: UIScrollView) {
        if slidingPanelTopConstraint.constant != slidingPanelFullHeight {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateSlidingPanelPosition()
    }
}

extension SlidingPanelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// Optional protocol that a view controller can implement in order for its scrollable content
// to coordinate with the scrolling of the sliding panel.
//
@objc public protocol SlidingPanelContentProvider {
    var contentScrollView: UIScrollView? { get }
    @objc optional var summaryHeight: CGFloat { get }
    @objc optional var partialHeight: CGFloat { get }
}


extension UIView {
    
    static func springAnimate(withDuration duration: TimeInterval, animations: @escaping (()->Void)) {
        UIView.springAnimate(withDuration: duration, animations: animations, completion: nil)
    }
    
    static func springAnimate(withDuration duration: TimeInterval, animations: @escaping (()->Void), completion: ((Bool) ->Void)? = nil) {
        UIView.animate(withDuration: duration * 2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .curveEaseInOut], animations: animations, completion: completion)
    }
}
