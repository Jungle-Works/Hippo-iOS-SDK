//
//  CategoryTableViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellData = HippoSupportList()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(object: HippoSupportList) {
        self.cellData = object
        titleLabel.text = cellData.title
    }
    
    func setTheme() {
        titleLabel.font = HippoConfig.shared.theme.supportTheme.supportListHeadingFont
        titleLabel.textColor = HippoConfig.shared.theme.supportTheme.supportListHeadingColor
    }
}
