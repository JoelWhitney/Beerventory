//
//  ScanViewController.swift
//  Beerventory
//
//  Created by Joel Whitney on 4/20/17.
//  Copyright © 2017 Joel Whitney. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import RxSwift
import RxCocoa
import AWSDynamoDB
import AWSMobileHubHelper

class ScanViewController: UIViewController {
    // MARK: - variables/constants
    var codeFont: UIFont?
    var captureSession: AVCaptureSession?
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var prevCodeStringvalue: String = ""
    var mainBeerStore = [AWSBeer]()
    var scanResultBeers = [Beer]()
    var currentAWSBeer: AWSBeer!
    var currentBeer: Beer!
    var currentBeerIndexPath: IndexPath!
    var alertTextField = UITextField()
    weak var actionToEnable : UIAlertAction?
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
    let disposeBag = DisposeBag()
    var pickerQuantity = "1"
    var upc_code = ""
    var scanResultFound: (([Beer]) -> Void)?

    // MARK: Outlets
    //@IBOutlet var tableView: UITableView!
    @IBOutlet var activitySpinnerView: UIView!
    @IBOutlet var capturePreviewViewFrame: UIView!
    
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
        //initBottomSheetController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func capturePreviewFrame() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let captureRectWidth = CGFloat(150.0)
        let captureRectHeight = CGFloat(150.0)
        
        var cgCaptureRect = CGRect(x: (screenWidth / 2 - captureRectWidth / 2),
                                   y: (screenHeight / 4 - captureRectHeight / 2),
                                   width: captureRectWidth,
                                   height: captureRectHeight)
        
        let captureWindowView = UIView()
        captureWindowView.frame = cgCaptureRect
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
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
        for subview in self.view.subviews {
            if subview is SearchProgress {
                subview.removeFromSuperview()
            }
        }
    }
    func configureTextField(alertTextField: UITextField?) {
        if let textField = alertTextField {
            textField.placeholder = "Enter quantity"
            textField.keyboardType = UIKeyboardType.numberPad
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
            self.alertTextField = textField // save reference to UITextField
        }
    }
    func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text! != "")
    }
    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    func handleInitialBeerJSON(beerJSON: JSON, upc_code: String, onCompletion: () -> Void) {
        print("################################### ADD INITIAL BARCODE JSON ################################")
        print("####### STEP 1: GET BEER DATA #######") // STEP 1 HERE
        if let results = beerJSON["data"].array {
            print("         Beers:")
            var tempResults = [Beer]()
            for beerResult in results {
                print("           " + beerResult["name"].string! )
                //self.lastSearchCount = results.count
                var beerResultObject = Beer(brewerydb_id: beerResult["id"].string! ,
                                            upc_code: upc_code ,
                                            name: beerResult["name"].string ?? "" ,
                                            beer_description: beerResult["description"].string ?? "",
                                            abv: beerResult["abv"].string ?? "--" ,
                                            label: beerResult["labels"]["large"].string ?? "" ,
                                            gravity: beerResult["style"]["ogMin"].string ?? "--" ,
                                            availability: beerResult["available"]["name"].string ?? "" ,
                                            availability_desc: beerResult["available"]["description"].string ?? "" ,
                                            style_name: beerResult["style"]["shortName"].string ?? "" ,
                                            style_desc: beerResult["style"]["description"].string ?? "" ,
                                            style_id: beerResult["style"]["id"].string ?? "" )
                tempResults.append(beerResultObject)
            }
            self.scanResultBeers = tempResults
            print("####### STEP 2: BEERSTORE CONTENTS #######") // STEP 3 HERE
            print(self.scanResultBeers)
        } else {
            print("   No Beers")
            let alertController = UIAlertController(title: "Error", message: "The barcode is not in the database, consider adding it.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { action in
                self.performSegue(withIdentifier: "tabBarController", sender: self)
            }

            alertController.addAction(add)
            present(alertController, animated: true, completion: nil)
            
        }
        onCompletion()
    }
    func updateBreweryDetails(onCompletion: @escaping () -> Void) {
        print("~~~~ STEP 3: GET BREWERY INFO JSON ~~~~")
        BrewerydbAPI.sharedInstance.get_beers_breweries(beers: self.scanResultBeers, onCompletion: { (updatedBeers: [Beer]) in
            print(updatedBeers)
            self.scanResultBeers = updatedBeers
            onCompletion()
        })
    }
    func refreshScanControllerState() {
        captureSession?.startRunning()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        qrCodeFrameView?.frame = CGRect.zero
    }
}

// MARK: - UIPicker delegate
extension ScanViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerQuantity = String(row + 1)
    }
}

// MARK: - UIPicker delegate
extension ScanViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(row)
        return String(row + 1)
    }
}

//MARK: AVCapture delegate
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
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
                    upc_code = metadataObj.stringValue
                    BrewerydbAPI.sharedInstance.search_barcode(barCode: metadataObj.stringValue, onCompletion: { (json: JSON) in
                        self.handleInitialBeerJSON(beerJSON: json, upc_code: self.upc_code, onCompletion: {
                            self.updateBreweryDetails(onCompletion: { // STEP 2 HERE
                                DispatchQueue.main.async(execute: {
                                    print("push results to searchResultsController")
                                    self.removeProgressSubview()
                                    self.refreshScanControllerState()
                                    print(self.scanResultBeers)
                                    self.scanResultFound?(self.scanResultBeers)
                                    //self.refreshTableView()
                                })
                            })
                        })
                    })
                } else {
                    // TODO: - Add no results prompt
                }
                return
            }
        }
    }
}
