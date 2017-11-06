//
//  AddBeerScanUrlController.swift
//  Beerventory
//
//  Created by Joel Whitney on 10/12/17.
//


import Foundation
import UIKit
import SwiftyJSON
import AVFoundation

class AddBeerScanUrlController: UIViewController {
    // MARK: - variables/constants
    var currentBeer: Beer!
    var captureSession: AVCaptureSession?
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypeITF14Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeDataMatrixCode,
                              AVMetadataObjectTypeInterleaved2of5Code]
    var scanResultsBeer: Beer!
    var captureDevice: AVCaptureDevice!
    @IBOutlet var flashButton: UIButton!
    
    // MARK: Outlets
    //@IBOutlet var tableView: UITableView!
    @IBOutlet var activitySpinnerView: UIView!
    
    // MARK: Actions
    
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturePreviewFrame()
        self.captureDetectionFrame()
        self.refreshScanControllerState()
        flashButton.addTarget(self, action: #selector(updateTorch), for: UIControlEvents.touchDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toggleTorch(on: false)
        self.refreshScanControllerState()
    }
    func updateTorch() {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        if device.isTorchActive {
            toggleTorch(on: false)
            flashButton.setImage( #imageLiteral(resourceName: "flashOn"), for: .normal)
        } else {
            toggleTorch(on: true)
            flashButton.setImage( #imageLiteral(resourceName: "flashOff"), for: .normal)
        }
    }
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
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
    func capturePreviewFrame() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let captureRectWidth = CGFloat(200.0)
        let captureRectHeight = CGFloat(200.0)
        
        var cgCaptureRect = CGRect(x: (screenWidth / 2 - captureRectWidth / 2),
                                   y: (screenHeight / 3 - captureRectHeight / 2),
                                   width: captureRectWidth,
                                   height: captureRectHeight)
        
        let captureWindowView = UIView()
        captureWindowView.frame = cgCaptureRect
        
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            // initialize the captureSession object and add input
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // initialize a output object to capture session
            let results = AVCaptureMetadataOutput()
            captureSession?.addOutput(results)
            results.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            results.metadataObjectTypes = supportedCodeTypes
            
            
            // initialize the video preview layer and add to view as sublayer
            capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            capturePreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            capturePreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(capturePreviewLayer!)
            view.addSubview(flashButton)
            // start capture session and move labels to front
            captureSession?.startRunning()
            
            
            // set capture area
            let captureRect = capturePreviewLayer?.metadataOutputRectOfInterest(for: cgCaptureRect)
            results.rectOfInterest = captureRect!
            captureWindowView.layer.backgroundColor = UIColor.clear.cgColor
            captureWindowView.layer.borderColor = UIColor.lightGray.cgColor
            captureWindowView.layer.borderWidth = 1
            view.addSubview(captureWindowView)
            view.bringSubview(toFront: captureWindowView)
            
            
        } catch {
            // print errors thrown by AVCaptureDeviceInput
            print("Error setting up preview frame: \(error)")
            return
        }
    }
    func captureDetectionFrame() {
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.white.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    //MARK: Imperative methods
    func addProgressSubview(){
        let progressHUD = SearchProgress(text: "Searching..")
        self.view.addSubview(progressHUD)
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
            self.present(alertController, animated: true, completion: nil)
            
        })
    }
    func refreshScanControllerState() {
        captureSession?.startRunning()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        qrCodeFrameView?.frame = CGRect.zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = UIScreen.main.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addBeerViewController = segue.destination as? AddBeerViewController {
            if currentBeer.upc_code != "" {
                let replacementBeer = currentBeer
                addBeerViewController.beer = replacementBeer!
            }
        }
    }
}


//MARK: AVCapture delegate
extension AddBeerScanUrlController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects results: [Any]!, from connection: AVCaptureConnection!) {
        if results == nil || results.count == 0 { // handle empty results
            qrCodeFrameView?.frame = CGRect.zero
            // TODO: - Add no results prompt
            return
        } else {
            let metadataObj = results[0] as! AVMetadataMachineReadableCodeObject
            if supportedCodeTypes.contains(metadataObj.type) { // handle output type
                let barCodeObject = capturePreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                if !metadataObj.stringValue.isEmpty { // handle result contents
                    captureSession?.stopRunning()
                    addProgressSubview()
                    print(metadataObj.stringValue)
                    currentBeer.upc_code = metadataObj.stringValue
                    searchBeerBarcodes(upc_code: currentBeer.upc_code, onCompletion: {
                        self.performSegue(withIdentifier: "unwindToAddBeer", sender: self)
                    })
                } else {
                    // TODO: - Add no results prompt
                }
                return
            }
        }
    }
}

