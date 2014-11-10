//
//  DateUtil.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/10.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class DateUtil: NSObject {
    
    class func getDateStringFromNSDate(date:NSDate) ->String{
        
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let result:String = formatter.stringFromDate(date)
        
        return result
    }
    
    class func getDateStringFromNSDate2(date:NSDate) ->String{
        
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result:String = formatter.stringFromDate(date)
        
        return result
    }
   
}
