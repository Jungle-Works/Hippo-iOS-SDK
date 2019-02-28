//
//  ConversationView.swift
//  Fugu
//
//  Created by Gagandeep Arora on 25/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

enum ChannelStatus: Int { case open = 1, close = 0 }

class ConversationView : UITableViewCell {
    @IBOutlet weak var msgStatusWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var msgStatusImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var chatTextLabel: UILabel!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var placeHolderImageButton: UIButton!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var channelImageView: So_UIImageView!
    @IBOutlet var unreadCountLabel: UILabel!
    @IBOutlet var unreadCountWidthLabel: NSLayoutConstraint!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var leadingConstraintOfLastMessage: NSLayoutConstraint!
    
    override func awakeFromNib() { super.awakeFromNib()
        msgStatusWidthConstraint.constant = 0
        leadingConstraintOfLastMessage.constant = 0
        msgStatusImageView.image = nil
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
        
        selectionView.backgroundColor = .clear
        
        headingLabel.text = ""
        chatTextLabel.text = ""
        timeLabel.text = ""
        
        channelImageView.image = nil
        channelImageView.layer.masksToBounds = true
        channelImageView.layer.cornerRadius = 15.0
        
        placeHolderImageButton.isHidden = true
        placeHolderImageButton.setImage(nil, for: .normal)
        placeHolderImageButton.layer.cornerRadius = 0.0
        placeHolderImageButton.backgroundColor = .white
        placeHolderImageButton.setTitle("", for: .normal)
        unreadCountLabel.layer.masksToBounds = true
        unreadCountLabel.text = ""
        unreadCountLabel.backgroundColor = .clear
        msgStatusWidthConstraint.constant = 0
        leadingConstraintOfLastMessage.constant = 0
        
        msgStatusImageView.image = nil
        timeLabel.textColor = UIColor.black.withAlphaComponent(0.37)
    }
    
   func configureConversationCell(resetProperties: Bool, conersationObj: FuguConversation) {
      if resetProperties {
         resetPropertiesOfConversationView()
      }
      
      var isOpened = true
      let channelStatus = conersationObj.channelStatus
      
      if channelStatus == ChannelStatus.close,
         let labelId = conersationObj.labelId,
         labelId < 0 {
         isOpened = false
      }
      
      bgView.backgroundColor = UIColor.white.withAlphaComponent(isThisChatOpened(opened: isOpened))
      
      headingLabel.textColor = HippoConfig.shared.theme.conversationTitleColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
      
      if let channelName = conersationObj.label,
         channelName.characters.count > 0 {
         headingLabel.text = channelName
      }
      
      if let unreadCount = conersationObj.unreadCount,
         unreadCount > 0 {
         bgView.backgroundColor =  UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
         headingLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
         chatTextLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
         timeLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
         
         unreadCountLabel.text = "\(unreadCount)"
         unreadCountLabel.backgroundColor = HippoConfig.shared.theme.unReadMessageCounterColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
        var unreadCountWidth = (unreadCountLabel.text?.width(withConstraintedHeight: unreadCountLabel.bounds.height, font: unreadCountLabel.font))! + 2
        unreadCountWidth = (unreadCountWidth > CGFloat(unreadCountLabel.bounds.height)) ?  unreadCountWidth : CGFloat(unreadCountLabel.bounds.height)
        unreadCountWidthLabel.constant = unreadCountWidth
         unreadCountLabel.layer.cornerRadius = 9.5
      } else {
         headingLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
         chatTextLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
         timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
      }
      
      channelImageView.image = nil
      channelImageView.alpha = isThisChatOpened(opened: isOpened)
      
      if let channelImage = conersationObj.channelImage,
         channelImage.isEmpty == false,
         let url = URL(string: channelImage) {
         channelImageView.kf.setImage(with: url)
      } else if let channelName = conersationObj.label,
         channelName.isEmpty == false {
         placeHolderImageButton.alpha = isThisChatOpened(opened: isOpened)
         placeHolderImageButton.isHidden = false
         placeHolderImageButton.setImage(nil, for: .normal)
         placeHolderImageButton.backgroundColor = .lightGray
         
         var channelNameInitials = channelName.trimWhiteSpacesAndNewLine()
         placeHolderImageButton.setTitle(String(channelNameInitials.remove(at: channelNameInitials.startIndex)).capitalized, for: .normal)
         placeHolderImageButton.layer.cornerRadius = 15.0
      }
      
      chatTextLabel.textColor = HippoConfig.shared.theme.conversationLastMsgColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
      
      var messageString = ""
      if let last_sent_by_id = conersationObj.lastMessage?.senderId, let userId = HippoConfig.shared.userDetail?.fuguUserID, last_sent_by_id == userId {
         messageString = "You: "
         msgStatusWidthConstraint.constant = 17
         leadingConstraintOfLastMessage.constant = 2
         msgStatusImageView.contentMode = .center
         if let lastMessageStatus = conersationObj.lastMessage?.status, lastMessageStatus == .read {
            msgStatusImageView.image = UIImage(named: "readMsgTick", in: HippoFlowManager.bundle, compatibleWith: nil)
         } else {
            msgStatusImageView.image = UIImage(named: "unreadMsgTick", in: HippoFlowManager.bundle, compatibleWith: nil)
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
         default:
            messageToBeShown = "\(lastMessage.senderFullName) sent a message"
         }
         
         chatTextLabel.text = messageToBeShown
      }
      
      timeLabel.textColor = HippoConfig.shared.theme.timeTextColor.withAlphaComponent(isThisChatOpened(opened: isOpened))
      
      if let channelId = conersationObj.channelId,
         channelId <= 0 {
         timeLabel.text = ""
      } else if let dateTime = conersationObj.lastMessage?.creationDateTime {
         timeLabel.text = dateTime.toString
      }
   }
    
    func isThisChatOpened(opened: Bool) -> CGFloat {
        return opened ? 1 : 0.5
    }
}
