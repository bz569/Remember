//
//  AddEventTableViewCell.swift
//  Remember
//
//  Created by ZhangBoxuan on 14/11/7.
//  Copyright (c) 2014年 ZhangBoxuan. All rights reserved.
//

import UIKit

protocol AddEventDelegate: NSObjectProtocol {
    func confirmToAddEvent(title:String)
    func cancclToAddEvent()
}

class AddEventTableViewCell: UITableViewCell {

    @IBOutlet weak var tf_eventTitle: UITextField!
    var delegate:AddEventDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onTouchConfirmBtn(sender: UIButton) {
//        println("confirm:" + self.tf_eventTitle.text)
        self.delegate?.confirmToAddEvent(self.tf_eventTitle.text)
        self.tf_eventTitle.text = ""
    }
    
    
    @IBAction func onTouchCancelBtn(sender: UIButton) {
        self.delegate?.cancclToAddEvent()
    }
}
