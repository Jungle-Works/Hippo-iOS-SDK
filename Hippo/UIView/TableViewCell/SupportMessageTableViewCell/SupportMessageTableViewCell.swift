//
//  SupportMessageTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 29/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class SupportMessageTableViewCell: MessageTableViewCell {
    
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var supportMessageTextView: UITextView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        supportMessageTextView.backgroundColor = .clear
        supportMessageTextView.textContainer.lineFragmentPadding = 0
        supportMessageTextView.textContainerInset = .zero
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
    }
    
    func setupBoxBackground(messageType: MessageType) {
        switch messageType {
        default:
            bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        }
    }
    
    func adjustShadow() {
        bgView.layoutIfNeeded()
    }
    
    func resetPropertiesOfSupportCell() {
        selectionStyle = .none
        supportMessageTextView.text = ""
        supportMessageTextView.attributedText = nil
        supportMessageTextView.isEditable = false
        supportMessageTextView.dataDetectorTypes = UIDataDetectorTypes.all
        supportMessageTextView.backgroundColor = .clear
        
        timeLabel.text = ""
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textAlignment = .left
        timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
        
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
    }
    
    func configureCellOfSupportIncomingCell(resetProperties: Bool,
                                            attributedString: NSMutableAttributedString,
                                            channelId: Int,
                                            chatMessageObject: HippoMessage) -> SupportMessageTableViewCell {
        if resetProperties { resetPropertiesOfSupportCell() }
        
        message?.messageRefresed = nil
        
        super.intalizeCell(with: chatMessageObject, isIncomingView: true)
        let messageType = chatMessageObject.type
        
        message?.messageRefresed = {
            DispatchQueue.main.async {
                self.setSenderImageView()
            }
        }
        
        setupBoxBackground(messageType: messageType)
        
        setTime()
        
        supportMessageTextView.attributedText = attributedString
        setSenderImageView()
        return self
    }
}


