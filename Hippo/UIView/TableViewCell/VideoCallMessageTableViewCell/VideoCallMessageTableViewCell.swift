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

class VideoCallMessageTableViewCell: MessageTableViewCell {
   
   // MARK: - Properties
   @IBOutlet weak var dateTimeLabel: UILabel!
   @IBOutlet weak var messageLabel: UILabel!
   
    @IBOutlet weak var centerLineView: UIView!
    @IBOutlet weak var retryButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var callAgainButton: UIButton!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var callDurationLabel: UILabel!
   
    @IBOutlet weak var phoneIcon: UIImageView!
    
   weak var delegate: VideoCallMessageTableViewCellDelegate?
   
   // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.font = HippoConfig.shared.theme.incomingMsgFont
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        callDurationLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        callDurationLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        callAgainButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)

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
    
      messageBackgroundView.layer.cornerRadius = 10
      messageBackgroundView.backgroundColor = HippoConfig.shared.theme.callAgainColor
    
    if #available(iOS 11.0, *) {
        messageBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    } else {
        // Fallback on earlier versions
    }
   }

   
    func setCellWith(message: HippoMessage, isCallingEnabled: Bool) {
        super.intalizeCell(with: message, isIncomingView: true)
        
        if message.isMissedCall {
            
            messageBackgroundView.backgroundColor = HippoConfig.shared.theme.missedCallColor
            callAgainButton.setTitle(HippoStrings.callback, for: .normal)
            phoneIcon.image = UIImage(named: "missed")
            phoneIcon.tintColor = UIColor.white
            
            
        } else {
           // messageLabel.textColor =  HippoConfig.shared.theme.incomingMsgColor
            
            messageBackgroundView.backgroundColor = HippoConfig.shared.theme.callAgainColor
            
            callAgainButton.setTitle(HippoStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "incomming")
        }
        
        messageLabel.textColor = UIColor.white
        messageLabel.text = message.getVideoCallMessage(otherUserName: "🎥")
        callAgainButton.setTitleColor(UIColor.white, for: .normal)
        
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
    
    messageBackgroundView.layer.cornerRadius = 10
    
    if #available(iOS 11.0, *) {
        messageBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    } else {
        // Fallback on earlier versions
    }
    
   }
   
   
    func setCellWith(message: HippoMessage, otherUserName: String, isCallingEnabled: Bool) {
        self.message = message
        
        if message.isMissedCall {
           
            callAgainButton.setTitle(HippoStrings.callback, for: .normal)
            phoneIcon.image = UIImage(named: "missed")
            phoneIcon.tintColor = UIColor.black
            
            
        } else {
           // messageLabel.textColor = HippoConfig.shared.theme.outgoingMsgColor
            callAgainButton.setTitle(HippoStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "outgoing")
            phoneIcon.tintColor = UIColor.black
        }
        
       //  messageLabel.textColor = UIColor.white
        messageLabel.text = message.getVideoCallMessage(otherUserName: otherUserName)
        callAgainButton.setTitleColor(UIColor.black, for: .normal)
        centerLineView.backgroundColor = UIColor.black
        
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
            return "\(HippoStrings.ongoing_call) \(callTypeString) \(HippoStrings.call)"
        }
       // let tempOtherUser = otherUserName.isEmpty ? "Other user" : otherUserName
        
        if isMissedCall {
            if isSentByMe() {
                return "\(HippoStrings.missed) \(callTypeString) \(HippoStrings.call)"//"\(tempOtherUser) missed a \(callTypeString) call with you"
            } else {
                return "\(HippoStrings.missed) \(callTypeString) \(HippoStrings.call)"//"You missed a \(callTypeString) call with \(senderFullName)"
            }
        } else {
            return "\(HippoStrings.the) \(callTypeString) \(HippoStrings.callEnded)."
        }
    }
    
    fileprivate func getFormattedVideoCallDuration() -> String? {
        guard let duration = callDurationInSeconds else {
            return nil
        }
        
        return (dateComponentFormatter.string(from: duration) ?? "") + " \(HippoStrings.at)"
    }
    func getCallTypeString() -> String {
        switch callType {
        case .video:
            return HippoStrings.video
        case .audio:
            return HippoStrings.voice
        }
    }
    
}


