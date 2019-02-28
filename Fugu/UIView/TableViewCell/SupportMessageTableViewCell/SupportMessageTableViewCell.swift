//
//  SupportMessageTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 29/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class SupportMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var supportMessageTextView: UITextView!
    @IBOutlet var dateTimeLabel: UILabel!
    //@IBOutlet var supportImageView: UIImageView!
    //@IBOutlet weak var heightImageView: NSLayoutConstraint!
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
    
    func setupBoxBackground(messageType: Int) {
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
    }
    
    func adjustShadow() {
        // shadowView.layoutIfNeeded()
        bgView.layoutIfNeeded()
        
        // shadowView.layer.cornerRadius = self.bgView.layer.cornerRadius
        
        // shadowView.backgroundColor = //UIColor.makeColor(red: 234, green: 234, blue: 234, alpha: 0.3)
        //self.shadowView.roundCorner(cornerRect: .allCorners, cornerRadius: self.shadowView.layer.cornerRadius)
    }
    
    func resetPropertiesOfSupportCell() {
        selectionStyle = .none
        supportMessageTextView.text = ""
        supportMessageTextView.attributedText = nil
        supportMessageTextView.isEditable = false
        supportMessageTextView.dataDetectorTypes = UIDataDetectorTypes.all
        supportMessageTextView.backgroundColor = .clear
        
        dateTimeLabel.text = ""
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
        
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
//        supportImageView.layer.cornerRadius = 4.0
//        supportImageView.image = nil
//        heightImageView.constant = 0
    }
    
    func configureCellOfSupportIncomingCell(resetProperties: Bool,
                                            attributedString: NSMutableAttributedString,
                                            channelId: Int,
                                            chatMessageObject: FuguMessage) -> SupportMessageTableViewCell {
        if resetProperties { resetPropertiesOfSupportCell() }
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)


            let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
            dateTimeLabel.text = "\t" + "\(timeOfMessage)"
      
        supportMessageTextView.attributedText = attributedString
        
        return self
    }
}


