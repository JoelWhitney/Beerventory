//
//  ScanController.swift
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

class ScanController: UIViewController {
    // MARK: - variables/constants
    var codeFont: UIFont?
    var captureSession: AVCaptureSession?
    var capturePreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var prevCodeStringvalue: String = ""
    var mainBeerStore = [AWSBeer]()
    var scanResultsBeerStore: BeerStore {
        let navController = self.navigationController as? NavigationController
        return navController!.scanResultsBeerStore
    }
    var lastSearchCount: Int {
        let navController = self.navigationController as? NavigationController
        return navController!.scanResultsBeerStore.allBeers.value.count
    }
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
    
    // MARK: Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activitySpinnerView: UIView!
    @IBOutlet var capturePreviewViewFrame: UIView!
    
    // MARK: Actions
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        refreshScanControllerState()
    }
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.capturePreviewFrame()
        self.captureDetectionFrame()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        // add long press to tableView
        //let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ScanController.longPress(_:)))
        //longPressGesture.minimumPressDuration = 0.5 // 1 second press
        //longPressGesture.delegate = self
        //self.tableView.addGestureRecognizer(longPressGesture)
        queryWithPartitionKeyWithCompletionHandler { (response, error) in
            if let erro = error {
                //self.NoSQLResultLabel.text = String(erro)
                print("error: \(erro)")
            } else if response?.items.count == 0 {
                //self.NoSQLResultLabel.text = String("0")
                print("No items")
            } else {
                //self.NoSQLResultLabel.text = String(response!.items)
                print("success: \(response!.items)")
                self.updateItemstoStore(items: response!.items) {
                    DispatchQueue.main.async(execute: {
                        print("mainBeerStore updated")
                    })
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ScanController will appear -- \(scanResultsBeerStore.allBeers.value.count) existing results")
        self.navigationController?.topViewController?.title = "Scan"
        queryWithPartitionKeyWithCompletionHandler { (response, error) in
            if let erro = error {
                //self.NoSQLResultLabel.text = String(erro)
                print("error: \(erro)")
            } else if response?.items.count == 0 {
                //self.NoSQLResultLabel.text = String("0")
                print("No items")
            } else {
                //self.NoSQLResultLabel.text = String(response!.items)
                print("success: \(response!.items)")
                self.updateItemstoStore(items: response!.items) {
                    DispatchQueue.main.async(execute: {
                        print("mainBeerStore updated")
                    })
                }
            }
        }
        //self.lastSearchCount = scanResultsBeerStore.allBeers.value.count
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanResultsBeerStore.saveChanges()
    }
    
    //MARK: Additional views
    private func capturePreviewFrame() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let captureRectWidth = CGFloat(150.0)
        let captureRectHeight = CGFloat(150.0)
        
        var cgCaptureRect = CGRect(x: (screenWidth / 2 - captureRectWidth / 2),
                                   y: (screenHeight / 2 - captureRectHeight / 2) / 2,
                                   width: captureRectWidth,
                                   height: captureRectHeight)
        
        let captureWindowView = UIView()
        
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
            capturePreviewLayer?.frame = capturePreviewViewFrame.frame
            view.layer.addSublayer(capturePreviewLayer!)
            
            // start capture session and move labels to front
            captureSession?.startRunning()
            
            // set capture area
            //let captureRect = capturePreviewLayer?.metadataOutputRectOfInterest(for: cgCaptureRect)
            //results.rectOfInterest = captureRect!
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
    private func captureDetectionFrame() {
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.white.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }

    //MARK: Imperative methods
    func queryWithPartitionKeyDescription() -> String {
        let partitionKeyValue = AWSIdentityManager.default().identityId!
        return "Find all items with userId = \(partitionKeyValue)."
    }
    func queryWithPartitionKeyWithCompletionHandler(_ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": AWSIdentityManager.default().identityId!,]
        
        objectMapper.query(AWSBeer.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as? NSError)
            })
        }
    }
    func updateItemstoStore(items: [AWSDynamoDBObjectModel], onCompletion: () -> Void) {
        for item in items {
            let awsBeer = item as! AWSBeer
            mainBeerStore.append(awsBeer)
            print("\(mainBeerStore.count) items in beer store")
        }
        onCompletion()
    }
    func handleInitialBeerJSON(beerJSON: JSON, upc_code: String, onCompletion: () -> Void) {
        print("################################### ADD INITIAL BARCODE JSON ################################")
        print("####### STEP 1: GET BEER DATA #######") // STEP 1 HERE
        if let results = beerJSON["data"].array {
            print("         Beers:")
            self.clearScanResultsBeers()
            let tempResults: Variable<[Beer]> = Variable([])
            for beerResult in results {
                print("           " + beerResult["name"].string! )
                //self.lastSearchCount = results.count
                let beerResultObject = Beer(brewerydb_id: beerResult["id"].string! ,
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
                tempResults.value.append(beerResultObject)
            }
            self.scanResultsBeerStore.allBeers = tempResults
            print("####### STEP 2: BEERSTORE CONTENTS #######") // STEP 3 HERE
            print(self.scanResultsBeerStore.allBeers.value)
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
    func refreshScanControllerState() {
        captureSession?.startRunning()
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        qrCodeFrameView?.frame = CGRect.zero
    }
    func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func clearScanResultsBeers() {
        let emptyResults: Variable<[Beer]> = Variable([])
        scanResultsBeerStore.allBeers = emptyResults
        print("         (purging beers from BeerStore)")
        //print(scanResultsBeerStore.allBeers.value)
    }
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
    func checkButtonTapped(sender:AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        currentBeerIndexPath = indexPath!
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
    func showPickerInActionSheet(sender: AnyObject) {
        pickerQuantity = "1"
        checkButtonTapped(sender: sender)
        print(currentBeerIndexPath.row)
        currentBeer = scanResultsBeerStore.allBeers.value[currentBeerIndexPath.row]
        var actionType: String
        var actionTitle: String
        if sender.tag == 1 {
            actionType = "add"
            actionTitle = "Add"
        } else {
            actionType = "remove"
            actionTitle = "Remove"
        }
        print("\(actionTitle) \(currentBeer.name)")
        var title = "\(actionTitle) \(currentBeer.name)"
        var message = "Enter quantity of beers to \(actionType)\n\n\n\n\n\n\n\n\n\n"
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.isModalInPopover = true
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        var pickerFrame: CGRect = CGRect(x: 17, y: 52, width: 270, height: 160); // CGRectMake(left), top, width, height) - left and top are like margins
        var picker: UIPickerView = UIPickerView(frame: pickerFrame);
        //set the pickers datasource and delegate
        picker.delegate = self
        picker.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(picker)
        //add buttons to the view
        var buttonCancelFrame: CGRect = CGRect(x: 0, y: 200, width: 100, height: 30) //size & position of the button as placed on the toolView
        //Create the cancel button & set its title
        var buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState.normal)
        buttonCancel.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(cancelSelection), for: UIControlEvents.touchDown)
        //add buttons to the view
        var buttonOkFrame: CGRect = CGRect(x: 170, y:  200, width: 100, height: 30); //size & position of the button as placed on the toolView
        //Create the Select button & set the title
        var buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        if sender.tag == 1 {
            buttonOk.addTarget(self, action: #selector(addBeers), for: UIControlEvents.touchDown);
            buttonOk.setTitle("Add", for: UIControlState.normal);
            buttonOk.setTitleColor(UIColor(red: 200/255, green: 147/255, blue: 49/255, alpha: 1), for: UIControlState.normal)
        } else {
            //
        }
        alert.view.addSubview(buttonOk)
        alert.view.addSubview(buttonCancel)
        self.present(alert, animated: true, completion: nil);
    }
    func addBeers(sender: UIButton){
        guard let quantity = Int(pickerQuantity) else {
            // handle bad no value or text entry
            return
        }
        guard let existingAWSBeer = mainBeerStore.filter({$0._beerEntryId == currentBeer.brewerydb_id}).first else {
            // Add new beer if doesn't exist
            currentBeer.quantity = quantity
            insertAWSBeer(beer: currentBeer)
            self.dismiss(animated: true, completion: {
                let alertController2 = UIAlertController(title: "\(self.currentBeer.name) added", message: "You added \(self.currentBeer.quantity) \(self.currentBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
                alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController2, animated: true, completion: nil)
            })
            return
        }
        // Update beer quanity if exists
        let existingBeer = existingAWSBeer.returnBeerObject()
        existingBeer.quantity += quantity
        existingAWSBeer._beer = existingBeer.beerObjectMap()
        let objectMapper = AWSDynamoDBObjectMapper.default()
        objectMapper.save(existingAWSBeer, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
        self.dismiss(animated: true, completion: {
            let alertController2 = UIAlertController(title: "\(self.currentBeer.name) added", message: "You now have \(existingBeer.quantity) \(self.currentBeer.name).", preferredStyle: UIAlertControllerStyle.alert)
            alertController2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController2, animated: true, completion: nil)
        })
    }
    func cancelSelection(sender: UIButton){
        print("Cancel");
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailsViewController") {
            let yourNextViewController = (segue.destination as! DetailsController)
            yourNextViewController.beer = currentBeer
        }
        if(segue.identifier == "tabBarController") {
            let yourNextViewController = (segue.destination as! TabBarController)
            yourNextViewController.newBeer.upc_code = upc_code
        }
    }
    func insertAWSBeer(beer: Beer) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = beer.brewerydb_id
        itemToCreate._beer = beer.beerObjectMap()
        //itemToCreate._beer = ["thing": ""]
        print(itemToCreate._userId as String!)
        print(itemToCreate._beerEntryId as String!)
        print(itemToCreate._beer as [String: String]!)
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
    }
    func updateAWSBeer(beer: Beer) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate: AWSBeer = AWSBeer()
        itemToCreate._userId = AWSIdentityManager.default().identityId!
        itemToCreate._beerEntryId = beer.brewerydb_id
        itemToCreate._beer = beer.beerObjectMap()
        //itemToCreate._beer = ["thing": ""]
        print(itemToCreate._userId as String!)
        print(itemToCreate._beerEntryId as String!)
        print(itemToCreate._beer as [String: String]!)
        objectMapper.save(itemToCreate, completionHandler: {(error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        })
    }
}

