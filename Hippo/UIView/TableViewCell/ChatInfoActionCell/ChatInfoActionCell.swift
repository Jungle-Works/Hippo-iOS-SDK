//
//  ChatInfoActionCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 21/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ChatInfoActionCell: UITableViewCell {

    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var iconImageView: So_UIImageView!
    @IBOutlet weak var cellLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLineView: So_UIView!
    @IBOutlet weak var widthOfIconImageView: NSLayoutConstraint!
    @IBOutlet weak var closeReopenChatTapButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLabel.font = UIFont.regular(ofSize: 15.0)
    }
    
}

extension ChatInfoActionCell {
    func resetPropertiesOfChatInfo() {
        backgroundColor = .clear
        clipsToBounds = true
    }

    func configureCellOfChatInfo(resetProperties: Bool, chatInfo: ChatInfoCell) -> ChatInfoActionCell {
        if resetProperties == true {
            resetPropertiesOfChatInfo()
        }
        
        iconImageView.image = chatInfo.infoImage ?? nil
        cellLabel.text = chatInfo.nameOfCell
        
        iconImageView.tintColor = HippoConfig.shared.theme.themeTextcolor
        cellLabel.tintColor = HippoConfig.shared.theme.themeTextcolor
        
        if chatInfo.infoImage == nil {
            widthOfIconImageView.constant = 0
        } else {
            widthOfIconImageView.constant = 15
        }
        
        return self
    }
}
