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
    @IBOutlet weak var nameLabel: UILabel!
   // @IBOutlet weak var constraint_Height : NSLayoutConstraint!
    
    override func awakeFromNib() {
        
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
            print("default")
            //bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
            bgView.backgroundColor = HippoConfig.shared.theme.recievingBubbleColor
        }
    }
    
    func adjustShadow() {
        bgView.layoutIfNeeded()
    }
    
    func updateBottomConstraint(_ constant : CGFloat){
        self.bottomConstraint.constant = constant
        self.layoutIfNeeded()
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
        
        nameLabel.font = HippoConfig.shared.theme.senderNameFont
        
//        DispatchQueue.main.async {
//            let gradient = CAGradientLayer()
//            gradient.frame = self.bgView.bounds
//            gradient.colors = [HippoConfig.shared.theme.themeColor, HippoConfig.shared.theme.themeColor.cgColor]
//            self.bgView.layer.insertSublayer(gradient, at: 0)
//
//           //self.shadowView.backgroundColor = UIColor.red
//        }
        
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            bgView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        //bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
       // bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
      //  bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        supportMessageTextView.backgroundColor = .clear
        supportMessageTextView.textContainer.lineFragmentPadding = 0
        supportMessageTextView.textContainerInset = .zero
    }
    
    func configureCellOfSupportIncomingCell(resetProperties: Bool,attributedString: NSMutableAttributedString,channelId: Int,chatMessageObject: HippoMessage) -> SupportMessageTableViewCell
    {
        if resetProperties { resetPropertiesOfSupportCell() }
        
        message?.messageRefresed = nil
        
        super.intalizeCell(with: chatMessageObject, isIncomingView: true)
        let messageType = chatMessageObject.type
        
        message?.messageRefresed = {
            DispatchQueue.main.async {
                self.setSenderImageView()
            }
        }
        
        //self.nameLabel.text = message?.senderFullName
        
        let isMessageAllowedForImage = chatMessageObject.type == .consent  || chatMessageObject.belowMessageType == .card || chatMessageObject.belowMessageType == .paymentCard || chatMessageObject.aboveMessageType == .consent
        
        if (chatMessageObject.aboveMessageUserId == chatMessageObject.senderId && !isMessageAllowedForImage) {
            self.nameLabel.text = ""
        } else {
            self.nameLabel.text = message?.senderFullName
        }
        
        setupBoxBackground(messageType: messageType)
        
        setTime()
        

        supportMessageTextView.attributedText = attributedString
        setSenderImageView()
        return self
    }
}


