//
//  Event+CoreData.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/9.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import Foundation

extension Event{
    func addDetailObject(detail:Detail){
        var items = self.mutableSetValueForKey("details")
        items.addObject(detail)
    }
    
    func removeDetailObject(detail:Detail){
        var items = self.mutableSetValueForKey("details")
        items.removeObject(detail)
    }
}
