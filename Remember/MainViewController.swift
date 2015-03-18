//
//  ViewController.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/6.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddEventDelegate, UIAlertViewDelegate{

    @IBOutlet weak var v_emptyHint: UIView!
    @IBOutlet var tv_events: UITableView!
    
    var hasAddLine:Int = 0
    var events:[Event] = []
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var indexToBeDeleted = -1
    var selectedIndex = -1
    var iv_name:UIImageView = UIImageView(frame: CGRectMake(30, 7, 30, 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tv_events.delegate = self
        tv_events.dataSource = self
        tv_events.tableFooterView = UIView()
        
        self.fetchEventsFromDB()
        
        self.setEmptyHint()
        
        self.customizeNaviBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = ""
        
        self.iv_name.hidden = false
        
        self.fetchEventsFromDB()
        self.tv_events.reloadData()
    }
    
    @IBAction func onTouchAddButton(sender: UIBarButtonItem) {
        if self.hasAddLine == 0 {
            self.toAddEvent()
        }else {
            self.cancclToAddEvent()
        }
    }
    
    //Add a row in table to add event
    func toAddEvent() {
        tv_events.beginUpdates()
        let rowToInsert:[NSIndexPath] = [NSIndexPath(forRow: self.events.count, inSection: 0)]
        self.tv_events.insertRowsAtIndexPaths(rowToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
        self.hasAddLine = 1
        tv_events.endUpdates()
    }
   
    //TableView Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count + self.hasAddLine
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row < self.events.count {
            let cell:EventTableViewCell = tv_events.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as EventTableViewCell
            let event:Event = self.events[indexPath.row]
            cell.l_eventName.text = event.title
            
            let test:NSDate? = event.lastTime as NSDate?
            
            if test != nil   {
                let lastTimeStr:String = DateUtil.getDateStringFromNSDate2(event.lastTime)
                let lastSpotStr:String = event.lastSpot
                cell.l_info.text = "最后一次 " + lastTimeStr + " 于" + lastSpotStr
            }else{
                cell.l_info.text = ""
            }
            cell.l_times.text = String(event.details.count)
            
            //image of event
            let documentPath:NSString = NSHomeDirectory().stringByAppendingPathComponent("Documents")
            let imagePath:NSString = documentPath + "/images/" + event.title + ".png"
            
            var image:UIImage = UIImage()
            if NSFileManager.defaultManager().fileExistsAtPath(imagePath) {
                image = UIImage(contentsOfFile: imagePath)!
            }else {
                image = UIImage(named: "colorful-triangles-background")!
            }
            cell.iv_icon.image = image
            
            
            return cell
        }else{
            let cell:AddEventTableViewCell = tv_events.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath) as AddEventTableViewCell
            cell.delegate = self
            return cell
        }
    }
    
    //Tableview Delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == self.events.count {
            return nil
        }else{
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == self.events.count {
            return false
        }else{
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //删除一条记录
        self.indexToBeDeleted = indexPath.row
//        let alert:UIAlertView = UIAlertView(title: "", message: "确定要删除这条记录吗？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
//        alert.show()
        let alert = SCLAlertView()
        alert.addButton("确定", target: self, selector: Selector("toDeleteEvent"))
        alert.showWarning("确定删除", subTitle: "确定要删除这条记录吗？", closeButtonTitle: "取消", duration: NSTimeInterval.infinity)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.selectedIndex = indexPath.row
        self.performSegueWithIdentifier("segueToDetailView", sender: self.tv_events.cellForRowAtIndexPath(indexPath))
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        self.iv_name.hidden = true
        self.title = "返回"
    }
    
    //alertview Delegate
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        if buttonIndex == 1 {
//            let eventToBeDel:Event = self.events[indexToBeDeleted]
//            self.deleteEvent(eventToBeDel)
//            
//            tv_events.beginUpdates()
//            let rowToRemove:[NSIndexPath] = [NSIndexPath(forRow: self.indexToBeDeleted, inSection: 0)]
//            self.tv_events.deleteRowsAtIndexPaths(rowToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
//            self.events.removeAtIndex(self.indexToBeDeleted)
//            tv_events.endUpdates()
//            
//            self.setEmptyHint()
//            
//        }
//    }
//    
    
    //add event protocol
    func confirmToAddEvent(title: String) {
        
        //remove the line of adding event
        tv_events.beginUpdates()
        let rowToRemove:[NSIndexPath] = [NSIndexPath(forRow: self.events.count, inSection: 0)]
        self.tv_events.deleteRowsAtIndexPaths(rowToRemove, withRowAnimation: UITableViewRowAnimation.Fade)
        self.hasAddLine = 0
        tv_events.endUpdates()
        
        //add to database
        self.insertEvent(title)
        
        //fetch data again
        self.fetchEventsFromDB()
        self.tv_events.reloadData()
        
        self.setEmptyHint()
    }
    
    func cancclToAddEvent() {
        //remove the line of adding event
        tv_events.beginUpdates()
        let rowToRemove:[NSIndexPath] = [NSIndexPath(forRow: self.events.count, inSection: 0)]
        self.tv_events.deleteRowsAtIndexPaths(rowToRemove, withRowAnimation: UITableViewRowAnimation.Fade)
        self.hasAddLine = 0
        tv_events.endUpdates()

    }
    
    
    //CoreData
    //fetch data from coredata
    func fetchEventsFromDB(){
        let context = self.appDelegate.managedObjectContext
        
        var request:NSFetchRequest = NSFetchRequest(entityName: "Event")
        var error:NSError? = nil
        self.events = context?.executeFetchRequest(request, error: &error) as [Event]
        self.events.sort { (e1:Event, e2:Event) -> Bool in
            return e1.lastTime.compare(e2.lastTime) == NSComparisonResult.OrderedDescending
        }
    }
    
    
    //insert data in core data
    func insertEvent(title:String) {
        let context = self.appDelegate.managedObjectContext
        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context!) as Event
        event.title = title
        event.times = 0
        var error:NSError? = nil
        
        context?.save(&error)
    }
    
    //delete an event
    
    func toDeleteEvent() {
        let eventToBeDel:Event = self.events[indexToBeDeleted]
        self.deleteEvent(eventToBeDel)
        
        tv_events.beginUpdates()
        let rowToRemove:[NSIndexPath] = [NSIndexPath(forRow: self.indexToBeDeleted, inSection: 0)]
        self.tv_events.deleteRowsAtIndexPaths(rowToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.events.removeAtIndex(self.indexToBeDeleted)
        tv_events.endUpdates()
        
        self.setEmptyHint()
        
    }
    
    func deleteEvent(event:Event){
        
        //delete event image
        let docuPath:NSString = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        let imageFolderPath = docuPath + "/images"
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        let imageName:NSString = event.title + ".png"
        let imagePath:NSString = imageFolderPath + "/" + imageName
        
        if fileManager.fileExistsAtPath(imagePath){
            fileManager.removeItemAtPath(imagePath, error: nil)
        }

        //deleteEvent for CoreData
        let context = self.appDelegate.managedObjectContext
        context?.deleteObject(event)
        var error:NSError? = nil
        context?.save(&error)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToDetailView" {
            let destinationVC:DetailViewController = segue.destinationViewController as DetailViewController
            let cell:EventTableViewCell = sender as EventTableViewCell
            let indexPath:NSIndexPath! = self.tv_events.indexPathForCell(cell) as NSIndexPath!
            
            destinationVC.setValue(self.events[indexPath.row], forKey:"event")
        }
    }
    
    func setEmptyHint() {
        if self.events.count == 0 {
            self.v_emptyHint.hidden = false
        }else {
            self.v_emptyHint.hidden = true
        }
    }
    
    // customize navigation bar
    func customizeNaviBar() {
        self.iv_name.image = UIImage(named: "name_cn")
        self.iv_name.tag = 1
        self.navigationController?.navigationBar.addSubview(iv_name)
    }
    
    //TODO name, localization

}

