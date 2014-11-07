//
//  Event.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/6.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var lastTime: NSDate
    @NSManaged var lastSpot: String
    @NSManaged var times: NSNumber
    @NSManaged var imageName: String
    @NSManaged var details: NSSet

}
