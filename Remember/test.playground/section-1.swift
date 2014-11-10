// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let date:NSDate = NSDate()
let formatter:NSDateFormatter = NSDateFormatter()
formatter.dateFormat = "yyyy年MM月dd日"
let dateStr:String = formatter.stringFromDate(date)
