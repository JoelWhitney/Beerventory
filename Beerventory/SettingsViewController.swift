//
//  UserIdentityViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.18
//

import Foundation
import UIKit
import AWSDynamoDB
import AWSMobileClient
import AWSCore
import QuartzCore

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var buildLabel: UILabel!

    @IBOutlet var removeAllBeersButton: UIButton!
    let version: String? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String?
    let build: String? = Bundle.main.infoDictionary!["CFBundleVersion"] as! String?
    var mainBeerStore = [AWSBeer]()
    // MARK: - View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                        NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)]
        self.configureProfile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureProfile()
        versionLabel.text = version
        buildLabel.text = build
        signOutButton.addTarget(self, action: #selector(SettingsViewController.handleLogout), for: .touchUpInside)
        removeAllBeersButton.addTarget(self, action: #selector(SettingsViewController.removeAllBeers), for: .touchUpInside)
        tableView.tableFooterView = UIView()
            
    }
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        var imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        var roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
    @objc func removeAllBeers() {
        let title = "Remove all beers from inventory"
        let message = "Are you sure you want to remove all of your beers?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Remove", style: .destructive, handler: {
            (action) -> Void in
            DynamodbAPI.sharedInstance.removeAllBeers() {
                print("done deleting")
            }
        })
        ac.addAction(deleteAction)
        present(ac, animated: true, completion: nil)
    }
    func configureProfile() {
        let identityManager = AWSIdentityManager.default()
        print(identityManager.logins())
        print(identityManager.credentialsProvider)
        if let identityUserName = identityManager.identityId {
            userName.text = identityUserName
        } else {
            userName.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }

        userID.text = identityManager.identityId
//        if let imageURL = identityManager.  identityProfile?.imageURL {
//            let imageData = try! Data(contentsOf: imageURL)
//            if let profileImage = UIImage(data: imageData) {
//                userImageView.image = profileImage.circleMasked
//            } else {
//                userImageView.image = UIImage(named: "UserIcon")
//            }
//        } else {
//                userImageView.image = UIImage(named: "UserIcon")
//        }
        userImageView.image = UIImage(named: "UserIcon")
    }

    @objc func handleLogout() {
        AWSSignInManager.sharedInstance().logout(completionHandler: { (result: Any?, error: Error?) in
            if let erro = error {
                print("error: \(erro)")
            } else {
                print("result: \(result)")
            }
        })
    }

}

extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

