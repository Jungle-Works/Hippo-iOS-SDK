//
//  SelfMessageTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 29/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
protocol SelfMessageDelegate: class {
   func cancelMessage(message: FuguMessage)
   func retryMessageUpload(message: FuguMessage)
}
class SelfMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var warningViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cannelButtonOutlet: UIButton!
    @IBOutlet weak var retryButtonOutlet: UIButton!
    @IBOutlet weak var warningImage: So_UIImageView!
    @IBOutlet weak var warningLabel: So_CustomLabel!
    @IBOutlet weak var warningView: UIView!
    
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var selfMessageTextView: UITextView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var readUnreadImageView: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var messageObj = FuguMessage(message: "", type: .normal)
    var indexPath: IndexPath?
    weak var delegate: SelfMessageDelegate?
    
    override func awakeFromNib() {
        selfMessageTextView.backgroundColor = .clear
        selfMessageTextView.textContainer.lineFragmentPadding = 0
        selfMessageTextView.textContainerInset = .zero
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupBoxBackground(messageType: Int) {
        bgView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor

    }
    
    @IBAction func canecelButtonAction(_ sender: UIButton) {
        if !messageObj.isANotification() {
            delegate?.cancelMessage(message: messageObj)
        }
    }
    @IBAction func retryButtonAction(_ sender: UIButton) {
        if !messageObj.isANotification() {
            delegate?.retryMessageUpload(message: messageObj)
        }
    }
    
    func resetPropertiesOfOutgoingMessage() {
        selectionStyle = .none
        
        selfMessageTextView.text = ""
        selfMessageTextView.isEditable = false
        selfMessageTextView.dataDetectorTypes = UIDataDetectorTypes.all
        selfMessageTextView.textAlignment = .left
        selfMessageTextView.font =  HippoConfig.shared.theme.inOutChatTextFont
        selfMessageTextView.textColor = HippoConfig.shared.theme.outgoingMsgColor
        selfMessageTextView.backgroundColor = .clear
        
        timeLabel.text = ""
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textAlignment = .right
        timeLabel.textColor = HippoConfig.shared.theme.outgoingMsgDateTextColor
        
        //chatImageView.image = nil
       // chatImageView.layer.cornerRadius = 4.0
        
       // heightImageView.constant = 0
        
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
        if let tintColor = HippoConfig.shared.theme.unreadMessageTintColor {
            readUnreadImageView.tintColor = tintColor
        }
    }
    
    func configureIncomingMessageCell(resetProperties: Bool, chatMessageObject: FuguMessage, indexPath: IndexPath) -> SelfMessageTableViewCell {
        if resetProperties {
         resetPropertiesOfOutgoingMessage()
      }
        messageObj = chatMessageObject
        self.indexPath = indexPath
        setupWarningView()
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)

       // readUnreadImageView.tintColor = nil
        let messageReadStatus = chatMessageObject.status
            if messageReadStatus == ReadUnReadStatus.none {
                readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
                if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
                    readUnreadImageView.tintColor = tintColor
                }
            } else if messageReadStatus == ReadUnReadStatus.read {
                readUnreadImageView.image = HippoConfig.shared.theme.readMessageTick
                if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
                    readUnreadImageView.tintColor = tintColor
                }
            }
        
        

            selfMessageTextView.text = chatMessageObject.message
      
        

            let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
            timeLabel.text = "\(timeOfMessage)"
        
      
        return self
    }
    
    func setupWarningView() {
       let messageObject = self.messageObj
      
        if messageObject.wasMessageSendingFailed, messageObject.status == .none, messageObject.type != .imageFile {
         warningView.isHidden = false
            self.warningViewHeightConstraint.constant = 40
        } else {
         warningView.isHidden = true
            self.warningViewHeightConstraint.constant = 0
        }
    }
}


