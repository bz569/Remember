//
//  DetailTableViewCell.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/9.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var v_iconBackground: UIView!
    @IBOutlet weak var l_number: UILabel!
    @IBOutlet weak var l_time: UILabel!
    @IBOutlet weak var l_event: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.v_iconBackground.layer.masksToBounds = true
        self.v_iconBackground.layer.cornerRadius = 20
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
