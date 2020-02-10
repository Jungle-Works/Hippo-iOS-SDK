//
//  MultiSelectHeaderTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/17/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class MultiSelectHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setTheme()
    }
    func setTheme() {
        bgView.backgroundColor = .clear
        descriptionLabel.numberOfLines = 0
        
        let theme = HippoConfig.shared.theme
        descriptionLabel.font = theme.incomingMsgFont
        descriptionLabel.textColor = theme.lightThemeTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
