//
//  WelcomeScreen.swift
//  Beerventory
//
//  Created by Joel Whitney on 6/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileHubHelper

class WelcomeScreen: UIViewController {

    @IBOutlet var signOutButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userID: UILabel!
    
    // MARK: view transition overrides
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        configureProfile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProfile()
        presentSignInViewController()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "beer_foam140down.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        signOutButton.addTarget(self, action: #selector(WelcomeScreen.handleLogout), for: .touchUpInside)
    }
    
    func configureProfile() {
        let identityManager = AWSIdentityManager.default()
        identityManager.identityProfile?.load()
        print("Currently signed in as: \( identityManager.identityProfile?.userName)")
        if let identityUserName = identityManager.identityProfile?.userName {
            userName.text = identityUserName
        } else {
            userName.text = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        userID.text = identityManager.identityId
        
        if let imageURL = identityManager.identityProfile?.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                userImageView.image = profileImage.circleMasked
            } else {
                userImageView.image = UIImage(named: "UserIcon")
            }
        } else {
            userImageView.image = UIImage(named: "UserIcon")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            //self.setupRightBarButtonItem()
        } else {
            // handle cancel operation from user
        }
    }

    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController: SignInViewController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            loginController.canCancel = false
            loginController.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: loginController)
            navigationController?.present(navController, animated: true, completion: nil)
        } else {
            self.configureProfile()
        }
    }
    func handleLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.configureProfile()
                self.navigationController!.popToRootViewController(animated: false)
                self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }
}
