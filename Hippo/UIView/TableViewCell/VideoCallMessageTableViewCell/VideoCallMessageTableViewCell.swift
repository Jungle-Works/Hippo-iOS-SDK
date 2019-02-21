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
    
    @IBOutlet weak var sourceIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
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
    func intalizeCell(with message: HippoMessage) {
        self.message = message
        setSourceIcon()
    }
    internal func setSourceIcon() {
        let showMessageSourceIcon = HippoConfig.shared.appUserType == .agent ? true : HippoProperty.current.showMessageSourceIcon
        let icon =  showMessageSourceIcon ? message?.messageSource.getIcon() :  nil
        sourceIcon?.image = icon
        sourceIcon?.isHidden = icon == nil
        sourceIcon?.tintColor = HippoConfig.shared.theme.sourceIconColor
        
        
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
      self.message = message
      
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


