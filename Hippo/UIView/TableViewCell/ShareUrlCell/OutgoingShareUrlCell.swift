//
//  OutgoingShareUrlCell.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/06/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

protocol OutgoingShareUrlDelegate: class {
    func openJitsiUrl(url: String)
}

final class OutgoingShareUrlCell: MessageTableViewCell {

    //MARK:- IBOutlets
    @IBOutlet private weak var labelHeading : UILabel!
    @IBOutlet private weak var labelBusinessName : UILabel!
    @IBOutlet private weak var imageVideoIcon : UIImageView!
    @IBOutlet private weak var shadowView: So_UIView!
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var readUnreadImageView: So_UIImageView!
    @IBOutlet private weak var buttonJoinCall: UIButton!
    @IBOutlet private weak var viewUpper: UIView!
    
    
    //MARK:- Variables
    var indexPath: IndexPath?
    weak var delegate: OutgoingShareUrlDelegate?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewUpper.backgroundColor = HippoConfig.shared.theme.themeColor
        buttonJoinCall.setTitleColor(.black, for: .normal)
        buttonJoinCall.setBackgroundColor(color: .white, forState: .normal)
        labelHeading.font = UIFont.bold(ofSize: 15)
        labelBusinessName.font = UIFont.regular(ofSize: 14)
        labelHeading.textColor = HippoConfig.shared.theme.shareUrlTextColor
        labelBusinessName.textColor = HippoConfig.shared.theme.shareUrlTextColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func configureCellOfShareUrlCell(isIncoming: Bool, resetProperties: Bool, chatMessageObject: HippoMessage, indexPath: IndexPath) -> OutgoingShareUrlCell {
        if resetProperties {
            resetPropertiesOfOutgoingCell(isIncoming: isIncoming)
        }
        
        message?.statusChanged = nil
        
        super.intalizeCell(with: chatMessageObject, isIncomingView: false)
        self.message = chatMessageObject
        self.indexPath = indexPath
        labelHeading.text = HippoStrings.meeting
        labelBusinessName.text = currentUserType() == .customer ? (userDetailData["business_name"] as? String ?? "") : (HippoConfig.shared.agentDetail?.businessName ?? "") + " " + HippoStrings.businessMeet
        buttonJoinCall.setTitle(HippoStrings.joinCallNow, for: .normal)
        
        message?.statusChanged = {[weak self]() in
            DispatchQueue.main.async {
                self?.setReadUnreadStatus()
            }
        }
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        
        setReadUnreadStatus()
       
        let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        timeLabel.text = "\(timeOfMessage)"
        timeLabel.textColor = HippoConfig.shared.theme.outgoingMsgDateTextColor//UIColor.white
        return self
    }
    
    
    func resetPropertiesOfOutgoingCell(isIncoming: Bool) {
        backgroundColor = .clear
        selectionStyle = .none
        timeLabel.text = ""
        mainContentView.layer.cornerRadius = 10
        mainContentView.clipsToBounds = true
    
        shadowView.layer.cornerRadius = mainContentView.layer.cornerRadius
        if isIncoming {
            if #available(iOS 11.0, *) {
                mainContentView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                shadowView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }else {
            if #available(iOS 11.0, *) {
                mainContentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                shadowView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    
        
//        readUnreadImageView.image = UIImage(named: "readMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)
        readUnreadImageView.image = UIImage(named: "unreadMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)
        readUnreadImageView.tintColor = HippoConfig.shared.theme.unreadTintColor
    }
    
    
    private func adjustShadow() {
        mainContentView.layoutIfNeeded()
        shadowView.clipsToBounds = true
        shadowView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor
    }
    
    private func setupBoxBackground(messageType: Int) {
        mainContentView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
    }
    
    
    private func setReadUnreadStatus() {
        readUnreadImageView.tintColor = nil
        
        guard let messageReadStatus = message?.status else {
            return
        }
        
        switch messageReadStatus {
        case .sent:
            readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
            if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
//            if let tintColor = HippoConfig.shared.theme.unreadMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
            
//        case .read:
        case .read, .delivered:
            readUnreadImageView.image = HippoConfig.shared.theme.readMessageTick
            if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        default:
            readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
            if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        }
    }
    
    @IBAction private func actionJoinCall() {
        self.delegate?.openJitsiUrl(url: message?.message ?? "")
    }
    
}
