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
}

class ActionButtonViewCell: ActionViewCell {

    @IBOutlet weak var cellButton: UIButton!
    
    //MARK: Variable
    var buttonInfo: HippoActionButton!
    weak var delegate: ActionButtonViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultUI()
    }
    
    @IBAction func cellButtonAction(_ sender: Any) {
        delegate?.buttonClick(buttonInfo: buttonInfo)
    }
    
    func setDefaultUI() {
        cellButton.layer.cornerRadius = 5
        cellButton.layer.masksToBounds = true
        cellButton.tintColor = UIColor.gray
        
        cellButton.layer.borderWidth = 1
        
        cellButton.setTitle("", for: .normal)
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