// MARK: - UIPicker delegate
extension ScanController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerQuantity = String(row + 1)
    }
}

// MARK: - UIPicker delegate
extension ScanController: UIPickerViewDataSource {
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

// MARK: - Table view data source
extension ScanController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.lastSearchCount == 0 {
            return "Search results"
        } else if self.lastSearchCount == 1 {
            return "Last search results (\(self.lastSearchCount) beer)"
        } else {
            return "Last search results (\(self.lastSearchCount) beers)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResultsBeerStore.allBeers.value.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // handle all beers
        if indexPath.row < scanResultsBeerStore.allBeers.value.count {
            self.tableView.estimatedRowHeight = 135
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScanBeerTableCell", for: indexPath) as! ScanBeerTableCell
            let beer = scanResultsBeerStore.allBeers.value[indexPath.row]
            // cell details
            cell.beerNameLabel.text = beer.name
            cell.beerStyle.text = beer.style_name
            cell.breweryNameLabel.text = beer.brewery_name
            cell.abvLabel.text = "\(beer.abv)%"
            cell.addBeerButton.tag = 1
            cell.addBeerButton.addTarget(self, action: #selector(showPickerInActionSheet), for: .touchUpInside)
            return cell
        // handle the last cell after all beers
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScanLastCell", for: indexPath) as! ScanLastCell
            if self.lastSearchCount == 0 {
                cell.lastCellLabel.text =  "🍻 Find your Beer today! 🍻"
            } else {
                cell.lastCellLabel.text = ""
            }
            return cell
        }
    }
}

// MARK: - tableView delegate
extension ScanController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentBeer = scanResultsBeerStore.allBeers.value[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "detailsViewController", sender: self)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let myCell = cell as? ScanBeerTableCell {
            // cell formatting
            myCell.mainBackground.layer.cornerRadius = 8
            myCell.mainBackground.layer.masksToBounds = true
            myCell.shadowLayer.layer.masksToBounds = false
            myCell.shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 0)
            myCell.shadowLayer.layer.shadowColor = UIColor.black.cgColor
            myCell.shadowLayer.layer.shadowOpacity = 0.5
            myCell.shadowLayer.layer.shadowRadius = 2
            myCell.shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: myCell.shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
            myCell.shadowLayer.layer.shouldRasterize = false
            myCell.shadowLayer.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

//// MARK: longPress delegate
//extension ScanController: UIGestureRecognizerDelegate {
//    func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
//        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
//            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
//            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
//                // your code here, get the row for the indexPath or do whatever you want
//                print("pressed me hehehehe")
//                let beer: Beer = scanResultsBeerStore.allBeers.value[indexPath.row]
//                currentBeer = beer
//                let alertController = UIAlertController(title: beer.name, message: "What would you like to do?", preferredStyle: .actionSheet)
//                
//                let addButton = UIAlertAction(title: "Add Beer", style: .default, handler: { (action) -> Void in
//                    print("add button tapped")
//                    self.addBeerstoCart(beer: beer)
//                })
//                let detailsButton = UIAlertAction(title: "Beer Details", style: .default, handler: { (action) -> Void in
//                    print("details button tapped")
//                    self.performSegue(withIdentifier: "detailsViewController", sender: self)
//                })
//                
//                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
//                    print("Cancel button tapped")
//                })
//                alertController.addAction(addButton)
//                alertController.addAction(detailsButton)
//                alertController.addAction(cancelButton)
//                self.present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
//}

//MARK: AVCapture delegate
extension ScanController: AVCaptureMetadataOutputObjectsDelegate {
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
                            self.scanResultsBeerStore.updateBreweryDetails(onCompletion: { // STEP 2 HERE
                                DispatchQueue.main.async(execute: {
                                    print("reload tableview")
                                    self.removeProgressSubview()
                                    self.refreshScanControllerState()
                                    self.refreshTableView()
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
