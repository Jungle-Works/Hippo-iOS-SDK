//
//  ActionButtonViewCell.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol ActionButtonViewCellDelegate: class {
    func buttonClick(buttonInfo: HippoActionButton)
    func buttonClick(buttonInfo: HippoCard)
}

class ActionButtonViewCell: ActionViewCell {

    @IBOutlet weak var buttonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellButton: UIButton!
    
    //MARK: Variable
    var buttonInfo: HippoActionButton!
    var data: HippoCard?
    weak var delegate: ActionButtonViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultUI()
    }
    
    @IBAction func cellButtonAction(_ sender: Any) {
        if buttonInfo != nil {
          delegate?.buttonClick(buttonInfo: buttonInfo)
        } else if let data = data {
                delegate?.buttonClick(buttonInfo: data)
        }
    }
    
    func setDefaultUI() {
        cellButton.layer.cornerRadius = 5
        cellButton.layer.masksToBounds = true
        cellButton.tintColor = UIColor.gray
        
        cellButton.layer.borderWidth = 1
        
        cellButton.setTitle("", for: .normal)
        selectionStyle = .none
    }
    
    func setButtonState(active: Bool) {
        cellButton.isEnabled = active
        cellButton.alpha = active ? 1 : 0.5
    }
    func setupCell(buttonInfo: HippoActionButton) {
        self.buttonInfo = buttonInfo
        
        cellButton.isEnabled = buttonInfo.isUserInteractionEnabled
        cellButton.alpha = buttonInfo.isUserInteractionEnabled ? 1 : 0.5
        
        cellButton.setTitle(buttonInfo.title, for: .normal)
        
        if buttonInfo.isSelected {
            cellButton.backgroundColor = buttonInfo.selectedColor
            cellButton.setTitleColor(buttonInfo.selectedTitleColor, for: .normal)
            
            cellButton.layer.borderColor = buttonInfo.selectedTitleColor?.cgColor
        } else {
            cellButton.backgroundColor = buttonInfo.color
            cellButton.setTitleColor(buttonInfo.normalTitleColor, for: .normal)
            
            cellButton.layer.borderColor = buttonInfo.normalTitleColor?.cgColor
        }
    }
}

extension ActionButtonViewCell {
    func set(card: PayementButton) {
        self.data = card
//        let amount = card.selectedCardDetail?.amount ?? 0
        let displayAmount = ""//= (amount > 0 && card.showAmount) ? " \(amount)" : ""
        let title = card.title + displayAmount
        if let attributed = card.attributedTitle {
            self.cellButton.setAttributedTitle(attributed, for: .normal)
        } else {
            self.cellButton.setTitle(title, for: .normal)
        }
        let theme = HippoConfig.shared.theme
        cellButton.tintColor = HippoConfig.shared.theme.themeTextcolor
        cellButton.setTitleColor(HippoConfig.shared.theme.themeTextcolor, for: .normal)
        cellButton.backgroundColor = theme.themeColor
        cellButton.layer.borderWidth = 0
       // cellButton.hippoCornerRadius = cellButton.bounds.height / 2
        cellButton.titleLabel?.textColor = .white
        buttonLeadingConstraint.constant = 15
        buttonTrailingConstraint.constant = 15
    }
    
    
    
}
