//
//  VideoCallMessageTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 11/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

protocol VideoCallMessageTableViewCellDelegate: class {
    func callAgainButtonPressed(callType: CallType)
}

private var dateComponentFormatter: DateComponentsFormatter = {
   let formatter = DateComponentsFormatter()
   formatter.allowedUnits = [.hour, .minute, .second]
   formatter.unitsStyle = .short
   return formatter
}()


class MessageTableViewCell: UITableViewCell {
    var message: HippoMessage?
    var isIncomingView: Bool = false
    
    @IBOutlet weak var sourceIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    @IBOutlet weak var senderImageTraillingConstaints: NSLayoutConstraint!
    @IBOutlet weak var senderImageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func getTimeString() -> String {
        guard message != nil else {
            return ""
        }
        let timeOfMessage = changeDateToParticularFormat(message!.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        return timeOfMessage
    }
    func setTime() {
       let timeOfMessage = getTimeString()
        timeLabel.text = timeOfMessage
    }
    func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        self.message?.messageRefresed = nil
        self.message = message
        self.isIncomingView = isIncomingView
        setSourceIcon()
        
        
        self.message?.messageRefresed = {
            DispatchQueue.main.async {
                self.setSenderImageView()
            }
        }
        setSenderImageView()
    }
    internal func setSourceIcon() {
        let showMessageSourceIcon = HippoConfig.shared.appUserType == .agent ? true : HippoProperty.current.showMessageSourceIcon
        let icon =  showMessageSourceIcon ? message?.messageSource.getIcon() :  nil
        sourceIcon?.image = icon
        sourceIcon?.isHidden = icon == nil
        sourceIcon?.tintColor = HippoConfig.shared.theme.sourceIconColor
    }
    
    func setSenderImageView() {
        guard let message = self.message, isIncomingView, message.chatType.isImageViewAllowed else {
            hideSenderImageView()
            return
        }
        showSenderImageView()
        
        let isMessageAllowedForImage = message.type == .consent
        
        if message.belowMessageUserId == message.senderId && !isMessageAllowedForImage {
            unsetImageInSender()
        } else if let senderImage = message.senderImage, let url = URL(string: senderImage) {
            setImageInSenderView(imageURL: url)
        } else {
            setNameAsTitle(message.senderFullName)
        }
    }
    
    func hideSenderImageView() {
        senderImageView?.image = nil
        senderImageView?.isHidden = true
        senderImageWidthConstraint?.constant = 0
        senderImageTraillingConstaints?.constant = 0
        layoutIfNeeded()
    }
    
    func showSenderImageView() {
        senderImageView.isHidden = false
        senderImageWidthConstraint.constant = 30
        senderImageTraillingConstaints.constant = 5
        senderImageView.cornerRadius = senderImageView.bounds.height / 2
        layoutIfNeeded()
    }
    
    func setImageInSenderView(imageURL: URL?) {
        senderImageView.kf.setImage(with: imageURL, placeholder: HippoConfig.shared.theme.placeHolderImage,  completionHandler: {(_, error, _, _) in
            guard let parsedError = error else {
                return
            }
            print(parsedError.localizedDescription)
        })
    }
    
    func setNameAsTitle(_ name: String?) {
        if let parsedName = name {
            self.senderImageView.setImage(string: parsedName, color: UIColor.lightGray, circular: true)
        } else {
            self.senderImageView.image = HippoConfig.shared.theme.placeHolderImage
        }
    }
    
    func unsetImageInSender() {
        senderImageView.image = nil
    }
}
class VideoCallMessageTableViewCell: MessageTableViewCell {
   
   // MARK: - Properties
   @IBOutlet weak var dateTimeLabel: UILabel!
   @IBOutlet weak var messageLabel: UILabel!
   
    @IBOutlet weak var centerLineView: UIView!
    @IBOutlet weak var retryButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var callAgainButton: UIButton!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var callDurationLabel: UILabel!
   
   
   weak var delegate: VideoCallMessageTableViewCellDelegate?
   
   // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.font = HippoConfig.shared.theme.incomingMsgFont
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        callDurationLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        callDurationLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        
        messageBackgroundView.layer.masksToBounds = true
        messageBackgroundView.layer.cornerRadius = 5
        
        messageBackgroundView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        messageBackgroundView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
    }
   
   // MARK: - IBAction
   @IBAction func callAgainButtonPressed(_ sender: UIButton) {
    delegate?.callAgainButtonPressed(callType: message?.callType ?? .video)
   }
   
   func setDuration() {
      callDurationLabel.text = message?.getFormattedVideoCallDuration()
   }
}

class IncomingVideoCallMessageTableViewCell: VideoCallMessageTableViewCell {
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      messageBackgroundView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
   }

   
    func setCellWith(message: HippoMessage, isCallingEnabled: Bool) {
        super.intalizeCell(with: message, isIncomingView: true)
        
        if message.isMissedCall {
            messageLabel.textColor = UIColor.red
        } else {
            messageLabel.textColor = UIColor.black
        }
        messageLabel.text = message.getVideoCallMessage(otherUserName: "🎥")
        
        retryButtonHeight.constant = isCallingEnabled ? 35 : 0
        callAgainButton.isEnabled = isCallingEnabled
        callAgainButton.isHidden = !isCallingEnabled
        centerLineView.isHidden = !isCallingEnabled
        
        dateTimeLabel.text = getTimeString()
        setDuration()
    }
   
}

class OutgoingVideoCallMessageTableViewCell: VideoCallMessageTableViewCell {
   override func awakeFromNib() {
      super.awakeFromNib()
      
      messageBackgroundView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
   }
   
   
    func setCellWith(message: HippoMessage, otherUserName: String, isCallingEnabled: Bool) {
        self.message = message
        
        if message.isMissedCall {
            messageLabel.textColor = UIColor.black
        } else {
            messageLabel.textColor = UIColor.black
        }
        
        messageLabel.text = message.getVideoCallMessage(otherUserName: otherUserName)
        
        retryButtonHeight.constant = isCallingEnabled ? 35 : 0
        callAgainButton.isEnabled = isCallingEnabled
        callAgainButton.isHidden = !isCallingEnabled
        centerLineView.isHidden = !isCallingEnabled
        
        dateTimeLabel.text = getTimeString()
        setDuration()
        
    }
}

extension HippoMessage {
    func getVideoCallMessage(otherUserName: String) -> String {
        let callTypeString = getCallTypeString()
        
        if let activeVideoCallID = CallManager.shared.findActiveCallUUID(), messageUniqueID == activeVideoCallID {
            return "Ongoing \(callTypeString) call"
        }
        let tempOtherUser = otherUserName.isEmpty ? "Other user" : otherUserName
        
        if isMissedCall {
            if isSentByMe() {
                return "\(tempOtherUser) missed a \(callTypeString) call with you"
            } else {
                return "You missed a \(callTypeString) call with \(senderFullName)"
            }
        } else {
            return "The \(callTypeString) call ended."
        }
    }
    
    fileprivate func getFormattedVideoCallDuration() -> String? {
        guard let duration = callDurationInSeconds else {
            return nil
        }
        
        return (dateComponentFormatter.string(from: duration) ?? "") + " at"
    }
    func getCallTypeString() -> String {
        switch callType {
        case .video:
            return "video"
        case .audio:
            return "voice"
        }
    }
    
}


