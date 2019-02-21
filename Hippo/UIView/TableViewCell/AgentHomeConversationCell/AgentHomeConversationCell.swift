//
//  AgentHomeConversationCell.swift
//  Fugu
//
//  Created by vishal on 18/06/18.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class AgentHomeConversationCell: UITableViewCell {
    
    @IBOutlet weak var closedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var containerBckgrnd: So_UIImageView!
    @IBOutlet weak var closedLabel: So_CustomLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: So_CustomLabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var leftSideView: So_UIView!
    @IBOutlet weak var heightOfLeftContainer: NSLayoutConstraint!
    @IBOutlet weak var leftSideLabel: So_CustomLabel!
    @IBOutlet weak var rightSideView: So_UIView!
    @IBOutlet weak var heightOfRightContainer: NSLayoutConstraint!
    @IBOutlet weak var rightSideLabel: So_CustomLabel!
    @IBOutlet weak var counterLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLine: So_UIView!
    
    @IBOutlet weak var transitionView: So_UIView!
    @IBOutlet weak var transitionImageView: So_UIImageView!
    @IBOutlet weak var transitionLabel: So_CustomLabel!
    
    var arrayTagList = [TagBoxInfo]()
    var tagViewHeight: CGFloat = 22.5
    var cellData: AgentConversation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        containerBckgrnd.image = UIColor.clear.createImage(withFrameSize: CGSize(width: 10, height: 30))
//        containerBckgrnd.highlightedImage = UIColor.veryLightBlue.createImage(withFrameSize: CGSize(width: 10, height: 30))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - Configure Cell Methods
extension AgentHomeConversationCell {
    func resetCell() {
        backgroundColor = .clear
        clipsToBounds = true
        selectionStyle = .none
        
        timeLabel.text = ""
        counterLabel.isHidden = true
        
        leftSideView.layer.borderWidth = 0.5
        rightSideView.layer.borderWidth = 0.5
        
        transitionView.isHidden = true
        transitionLabel.text = ""
        transitionImageView.image = nil
        
        nameLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
        lastMessageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
        timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
    }
    
    func setupCell(resetProperties: Bool = true, cellInfo: AgentConversation) {
        if resetProperties {
            resetCell()
        }
        cellData?.messageUpdated = nil
        cellData?.unreadCountupdated = nil
        //Setting self data
        self.cellData =  cellInfo
        
        cellData?.messageUpdated = {
            DispatchQueue.main.async {
                if let data = self.cellData {
                    self.setupCell(resetProperties: false, cellInfo: data)
                }
            }
        }
        cellData?.unreadCountupdated = {
            DispatchQueue.main.async {
                self.setUnreadCount()
            }
        }
        
        //Set Time
        timeLabel.text = cellData?.formattedTime
        
        //Setting unreadCount
        setUnreadCount()
        
        //Setting setting close label
        if let cellChatStatus = cellInfo.status, cellChatStatus == ChatStatus.close.rawValue {
            closedLabel.text = "   Closed   "
            closedViewWidthConstraint.constant = 55
        } else {
            closedLabel.text = ""
            closedViewWidthConstraint.constant = 0
        }
        
        //Setting channel name
        nameLabel.text = (closedLabel.text!.isEmpty ? "" : "  ") + (cellInfo.label ?? "")
        
        //Setting last message
        lastMessageLabel.text = cellInfo.displayingMessage
        
        //Setting tags
        setTags()
    }
    
    func setUnreadCount() {
        if let totalCount = cellData?.unreadCount, totalCount > 0 {
            counterLabel.text = "\(totalCount)"
            counterLabel.isHidden = false
            nameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
            lastMessageLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
            timeLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        } else {
            counterLabel.isHidden = true
            nameLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
            lastMessageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
            timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
        }
    }
    
    func setTags() {
        arrayTagList.removeAll()
        
        guard let data = cellData else {
            return
        }
        if let unassignedTag = self.getAssignedStatusTag(info: data) {
            arrayTagList.append(unassignedTag)
        }
        if let botChannelTag = self.getBotChannelTag(info: data) {
            arrayTagList.append(botChannelTag)
        }
        self.setTagView()
    }
    func setTagView() {
        setTagViewDefault()
        guard !arrayTagList.isEmpty else {
            return
        }
        heightOfLeftContainer.constant = tagViewHeight
        
        leftSideView.backgroundColor = arrayTagList[0].containerBckgrndColor
        leftSideView.layer.borderColor = arrayTagList[0].containerBorderColor?.cgColor
        
        leftSideLabel.text = arrayTagList[0].labelText
        leftSideLabel.textColor = arrayTagList[0].textColor
        leftSideLabel.font = arrayTagList[0].textFont
        
        if arrayTagList.count > 1 {
            heightOfRightContainer.constant = tagViewHeight
            rightSideView.backgroundColor = arrayTagList[1].containerBckgrndColor
            rightSideView.layer.borderColor = arrayTagList[1].containerBorderColor?.cgColor
            rightSideLabel.text = arrayTagList[1].labelText
            rightSideLabel.textColor = arrayTagList[1].textColor
            rightSideLabel.font = arrayTagList[1].textFont
        }
    }
    func setTagViewDefault() {
        heightOfLeftContainer.constant = 0
        leftSideView.backgroundColor = .clear
        leftSideLabel.text = ""

        heightOfRightContainer.constant = 0
        rightSideView.backgroundColor = .clear
        rightSideLabel.text = ""
    }
    
    func getBotChannelTag(info: AgentConversation) -> TagBoxInfo? {
        var tag: TagBoxInfo?
        let botChannelName = info.bot_channel_name ?? ""
        
        guard !botChannelName.isEmpty else {
            return nil
        }
        tag = TagBoxInfo(labelText: botChannelName, textColor: .purpleGrey, containerBackgroundColor: .veryLightBlue, containerBorderColor: UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1))
        return tag
    }
    func getAssignedStatusTag(info: AgentConversation) -> TagBoxInfo? {
        var tag: TagBoxInfo?
        let agentID = info.agent_id ?? -1
        
        let unassignedColorForClosedChat = UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1)
        
        if agentID <= 0 {
            if let closedString = closedLabel.text, closedString.isEmpty == false {
                tag = TagBoxInfo(labelText: "Unassigned", textColor: .purpleGrey, containerBackgroundColor: .veryLightBlue, containerBorderColor: unassignedColorForClosedChat)
            } else {
                tag = TagBoxInfo(labelText: "Unassigned", textColor: .white, containerBackgroundColor: .pumpkinOrange)
            }
        } else if let agentName = info.agent_name {
                tag = TagBoxInfo(labelText: agentName, textColor: .purpleGrey, containerBackgroundColor: .veryLightBlue, containerBorderColor: UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1))
        }
        return tag
    }
}

extension AgentHomeConversationCell {
    struct TagBoxInfo {
        var labelText = ""
        var textColor: UIColor?
        var textFont: UIFont?
        var containerBckgrndColor: UIColor?
        var containerBorderColor: UIColor?
        
        init(labelText: String, textColor: UIColor, textFont: UIFont = UIFont.systemFont(ofSize: 11), containerBackgroundColor: UIColor, containerBorderColor: UIColor = .clear) {
            self.labelText = labelText
            self.textColor = textColor
            self.textFont = textFont
            self.containerBckgrndColor = containerBackgroundColor
            self.containerBorderColor = containerBorderColor
        }
    }
}
