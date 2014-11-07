//
//  Remember.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/7.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import Foundation
import CoreData

class Detail: NSManagedObject {

    @NSManaged var spot: String
    @NSManaged var time: NSDate
    @NSManaged var number: NSNumber
    @NSManaged var ofEvent: Event

}
