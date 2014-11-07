//
//  EventTableViewCell.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/6.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var l_eventName: UILabel!
    @IBOutlet weak var iv_icon: UIImageView!
    @IBOutlet weak var l_info: UILabel!
    @IBOutlet weak var l_times: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iv_icon.layer.masksToBounds = true
        iv_icon.layer.cornerRadius = 20
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
