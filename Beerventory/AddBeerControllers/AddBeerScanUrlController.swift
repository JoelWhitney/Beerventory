//
//  AddBeerScanUrlController.swift
//  Beerventory
//
//  Created by Joel Whitney on 12/16/17.
//  Copyright © 2017 JoelWhitney. All rights reserved.
//

/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 View controller for camera interface.
 */

import UIKit
import AVFoundation
import SwiftyJSON
import AWSDynamoDB
import AWSMobileClient
import AWSCore

class AddBeerScanUrlController: UIViewController {
    // MARK: - variables/constants
    var mainBeerStore = [AWSBeer]()
    var scanResultsBeers = [Beer]()
    var currentAWSBeer: AWSBeer!
    var currentBeer: Beer!
    var currentBeerIndexPath: IndexPath!
    var alertTextField = UITextField()
    weak var actionToEnable : UIAlertAction?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.itf14,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.dataMatrix,
                              AVMetadataObject.ObjectType.interleaved2of5]
    var pickerQuantity = "1"
    var upc_code = ""
    var scanResultsFound: (([Beer]) -> Void)?
    
    // MARK: Session Management
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    var defaultVideoDevice: AVCaptureDevice?
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    
    let results = AVCaptureMetadataOutput()
    let metadataObjectsQueue = DispatchQueue(label: "metadata objects queue", attributes: [], target: nil)
    
    @IBOutlet private var previewView: PreviewView!
    @IBOutlet var activitySpinnerView: UIView!
    @IBOutlet var flashButton: UIButton!
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the video preview view.
        previewView.session = session
        
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
        flashButton.addTarget(self, action: #selector(updateTorch), for: UIControlEvents.touchDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.sessionQueue.async {
                    self.configureSession()
                }
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivatySetting = "Beerventory doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivatySetting, comment: "Alert message when the user has denied access to the camera")
                    let    alertController = UIAlertController(title: "Beerventory", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings",
                                                                                     comment: "Alert button to open Settings"),
                                                            style: .`default`, handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                print("sup")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        toggleTorch(on: false)
        super.viewWillDisappear(animated)
    }
    
    // Call this on the session queue.
    private func configureSession() {
        if self.setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        // Add video input.
        do {
            
            
            // Choose the back wide angle camera if available, otherwise default to the front wide angle camera.
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else {
                defaultVideoDevice = nil
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("Could not get video device")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add metadata output.
        if session.canAddOutput(results) {
            session.addOutput(results)
            
            // Set this view controller as the delegate for metadata objects.
            results.setMetadataObjectsDelegate(self, queue: metadataObjectsQueue)
            results.metadataObjectTypes = supportedCodeTypes
            
            
            let initialRectOfInterest = CGRect(x: 0.10, y: 0.10, width: 0.25, height: 0.80)
            results.rectOfInterest = initialRectOfInterest
            
            DispatchQueue.main.async {
                let initialRegionOfInterest = self.previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: initialRectOfInterest)
                self.previewView.setRegionOfInterestWithProposedRegionOfInterest(initialRegionOfInterest)
            }
        } else {
            print("Could not add metadata output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    // MARK: KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    private func addObservers() {
        var keyValueObservation: NSKeyValueObservation
        
        keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                
                /*
                 When the session starts running, the aspect ratio of the video preview may also change if a new session preset was applied.
                 To keep the preview view's region of interest within the visible portion of the video preview, the preview view's region of
                 interest will need to be updated.
                 */
                if isSessionRunning {
                    self.previewView.setRegionOfInterestWithProposedRegionOfInterest(self.previewView.regionOfInterest)
                }
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        /*
         Observe the previewView's regionOfInterest to update the AVCaptureMetadataOutput's
         rectOfInterest when the user finishes resizing the region of interest.
         */
        keyValueObservation = previewView.observe(\.regionOfInterest, options: .new) { _, change in
            guard let regionOfInterest = change.newValue else { return }
            
            DispatchQueue.main.async {
                
                // Translate the preview view's region of interest to the metadata output's coordinate system.
                let metadataOutputRectOfInterest = self.previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: regionOfInterest)
                
                // Update the AVCaptureMetadataOutput with the new region of interest.
                self.sessionQueue.async {
                    self.results.rectOfInterest = metadataOutputRectOfInterest
                }
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        notificationCenter.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        notificationCenter.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using AVCamBarcode, then the user can let AVCamBarcode resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // do something
            }
        }
    }
    
    @objc func updateTorch() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.isTorchActive {
            toggleTorch(on: false)
            flashButton.setImage( #imageLiteral(resourceName: "flashOn"), for: .normal)
        } else {
            toggleTorch(on: true)
            flashButton.setImage( #imageLiteral(resourceName: "flashOff"), for: .normal)
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
    }
    
    func addProgressSubview(){
        print("add progress subview")
        DispatchQueue.main.async {
            let progressHUD = SearchProgress(text: "Searching..")
            self.view.addSubview(progressHUD)
            self.view.bringSubview(toFront: progressHUD)
        }
    }
    
    func removeProgressSubview(){
        DispatchQueue.main.async {
            for subview in self.view.subviews {
                if subview is SearchProgress {
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    
    func searchBeerBarcodes(upc_code: String, onCompletion: @escaping () -> Void) {
        BrewerydbAPI.sharedInstance.search_barcode(barCode: upc_code, onCompletion: { (json: JSON) in
            guard let results = json["data"].array else {
                self.removeProgressSubview()
                print("   Good, no beers found with ")
                onCompletion()
                return
            }
            let alertController = UIAlertController(title: "Warning", message: "The barcode is already in the database.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { action in
                self.removeProgressSubview()
                print("   Found barcode in database")
                onCompletion()
            })
            self.presentedViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
    func updateBreweryDetails(onCompletion: @escaping () -> Void) {
        BrewerydbAPI.sharedInstance.get_beers_breweries(beers: self.scanResultsBeers, onCompletion: { (updatedBeers: [Beer]) in
            print(updatedBeers)
            self.scanResultsBeers = updatedBeers
            onCompletion()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("screen touched")
        let screenSize = UIScreen.main.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            guard let videoDevice = defaultVideoDevice else {
                print("Could not get video device")
                return
            }
            
            do {
                try videoDevice.lockForConfiguration()
                
                videoDevice.focusPointOfInterest = focusPoint
                //device.focusMode = .continuousAutoFocus
                videoDevice.focusMode = .autoFocus
                //device.focusMode = .locked
                videoDevice.exposurePointOfInterest = focusPoint
                videoDevice.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                videoDevice.unlockForConfiguration()
            }
            catch {
                // just ignore
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let addBeerViewController = segue.destination as? AddBeerViewController {
            print("set beer")
            addBeerViewController.beer = self.currentBeer
        }
    }
}

extension AddBeerScanUrlController: AVCaptureMetadataOutputObjectsDelegate {
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput results: [AVMetadataObject], from connection: AVCaptureConnection) {
        if results == nil || results.count == 0 { // handle empty results
            return
        } else {
            let metadataObj = results[0] as! AVMetadataMachineReadableCodeObject
            if supportedCodeTypes.contains(metadataObj.type) { // handle output type
                if supportedCodeTypes.contains(metadataObj.type) { // handle output type
                    if !(metadataObj.stringValue?.isEmpty)! { // handle result contents
                        self.session.stopRunning()
                        addProgressSubview()
                        print(metadataObj.stringValue)
                        self.currentBeer.upc_code = metadataObj.stringValue!
                        searchBeerBarcodes(upc_code: self.currentBeer.upc_code, onCompletion: {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "unwindToAddBeer", sender: self)
                            }
                        })
                    } else {
                        // TODO: - Add no results prompt
                    }
                    return
                } else {
                    // TODO: - Add no results prompt
                }
                return
            }
        }
    }
}



