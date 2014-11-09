//
//  DetailViewController.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/7.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tv_details: UITableView!
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var l_title: UILabel!
    
    var event:Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = self.event.title
        // Do any additional setup after loading the view.
    }

    @IBAction func onTouchPlusButton(sender: UIButton) {
    }
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
