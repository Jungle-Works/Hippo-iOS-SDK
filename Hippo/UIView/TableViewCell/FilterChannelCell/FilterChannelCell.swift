//
//  FilterChannelCell.swift
//  Fugu
//
//  Created by Vishal on 01/06/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class FilterChannelCell: CoreTabelViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(field: FilterField) {
        cellLabel.text = field.nameOfField
    }
    
}
