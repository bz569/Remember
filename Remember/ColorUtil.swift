//
//  ColorUtil.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/10.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class ColorUtil: NSObject {
    
    class func randomColor () -> UIColor{
        
        let color1:UIColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        let color2:UIColor = UIColor(red: 243.0/255.0, green: 156.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        let color3:UIColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        let color4:UIColor = UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
        let color5:UIColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
        
        let colorList:[UIColor] = [color1, color2, color3, color4, color5]
        
        let randIndex:Int = Int(arc4random()) % (colorList.count)
        
        return colorList[randIndex]
    }
   
}
