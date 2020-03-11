//
//  ProfileDetailCell.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class ProfileDetailCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var bgView: UIView!
    
    
    var info: CustomField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }
    
    internal func setTheme() {
        self.selectionStyle = .none
        backgroundColor = .clear
        let theme = HippoConfig.shared.theme
        
        titleLabel.textColor = theme.profileFieldTitleColor
        titleLabel.font = theme.profileFieldTitleFont
        
        valueLabel.textColor = theme.prfoileFieldValueColor
        valueLabel.font = theme.profileFieldValueFont
        labelContainer.backgroundColor = .clear
        bgView.backgroundColor = .white
    }

}

extension ProfileDetailCell {
    func set(field: CustomField) {
        self.info = field
        
        titleLabel.text = field.displayName
        valueLabel.text = field.value ?? ""
    }
}
