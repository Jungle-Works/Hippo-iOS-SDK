//
//  ConversationView.swift
//  Fugu
//
//  Created by Gagandeep Arora on 25/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

extension UILabel {
    func setTheme(theme: HippoLabelTheme) {
        textColor = theme.textColor
        font = theme.textFont
    }
}

class ConversationView: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var msgStatusWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var msgStatusImageView: UIImageView?
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var chatTextLabel: UILabel!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var placeHolderImageButton: UIButton?
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var channelImageView: So_UIImageView!
    @IBOutlet var unreadCountLabel: UILabel!
    @IBOutlet var unreadCountWidthLabel: NSLayoutConstraint?
    @IBOutlet weak var selectionView: UIView?
    @IBOutlet weak var leadingConstraintOfLastMessage: NSLayoutConstraint?
    @IBOutlet weak var view_Unread : UIView!
    
    
    override func awakeFromNib() { super.awakeFromNib()
        msgStatusWidthConstraint?.constant = 0
        leadingConstraintOfLastMessage?.constant = 0
        msgStatusImageView?.image = nil
    }
    
    deinit {}
    
    override func setSelected(_ selected: Bool,
                              animated: Bool) {
        super.setSelected(selected,
                          animated: animated)
    }
}

extension ConversationView {
    func resetPropertiesOfConversationView() {
        selectionStyle = .none
        backgroundColor = .clear
        selectionView?.backgroundColor = .clear
        
        headingLabel.text = ""
        chatTextLabel.text = ""
        timeLabel.text = ""
        channelImageView.layer.masksToBounds = true
        channelImageView.layer.cornerRadius = 5
        channelImageView.contentMode = .scaleAspectFill
        
        placeHolderImageButton?.isHidden = true
        placeHolderImageButton?.setImage(nil, for: .normal)
        placeHolderImageButton?.layer.cornerRadius = 0.0
        placeHolderImageButton?.backgroundColor = .white
        placeHolderImageButton?.setTitle("", for: .normal)
        
 
        unreadCountLabel.text = ""
        view_Unread.backgroundColor = .clear
        msgStatusWidthConstraint?.constant = 0
        leadingConstraintOfLastMessage?.constant = 0
        
        msgStatusImageView?.image = nil
       // timeLabel.textColor = UIColor.black.withAlphaComponent(0.37)
    }
    
    
    
