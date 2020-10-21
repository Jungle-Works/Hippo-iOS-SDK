//
//  SelfMessageTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 29/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
protocol SelfMessageDelegate: class {
   func cancelMessage(message: HippoMessage)
   func retryMessageUpload(message: HippoMessage)
}

class SelfMessageTableViewCell: MessageTableViewCell {
    
    @IBOutlet weak var warningViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cannelButtonOutlet: UIButton!
    @IBOutlet weak var retryButtonOutlet: UIButton!
    @IBOutlet weak var warningImage: So_UIImageView!
    @IBOutlet weak var warningLabel: So_CustomLabel!
    @IBOutlet weak var warningView: UIView!
    
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var selfMessageTextView: UITextView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var readUnreadImageView: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var indexPath: IndexPath?
    weak var delegate: SelfMessageDelegate?
    var messageLongPressed : ((HippoMessage)->())?
    
    override func awakeFromNib() {
        selfMessageTextView.backgroundColor = .clear
        selfMessageTextView.textContainer.lineFragmentPadding = 0
        selfMessageTextView.textContainerInset = .zero
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGestureFired))
        longPressGesture.minimumPressDuration = 0.3
        bgView?.addGestureRecognizer(longPressGesture)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func longPressGestureFired(sender: UIGestureRecognizer) {
       guard sender.state == .began else {
          return
       }
        if let message = message{
            messageLongPressed?(message)
        }
    }
    
    func setupBoxBackground(messageType: MessageType) {
        switch messageType {
        case .privateNote:
            bgView.backgroundColor = HippoConfig.shared.theme.privateNoteChatBoxColor
        default:
            bgView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
        }

    }
    
    @IBAction func canecelButtonAction(_ sender: UIButton) {
        guard let messageObj = message else {
            return
        }
        if !messageObj.isANotification() {
            delegate?.cancelMessage(message: messageObj)
        }
    }
    @IBAction func retryButtonAction(_ sender: UIButton) {
        guard let messageObj = message else {
            return
        }
        if !messageObj.isANotification() {
            delegate?.retryMessageUpload(message: messageObj)
        }
    }
    
    func resetPropertiesOfOutgoingMessage() {
        //selectionStyle = .none
        
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
        
        selfMessageTextView.backgroundColor = .clear
        selfMessageTextView.textContainer.lineFragmentPadding = 0
        selfMessageTextView.textContainerInset = .zero
        
        //chatImageView.image = nil
       // chatImageView.layer.cornerRadius = 4.0
        
       // heightImageView.constant = 0
        
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            bgView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        bgView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
        if let tintColor = HippoConfig.shared.theme.unreadMessageTintColor {
            readUnreadImageView.tintColor = tintColor
        }
    }
    
    func configureIncomingMessageCell(resetProperties: Bool, chatMessageObject: HippoMessage, indexPath: IndexPath) -> SelfMessageTableViewCell {
        if resetProperties {
            resetPropertiesOfOutgoingMessage()
        }
        message?.statusChanged = nil
        
        super.intalizeCell(with: chatMessageObject, isIncomingView: false)
        
        message = chatMessageObject
        
        message?.statusChanged = {
            DispatchQueue.main.async {
                self.setReadUnreadIcon()
            }
        }
        self.indexPath = indexPath
        setupWarningView()
        let messageType = chatMessageObject.type
        setupBoxBackground(messageType: messageType)
        
        
        setReadUnreadIcon()
        
        switch HippoConfig.shared.appUserType {
        case .agent:
            selfMessageTextView.text = ""
            selfMessageTextView.attributedText = Helper.getIncomingAttributedStringWithLastUserCheck(chatMessageObject: chatMessageObject)
        case .customer:
            selfMessageTextView.attributedText = nil
            selfMessageTextView.text =  chatMessageObject.message
        }
        setTime()
        return self
    }
    func getIncomingAttributedString(chatMessageObject: HippoMessage) -> NSMutableAttributedString {
        let messageString = chatMessageObject.message
        let userNameString = chatMessageObject.senderFullName
        
        
        return attributedStringForLabel(userNameString, secondString: "\n" + messageString, thirdString: "", colorOfFirstString: HippoConfig.shared.theme.senderNameColor, colorOfSecondString: HippoConfig.shared.theme.outgoingMsgColor, colorOfThirdString: UIColor.black.withAlphaComponent(0.5), fontOfFirstString: HippoConfig.shared.theme.senderNameFont, fontOfSecondString:  HippoConfig.shared.theme.incomingMsgFont, fontOfThirdString: UIFont.regular(ofSize: 11.0), textAlighnment: .left, dateAlignment: .right)
    }
    
    func setupWarningView() {
        guard let messageObject = self.message else {
            return
        }
      
        if messageObject.wasMessageSendingFailed, messageObject.status == .none, messageObject.type != .imageFile {
         warningView.isHidden = false
            self.warningViewHeightConstraint.constant = 40
        } else {
         warningView.isHidden = true
            self.warningViewHeightConstraint.constant = 0
        }
    }
    
    func updateBottomConstraint(_ constant : CGFloat){
        self.bottomConstraint.constant = constant
        self.layoutIfNeeded()
    }
    
    private func setReadUnreadIcon() {
        guard let messageReadStatus = message?.status else {
            return
        }
        
        switch messageReadStatus {
//        case .read:
        case .read, .delivered:
            readUnreadImageView.image = HippoConfig.shared.theme.readMessageTick
            if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        case .sent:
            readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
            if let tintColor = HippoConfig.shared.theme.unreadMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        default:
            readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
            if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        }
    }
}


