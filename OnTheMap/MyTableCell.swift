//
//  MyTableCell.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class MyTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func setCell(nameLabelText: String) {
        self.nameLabel.text = nameLabelText
    }
    
}
