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

    @IBOutlet var tv_events: UITableView!
    
    var hasAddLine:Int = 0
    var events:[Event] = []
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var indexToBeDeleted = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tv_events.delegate = self
        tv_events.dataSource = self
        tv_events.tableFooterView = UIView()
        
        self.fetchEventsFromDB()
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
            cell.l_eventName.text = self.events[indexPath.row].title
            cell.l_info.text = "最后一次 2014-10-10 于XXX"
            
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
        let alert:UIAlertView = UIAlertView(title: "", message: "确定要删除这条记录吗？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.show()
    }
    
    //alertview Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let eventToBeDel:Event = self.events[indexToBeDeleted]
            self.deleteEvent(eventToBeDel)
            
            tv_events.beginUpdates()
            let rowToRemove:[NSIndexPath] = [NSIndexPath(forRow: self.indexToBeDeleted, inSection: 0)]
            self.tv_events.deleteRowsAtIndexPaths(rowToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
            self.events.removeAtIndex(self.indexToBeDeleted)
            tv_events.endUpdates()
            
        }
    }
    
    
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
    }
    
    @IBAction func onTouchAddButton(sender: UIBarButtonItem) {
        if self.hasAddLine == 0 {
            self.toAddEvent()
        }else {
            self.cancclToAddEvent()
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
    func deleteEvent(event:Event){
        let context = self.appDelegate.managedObjectContext
        context?.deleteObject(event)
        var error:NSError? = nil
        context?.save(&error)
    }

    
    


}

