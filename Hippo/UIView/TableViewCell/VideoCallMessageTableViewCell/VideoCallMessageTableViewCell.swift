//
//  VideoCallMessageTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 11/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

protocol VideoCallMessageTableViewCellDelegate: AnyObject {
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
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameView: UIView!
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
            phoneIcon.image = UIImage(named: "missed", in: FuguFlowManager.bundle, compatibleWith: nil)
            phoneIcon.tintColor = UIColor.white
            
            
        } else {
           // messageLabel.textColor =  HippoConfig.shared.theme.incomingMsgColor
            
            messageBackgroundView.backgroundColor = HippoConfig.shared.theme.callAgainColor
            
            callAgainButton.setTitle(HippoStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "incomming", in: FuguFlowManager.bundle, compatibleWith: nil)
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
    nameLbl.font = HippoConfig.shared.theme.broadcastTitleInfoFont
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
        if message.senderFullName != HippoConfig.shared.agentDetail?.fullName ?? "" && message.senderFullName != "Visitor"{
            nameLbl.text = message.senderFullName
        }else{
            nameLbl.text = "You"
        }
        if message.isMissedCall {
           
            callAgainButton.setTitle(HippoStrings.callback, for: .normal)
            phoneIcon.image = UIImage(named: "missed", in: FuguFlowManager.bundle, compatibleWith: nil)
            phoneIcon.tintColor = UIColor.black
            
            
        } else {
           // messageLabel.textColor = HippoConfig.shared.theme.outgoingMsgColor
            callAgainButton.setTitle(HippoStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "outgoing", in: FuguFlowManager.bundle, compatibleWith: nil)
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
        // Collapse the "<missed> <type> <call>" template, dropping the type word (and
        // its space) when the medium is unknown — e.g. the conversation list, whose
        // payload has no call_type.
        func joined(_ parts: String...) -> String {
            parts.filter { !$0.trimWhiteSpacesAndNewLine().isEmpty }.joined(separator: " ")
        }
        let callTypeString = isCallTypeKnown ? getCallTypeString() : ""

        if let activeVideoCallID = CallManager.shared.findActiveCallUUID(), messageUniqueID == activeVideoCallID {
            return joined(HippoStrings.ongoing_call, callTypeString, HippoStrings.call)
        }

        if isMissedCall {
            return joined(HippoStrings.missed, callTypeString, HippoStrings.call)
        } else {
            return joined(HippoStrings.the, callTypeString, HippoStrings.callEnded) + "."
        }
    }
    
    fileprivate func getFormattedVideoCallDuration() -> String? {
        guard let duration = callDurationInSeconds else {
            return nil
        }
        
        return (dateComponentFormatter.string(from: duration) ?? "") + " \(HippoStrings.at)"
    }
    enum CallIconKind {
        case incoming, outgoing, missed
    }
    
    /// Call-log glyph for this message (customer-facing call cards): the video set for a
    /// known video call, otherwise the voice set (also the fallback when the payload has
    /// no call_type). Template-rendered so the card's call-icon colour tokens tint it.
    func callIcon(_ kind: CallIconKind) -> UIImage? {
        let isVideo = isCallTypeKnown && callType == .video
        let name: String
        switch kind {
        case .incoming: name = isVideo ? "incommingVideoCall" : "incomming"
        case .outgoing: name = isVideo ? "outgoingVideoCall" : "outgoing"
        case .missed:   name = isVideo ? "missedVideoCall" : "missed"
        }
        return UIImage(named: name, in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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