    func configureConversationCell(resetProperties: Bool, conersationObj: FuguConversation) {
        if resetProperties {
            resetPropertiesOfConversationView()
        }
        
        var isOpened = true
        let channelStatus = conersationObj.channelStatus
        
        if channelStatus == ChatStatus.close {
            isOpened = false
          //  bgView.backgroundColor = UIColor.red //HippoConfig.shared.theme.gradientBackgroundColor
            
        }
        
        if isOpened
        {
          bgView.backgroundColor = UIColor.white
        }
        else
        {
            bgView.backgroundColor = UIColor.white//HippoConfig.shared.theme.gradientBackgroundColor
        }
         
       //bgView.backgroundColor = UIColor.white.withAlphaComponent(isThisChatOpened(opened: isOpened))
        
        headingLabel.textColor = HippoConfig.shared.theme.conversationTitleColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
        
        if let channelName = conersationObj.label, channelName.count > 0 {
            headingLabel.text = channelName
        }
        
        let theme: ConversationListTheme
        
        if let unreadCount = conersationObj.unreadCount, unreadCount > 0 {//}, isOpened {
            theme = HippoConfig.shared.theme.conversationListUnreadTheme
            //         headingLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            //         chatTextLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
            //         timeLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
              
            unreadCountLabel.text = "  \(unreadCount)  "
            view_Unread.backgroundColor = HippoConfig.shared.theme.unreadCountColor
                //#colorLiteral(red: 0.8666666667, green: 0.09019607843, blue: 0.1176470588, alpha: 1).withAlphaComponent(isThisChatOpened(opened: isOpened))
            view_Unread.layer.cornerRadius = view_Unread.frame.size.height/2
            unreadCountLabel.textColor = UIColor.white
           // timeLabel.textColor =  UIColor(red: 74/255 , green: 74/255, blue: 74/255, alpha: 1.0)
            
        } else {
            theme = HippoConfig.shared.theme.conversationListNormalTheme
           // timeLabel.textColor =  UIColor(red: 74/255 , green: 74/255, blue: 74/255, alpha: 1.0)
            //         headingLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
            //         chatTextLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
            //         timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
        }
        
        statusLabel.isHidden = true
//        statusLabel.font = theme.timeTheme.textFont
//        statusLabel.textColor = HippoConfig.shared.theme.gradientTopColor
//        statusLabel.text = "closed"
            
        headingLabel.setTheme(theme: theme.titleTheme)
        chatTextLabel.setTheme(theme: theme.lastMessageTheme)
        timeLabel.setTheme(theme: theme.timeTheme)
        unreadCountLabel.font = theme.timeTheme.textFont
        channelImageView.alpha = isThisChatOpened(opened: isOpened)
        
        if let imageUrl = conersationObj.channelImageUrl{
            let url = URL(string: imageUrl)
            let channelNameInitials = conersationObj.label?.trimWhiteSpacesAndNewLine()
            let color = conersationObj.channelBackgroundColor
            let imageViewNew = UIImageView.init(frame: channelImageView.frame)
            imageViewNew.setTextInImage(string: channelNameInitials, color: color, circular: false, textAttributes: nil)
            channelImageView.kf.setImage(with: url, placeholder: imageViewNew.image, options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            let channelName = conersationObj.label
            placeHolderImageButton?.alpha = isThisChatOpened(opened: isOpened)
            placeHolderImageButton?.isHidden = false
            placeHolderImageButton?.setImage(nil, for: .normal)
            placeHolderImageButton?.backgroundColor = .lightGray
            let channelNameInitials = channelName?.trimWhiteSpacesAndNewLine()
            let color = conersationObj.channelBackgroundColor
            channelImageView.setTextInImage(string: channelNameInitials, color: color, circular: false, textAttributes: nil)
            
        }
            
        
        var messageString = ""
        if let last_sent_by_id = conersationObj.lastMessage?.senderId, let userId = HippoUserDetail.fuguUserID, last_sent_by_id == userId {
            messageString = "\(HippoStrings.you): "
            msgStatusWidthConstraint?.constant = 17
            leadingConstraintOfLastMessage?.constant = 2
            msgStatusImageView?.contentMode = .center
//            if let lastMessageStatus = conersationObj.lastMessage?.status, lastMessageStatus == .read {
            if let lastMessageStatus = conersationObj.lastMessage?.status, lastMessageStatus == .read || lastMessageStatus == .delivered{
                msgStatusImageView?.image = UIImage(named: "readMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)
                msgStatusImageView?.tintColor = HippoConfig.shared.theme.readTintColor
            } else {
//                msgStatusImageView?.image = UIImage(named: "readMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)
//                msgStatusImageView?.tintColor = HippoConfig.shared.theme.unreadTintColor
                msgStatusImageView?.image = UIImage(named: "unreadMessageImage", in: FuguFlowManager.bundle, compatibleWith: nil)
                msgStatusImageView?.tintColor = HippoConfig.shared.theme.unreadTintColor
            }
        } else if let last_sent_by_full_name = conersationObj.lastMessage?.senderFullName, (conersationObj.lastMessage?.senderId ?? -1) > 0 {
            if last_sent_by_full_name.isEmpty {
                messageString = ""
            } else {
                messageString = "\(last_sent_by_full_name): "
            }
        }
        if let lastMessage = conersationObj.lastMessage {
            var messageToBeShown = messageString
            switch lastMessage.type {
            case .normal:
                messageToBeShown += lastMessage.message.removeNewLine()
            case .imageFile:
                messageToBeShown += HippoStrings.attachmentImage
            case .attachment:
                messageToBeShown += "sent a file"
            case .call:
                messageToBeShown = lastMessage.getVideoCallMessage(otherUserName: "")
            default:
                let messageString = lastMessage.message.removeNewLine()
                let senderNAme = lastMessage.senderFullName
                let message = messageString.isEmpty ? " \(HippoStrings.messageSent)" : messageString
                messageToBeShown = ""
                if !senderNAme.isEmpty {
                    //messageToBeShown = senderNAme + ": "
                }
                messageToBeShown += message
            }
    
            if conersationObj.lastMessage?.messageState == .MessageDeleted {
                if lastMessage.senderId == currentUserId(){
                    messageToBeShown = HippoStrings.you + " " + HippoStrings.deleteMessage
                }else{
                    messageToBeShown = lastMessage.senderFullName + " " + HippoStrings.deleteMessage
                }
            }
            
            chatTextLabel.text = messageToBeShown
            
        }
        
      //  timeLabel.textColor = HippoConfig.shared.theme.timeTextColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
        let channelID = conersationObj.channelId ?? -1
        if channelID <= 0 {
            timeLabel.text = ""
        } else if let dateTime = conersationObj.lastMessage?.creationDateTime {
            timeLabel.text = dateTime.toString
        }
    }
    
    func isThisChatOpened(opened: Bool) -> CGFloat {
        return opened ? 1 : 0.5
    }
    
  
}
