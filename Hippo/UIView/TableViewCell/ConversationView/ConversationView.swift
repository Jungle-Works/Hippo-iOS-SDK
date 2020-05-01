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
        
        channelImageView.image = nil
        channelImageView.layer.masksToBounds = true
        channelImageView.layer.cornerRadius = 5
        channelImageView.contentMode = .scaleAspectFill
        
        placeHolderImageButton?.isHidden = true
        placeHolderImageButton?.setImage(nil, for: .normal)
        placeHolderImageButton?.layer.cornerRadius = 0.0
        placeHolderImageButton?.backgroundColor = .white
        placeHolderImageButton?.setTitle("", for: .normal)
        
        unreadCountLabel.layer.masksToBounds = true
        unreadCountLabel.text = ""
        unreadCountLabel.backgroundColor = .clear
        msgStatusWidthConstraint?.constant = 0
        leadingConstraintOfLastMessage?.constant = 0
        
        msgStatusImageView?.image = nil
        timeLabel.textColor = UIColor.black.withAlphaComponent(0.37)
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
            unreadCountLabel.backgroundColor = UIColor.red//.themeColor
                //#colorLiteral(red: 0.8666666667, green: 0.09019607843, blue: 0.1176470588, alpha: 1).withAlphaComponent(isThisChatOpened(opened: isOpened))
            unreadCountLabel.layer.cornerRadius = (unreadCountLabel.bounds.height - 5) / 2
            unreadCountLabel.layer.masksToBounds = true
            unreadCountLabel.textColor = UIColor.white
        } else {
            theme = HippoConfig.shared.theme.conversationListNormalTheme
            //         headingLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
            //         chatTextLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
            //         timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
        }
        
        statusLabel.isHidden = isOpened
        statusLabel.font = theme.timeTheme.textFont
        statusLabel.textColor = HippoConfig.shared.theme.gradientTopColor
        statusLabel.text = "closed"
            
        headingLabel.setTheme(theme: theme.titleTheme)
        chatTextLabel.setTheme(theme: theme.lastMessageTheme)
        timeLabel.setTheme(theme: theme.timeTheme)
        unreadCountLabel.font = theme.timeTheme.textFont
        
        channelImageView.image = nil
        channelImageView.alpha = isThisChatOpened(opened: isOpened)
        
        if let channelImage = conersationObj.channelImageUrl, channelImage.isEmpty == false, let url = URL(string: channelImage) {
            channelImageView.kf.setImage(with: url)
            channelImageView.backgroundColor = nil
        } else if let channelName = conersationObj.label, channelName.isEmpty == false {
            placeHolderImageButton?.alpha = isThisChatOpened(opened: isOpened)
            placeHolderImageButton?.isHidden = false
            placeHolderImageButton?.setImage(nil, for: .normal)
            placeHolderImageButton?.backgroundColor = .lightGray
            
            let channelNameInitials = channelName.trimWhiteSpacesAndNewLine()
//            placeHolderImageButton?.setTitle(String(channelNameInitials.remove(at: channelNameInitials.startIndex)).capitalized, for: .normal)
//            placeHolderImageButton?.layer.cornerRadius = 15.0
            let color = getRandomColor()
            if channelImageView.backgroundColor == nil{
                channelImageView.setTextInImage(string: channelNameInitials, color: color, circular: false, textAttributes: nil)
                channelImageView.backgroundColor = color
            }else{
               channelImageView.setTextInImage(string: channelNameInitials, color: channelImageView.backgroundColor, circular: false, textAttributes: nil)
            }
           
        }
        
        //      chatTextLabel.textColor = HippoConfig.shared.theme.conversationLastMsgColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
        
        var messageString = ""
        if let last_sent_by_id = conersationObj.lastMessage?.senderId, let userId = HippoUserDetail.fuguUserID, last_sent_by_id == userId {
            messageString = "You: "
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
                messageToBeShown += "Attachment: Image"
            case .attachment:
                messageToBeShown += "sent a file"
            case .call:
                messageToBeShown = lastMessage.getVideoCallMessage(otherUserName: "")
            default:
                let messageString = lastMessage.message.removeNewLine()
                let senderNAme = lastMessage.senderFullName
                let message = messageString.isEmpty ? " sent a message" : messageString
                messageToBeShown = ""
                if !senderNAme.isEmpty {
                    messageToBeShown = senderNAme + ": "
                }
                messageToBeShown += message
            }
            chatTextLabel.text = messageToBeShown
        }
        
        timeLabel.textColor = HippoConfig.shared.theme.timeTextColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
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
    
    func getRandomColor() -> UIColor {
         //Generate between 0 to 1
         let red:CGFloat = CGFloat(drand48())
         let green:CGFloat = CGFloat(drand48())
         let blue:CGFloat = CGFloat(drand48())

         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
}
