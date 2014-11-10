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

class DetailViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tv_details: UITableView!
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var l_title: UILabel!
    
    var event:Event!
    var locationManager:CLLocationManager!
    var details:[Detail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        
        
    }

    @IBAction func onTouchPlusButton(sender: UIButton) {
        
        //TODO:定位不可用时，提示手动输入地点
        
        let location:CLLocation = self.locationManager.location
        let time:NSDate = self.locationManager.location.timestamp
        let geoCoder:CLGeocoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            let placeMark:CLPlacemark = placeMarks[0] as CLPlacemark
            self.addARecordInDataBase(time, spot: placeMark.name)
        })
        
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
        
        //TODO: 添加行的动画
        self.tv_details.beginUpdates()
        let rowToAdd:[NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]
        self.tv_details.insertRowsAtIndexPaths(rowToAdd, withRowAnimation: UITableViewRowAnimation.Top)
        self.fetchDetails()
        self.tv_details.endUpdates()
        
        
        
        
        
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
    
    
}
























