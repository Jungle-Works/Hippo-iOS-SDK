//
//  ActionLabelViewCell.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ActionLabelViewCell: ActionViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(message: String) {
        cellLabel.text = message
    }
    
}
