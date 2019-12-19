//
//  MultipleSelectTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/13/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class MultipleSelectTableViewCell: UITableViewCell {
    
    var message: HippoMessage?
    var selectedButtonsArr : [MultiselectButtons]?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var selectionButtonView: UIImageView!
    
    
    @IBOutlet weak var innerCardView: UIView!
    @IBOutlet weak var innerCardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerCardViewLeadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var buttonText: UILabel!
    @IBOutlet weak var buttonTextBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTextLeadingConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setTheme() {
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        let theme = HippoConfig.shared.theme
        buttonText.textColor = theme.pricingTextColor
        buttonText.font = theme.pricingFont
        buttonText.numberOfLines = 0
        
        bgView.backgroundColor = UIColor.clear
        innerCardView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.black40.cgColor
        bgView.layer.cornerRadius = 3
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor.white
        
    }
    
}


extension MultipleSelectTableViewCell {
    func set(button: MultiselectButtons)
    {
        //setConstraint(config: card.cardConfig)
        setLabel(label:buttonText, text: button.btnTitle ?? "")
        
        if button.isMultiSelect
        {
            self.selectionButtonView?.image = button.status! ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive
        }
        else
        {
            self.selectionButtonView?.image = button.status! ? HippoConfig.shared.theme.radioActive : HippoConfig.shared.theme.radioInActive
        }
    }
    
}


extension MultipleSelectTableViewCell {
    
    private func setLabel(label: UILabel, text: String?) {
        let parsedText = text?.trimWhiteSpacesAndNewLine() ?? ""
        label.text = parsedText
        label.isHidden = parsedText.isEmpty
    }
  
}

