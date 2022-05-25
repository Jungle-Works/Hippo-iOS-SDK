//
//  FilterChannelCell.swift
//  Fugu
//
//  Created by Vishal on 01/06/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class FilterChannelCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        cellLabel.textColor = HippoConfig.shared.theme.headerTextColor
        
        if let btn = subviews.last as? UIButton{
            btn.superview?.backgroundColor = .white
            
            if let imageVw = btn.subviews.first as? UIImageView, var image = imageVw.image{
                image = image.withRenderingMode(.alwaysTemplate)
                imageVw.image = image
                imageVw.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(field: FilterField) {
        cellLabel.text = field.nameOfField
    }
    
}
