//
//  ViewController.swift
//  sliding-panel
//
//  Created by Jeff Jackson on 3/10/17.
//  Copyright © 2017 Jeff Jackson. All rights reserved.
//

import UIKit

@objc enum SlidingPanelPosition: Int {
    case hidden
    case summary
    case partial
    case full
}

class SlidingPanelViewController: UIViewController {

    @IBOutlet weak var primaryContainerView: UIView!
    @IBOutlet weak var panelContainerView: UIView!
    @IBOutlet weak var slidingPanelTopConstraint: NSLayoutConstraint!

    var lastPanPoint = CGPoint.zero
    var touchInsideScrollView = false
    let animationDuration = 0.3


    override func loadView() {
        super.loadView()
        updateSlidingPanelPosition()

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSlidingPanelPanGesture))
        panRecognizer.delegate = self
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panelContainerView.addGestureRecognizer(panRecognizer)

        panelContainerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        panelContainerView.layer.borderWidth = 0.5
        panelContainerView.layer.cornerRadius = 10
        panelContainerView.clipsToBounds = true

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
            //return provider.summaryHeight ?? defaultHeight
            return defaultHeight
        }

        return defaultHeight
    }

    var slidingPanelPartialHeight: CGFloat {
        let defaultHeight = (view.frame.height - topLayoutGuide.length) / 2

        if let provider = childViewControllers.last as? SlidingPanelContentProvider {
            //return provider.partialHeight ?? defaultHeight
            return defaultHeight
        }

        return defaultHeight
    }

    var slidingPanelFullHeight: CGFloat {
        return view.frame.height - topLayoutGuide.length - 70
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
                slidingPanelTopConstraint.constant = min(max(newTop, slidingPanelSummaryHeight), slidingPanelFullHeight)
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

                } else if top < (slidingPanelSummaryHeight + slidingPanelPartialHeight) / 2 {
                    panelPosition = .summary
                } else {
                    panelPosition = .partial
                }
            } else {
                if top > slidingPanelPartialHeight {
                    panelPosition = velocity > 0 ? .partial : .full
                } else {
                    panelPosition = velocity > 0 ? .summary : .partial
                }
            }

            let duration = animationDuration(from: slidingPanelTopConstraint.constant, to: top)
            UIView.springAnimate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })

            if panelPosition != .full {
                if let scrollView = contentScrollView {
                    scrollView.setContentOffset(CGPoint.zero, animated: true)
                }
            }
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


