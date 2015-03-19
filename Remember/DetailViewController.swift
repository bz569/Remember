//
//  DetailViewController.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/7.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class DetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var tv_details: UITableView!
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var l_title: UILabel!
    @IBOutlet weak var l_hintToChangImg: UILabel!
    @IBOutlet weak var blurBG: UIImageView!
    @IBOutlet weak var btn_plus: UIButton!
    
    var tf_inputLocation: UITextField?
    
    var event:Event!
    var locationManager:CLLocationManager!
    var details:[Detail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if self.iv_image.image == UIImage(named: "colorful-triangles-background") {
            self.l_hintToChangImg.hidden = false
        }else {
            self.l_hintToChangImg.hidden = true
        }
        
        
        //fetch details
        self.fetchDetails()
        
        //setup location manager
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10.0
        self.locationManager.startUpdatingLocation()
        
        //setup tableview
        self.tv_details.dataSource = self
        self.tv_details.delegate = self
        self.tv_details.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //set imageView
        self.showImage()
        
        //set imageview tap
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("changeImage"))
        singleTap.numberOfTapsRequired = 1
        self.iv_image.addGestureRecognizer(singleTap)
        
        //set title
        self.l_title.text = self.event.title
        
        //set blurBG to hint if no details
        self.setBlurBG()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //set animation for plus button
        self.btn_plus.transform = CGAffineTransformMakeScale(0.1, 0.1)
        
        UIView.animateWithDuration(2.0,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.btn_plus.transform = CGAffineTransformIdentity
            }, completion: nil)
    }

    @IBAction func onTouchPlusButton(sender: UIButton) {
        
        
        let location:CLLocation? = self.locationManager.location
        if location != nil{
            let time:NSDate = self.locationManager.location.timestamp
            let geoCoder:CLGeocoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
                let placeMark:CLPlacemark = placeMarks[0] as CLPlacemark
                self.addARecordInDataBase(time, spot: placeMark.name)
            })
        }else{
//            let av_inputLocation:UIAlertView = UIAlertView(title: "输入地点", message: "定位不可用，请手动输入地点", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
//            av_inputLocation.alertViewStyle = UIAlertViewStyle.PlainTextInput
//            let tf:UITextField = av_inputLocation.textFieldAtIndex(0)!
//            tf.placeholder = "地点"
//            av_inputLocation.show()
            
            let alert = SCLAlertView()
            let placeHolderStr = NSLocalizedString("ENTER_LOCATION", comment: "Enter location..")
            self.tf_inputLocation = alert.addTextField(title:placeHolderStr)
            self.tf_inputLocation?.delegate = self
            
            let confirmStr = NSLocalizedString("CONFIRM", comment: "Confirm")
            alert.addButton(confirmStr, action: {
                let time:NSDate = NSDate()
                
                if self.tf_inputLocation!.text != ""{
                    self.addARecordInDataBase(time, spot: self.tf_inputLocation!.text)
                }
            })
            
            let titleStr = NSLocalizedString("LOCATION", comment: "Location")
            let subTitleStr = NSLocalizedString("ENTER_LOCATION_HINT", comment: "Location is not valid, please enter it")
            let cancelStr = NSLocalizedString("CANCEL", comment: "Cancel")
            alert.showEdit(titleStr, subTitle: subTitleStr, closeButtonTitle: cancelStr, duration: NSTimeInterval.infinity)
            
            
        }
        
    }
    
    //CoreData
    func addARecordInDataBase(time:NSDate, spot:String){
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.managedObjectContext
        let detail:Detail = NSEntityDescription.insertNewObjectForEntityForName("Detail", inManagedObjectContext: context!) as Detail
        
        detail.time = time
        detail.spot = spot
        detail.number = self.event.details.count + 1
        detail.ofEvent = self.event
        
        self.event.addDetailObject(detail)
        self.event.times = self.event.details.count
        self.event.lastSpot = spot
        self.event.lastTime = time
        
        var error:NSError? = nil
        
        context?.save(&error)
        
        self.tv_details.beginUpdates()
        let rowToAdd:[NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]
        self.tv_details.insertRowsAtIndexPaths(rowToAdd, withRowAnimation: UITableViewRowAnimation.Top)
        self.fetchDetails()
        self.tv_details.endUpdates()
        
        //hide blurBG
        self.setBlurBG()
    }
    
    //table view datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.event.details.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                
        let cell:DetailTableViewCell = self.tv_details.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as DetailTableViewCell
        
        let detail:Detail = self.details[indexPath.row]
        cell.l_number.text = detail.number.stringValue
        cell.l_time.text = DateUtil.getDateStringFromNSDate(detail.time)
        let atStr = NSLocalizedString("AT", comment: "At")
        cell.l_event.text = atStr + detail.spot
        let colorUtil = ColorUtil()
        cell.v_iconBackground.backgroundColor = colorUtil.randomColor()
        
        return cell
    }
    
    //tableview delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    //coredata
    
    //fetch detail data form datebase
    func fetchDetails() {
        
        self.details = self.event.details.allObjects as [Detail]
        
        self.details = sorted(self.details, { (d1:Detail, d2:Detail) -> Bool in
            return d1.number.compare(d2.number) == NSComparisonResult.OrderedDescending
        })
    }
    
    
    // show the image
    func showImage() {
        let documentPath:NSString = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        let imagePath:NSString = documentPath + "/images/" + self.event.title + ".png"
        
        var image:UIImage = UIImage()
        if NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
            image = UIImage(contentsOfFile: imagePath)!
            self.l_hintToChangImg.hidden = true
        }else {
            image = UIImage(named: "colorful-triangles-background")!
        }
        self.iv_image.image = image
    }
    
    
    func changeImage(){
        
        let titleStr = NSLocalizedString("CHANGE_IMAGE", comment: "Change image")
        let cameraStr = NSLocalizedString("CAMERA", comment: "From camera")
        let photoLibStr = NSLocalizedString("PHOTO_LIBRARY", comment: "From photo library")
        let cancelStr = NSLocalizedString("CANCEL", comment: "Cancel")

        let as_selectIamge:UIActionSheet = UIActionSheet(title: titleStr, delegate: self, cancelButtonTitle: cancelStr, destructiveButtonTitle: nil, otherButtonTitles: cameraStr, photoLibStr)
        
        as_selectIamge.showInView(self.view)
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.takePhoto()
        }else if buttonIndex == 2{
            self.pickImageFormPhotoLibrary()
        }
    }
    
    func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            
            
        }else {
            println("camera error")
        }
        
    }
    
    func pickImageFormPhotoLibrary() {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    //After picking or shooting a picture
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let type:NSString = info[UIImagePickerControllerMediaType] as NSString

        if type == "public.image" {
            //convert image to NSData
            let image:UIImage = info[UIImagePickerControllerEditedImage] as UIImage
            var imageData:NSData = NSData()
            if UIImagePNGRepresentation(image) == nil {
                imageData = UIImageJPEGRepresentation(image, 1.0)
            }else{
                imageData = UIImagePNGRepresentation(image)
            }
            
            //save image in documents/images folder
            let docuPath:NSString = NSHomeDirectory().stringByAppendingPathComponent("Documents")
            let imageFolderPath = docuPath + "/images"
            let fileManager:NSFileManager = NSFileManager.defaultManager()
            fileManager.createDirectoryAtPath(imageFolderPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            let imageName:NSString = self.event.title + ".png"
            let imagePath:NSString = imageFolderPath + "/" + imageName
            fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
            
            //show the image
            self.showImage()
            
        }
    }
    
    
    // AlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1{
            let tf:UITextField = alertView.textFieldAtIndex(0)!
            let time:NSDate = NSDate()
            self.addARecordInDataBase(time, spot: tf.text)
        }
    }
    
    
    //when there is no detail record, set the background to be blur to notice user to touck plus button
    func setBlurBG() {
        if self.details.count == 0 {
            self.blurBG.hidden = false
        }else{
            self.blurBG.hidden = true
        }
    }
    
    //hide the keyboard
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.tf_inputLocation != nil {
            self.tf_inputLocation?.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

}
























