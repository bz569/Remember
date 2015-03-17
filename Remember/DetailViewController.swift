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

class DetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate{
    
    @IBOutlet weak var tv_details: UITableView!
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var l_title: UILabel!
    @IBOutlet weak var l_hintToChangImg: UILabel!
    @IBOutlet weak var blurBG: UIImageView!
    
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
            let av_inputLocation:UIAlertView = UIAlertView(title: "输入地点", message: "定位不可用，请手动输入地点", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            av_inputLocation.alertViewStyle = UIAlertViewStyle.PlainTextInput
            let tf:UITextField = av_inputLocation.textFieldAtIndex(0)!
            tf.placeholder = "地点"
            av_inputLocation.show()
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
        cell.l_event.text = "于 " + detail.spot
        cell.v_iconBackground.backgroundColor = ColorUtil.randomColor()
        
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
        let as_selectIamge:UIActionSheet = UIActionSheet(title: "更换背景图片", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍照", "从手机相册选择")
        
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
}
























