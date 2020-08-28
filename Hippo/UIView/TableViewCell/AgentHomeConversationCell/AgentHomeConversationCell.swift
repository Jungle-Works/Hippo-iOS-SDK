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
    @IBOutlet weak var counterLabelContainerView: UIView!
    @IBOutlet weak var counterLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLine: So_UIView!
    
    @IBOutlet weak var transitionView: So_UIView!
    @IBOutlet weak var transitionImageView: So_UIImageView!
    @IBOutlet weak var transitionLabel: So_CustomLabel!
    
    @IBOutlet weak var channelImageView: So_UIImageView!
    
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
        counterLabelContainerView.isHidden = true
        counterLabel.isHidden = true
        
        //channelImageView.image = nil
        channelImageView.layer.masksToBounds = true
        channelImageView.layer.cornerRadius = 5
        channelImageView.contentMode = .scaleAspectFill
        
        leftSideView.layer.borderWidth = 0.5
        rightSideView.layer.borderWidth = 0.5
        
        transitionView.isHidden = true
        transitionLabel.text = ""
        //transitionImageView.image = nil
        
//        nameLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
//        lastMessageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
//        timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
        self.setLabelsFont()
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
        self.setUnreadCount()
            
        //Setting setting close label
        if let cellChatStatus = cellInfo.status, cellChatStatus == ChatStatus.close.rawValue {
            closedLabel.text = HippoStrings.closed
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
        
//        if let channelImage = cellData?.user_image, channelImage.isEmpty == false, let url = URL(string: channelImage) {
        if let channelImage = cellData?.user_image, channelImage.isEmpty == false, channelImage.contains("http"), let url = URL(string: channelImage) {
            channelImageView.kf.setImage(with: url)
            channelImageView.backgroundColor = nil
        }
        
        if channelImageView.image == nil{
            if let channelName = cellData?.label, channelName.isEmpty == false {
                let channelNameInitials = channelName.trimWhiteSpacesAndNewLine()
                let color = cellData?.channelBackgroundColor
                channelImageView.setTextInImage(string: channelNameInitials, color: color, circular: false, textAttributes: nil)
            }
        }
        
    }
    
    func setUnreadCount() {
        if let totalCount = cellData?.unreadCount, totalCount > 0 {
            counterLabel.text = "\(totalCount)"
            counterLabelContainerView.isHidden = false
            counterLabel.isHidden = false
            counterLabelContainerView.layer.cornerRadius = counterLabelContainerView.frame.size.height/2
            lastMessageLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
//            nameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
//            lastMessageLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
//            timeLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
            self.setLabelsFont()
        } else {
            counterLabelContainerView.isHidden = true
            counterLabel.isHidden = true
            lastMessageLabel.textColor = UIColor(red: 165/255, green: 181/255, blue: 184/255, alpha: 1.0)
//            nameLabel.font = UIFont(name:"HelveticaNeue", size: 15.0)
//            lastMessageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
//            timeLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
            self.setLabelsFont()
        }
    }
    
    func setLabelsFont(){
        nameLabel.font = UIFont.bold(ofSize: 16.0)
        lastMessageLabel.font = UIFont.regular(ofSize: 15.0)
        timeLabel.font = UIFont.regular(ofSize: 12.5)
        closedLabel.font = UIFont.regular(ofSize: 12.5)
    }
    
    func setTags() {
        arrayTagList.removeAll()
        
        guard let data = cellData else {
            return
        }
        if data.notificationType == nil{
            self.getUnassignedTag(data: data)
        }else if let type = data.notificationType, type == .assigned || type == .message{
            self.getUnassignedTag(data: data)
        }else{}
        
        if let botChannelTag = self.getBotChannelTag(info: data) {
            arrayTagList.append(botChannelTag)
        }
        self.setTagView()
    }
    func getUnassignedTag(data: AgentConversation){
        if let unassignedTag = self.getAssignedStatusTag(info: data) {
            arrayTagList.append(unassignedTag)
        }
    }
    func setTagView() {
        setTagViewDefault()
        guard !arrayTagList.isEmpty, cellData?.chatType != .o2o else {
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
        let botInProgress = info.isBotInProgress
        if botInProgress{
            tag = TagBoxInfo(labelText: "Bot in progress", textColor: .darkGrayColorForTag, containerBackgroundColor: .lightGrayBgColorForTag, containerBorderColor: UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1))
            return tag
        }else{
            return nil
        }
    }
    func getAssignedStatusTag(info: AgentConversation) -> TagBoxInfo? {
        var tag: TagBoxInfo?
        let agentID = info.agent_id ?? -1
        
        let unassignedColorForClosedChat = UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1)
        
        if agentID <= 0 {
            if let closedString = closedLabel.text, closedString.isEmpty == false {
//                tag = TagBoxInfo(labelText: "Unassigned", textColor: .purpleGrey, containerBackgroundColor: .veryLightBlue, containerBorderColor: unassignedColorForClosedChat)
                tag = TagBoxInfo(labelText: HippoStrings.unassigned, textColor: .darkGrayColorForTag, containerBackgroundColor: .lightGrayBgColorForTag, containerBorderColor: unassignedColorForClosedChat)
            } else {
                tag = TagBoxInfo(labelText: HippoStrings.unassigned, textColor: .white, containerBackgroundColor: .pumpkinOrange)
            }
        }
//        else if let agentName = info.agent_name {
////                tag = TagBoxInfo(labelText: agentName, textColor: .purpleGrey, containerBackgroundColor: .veryLightBlue, containerBorderColor: UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1))
//            guard let loginAgent = HippoConfig.shared.agentDetail, loginAgent.id > 0 else {
//                return tag
//            }
//            if loginAgent.agentUserType == .admin{
//                tag = TagBoxInfo(labelText: agentName, textColor: .darkGrayColorForTag, containerBackgroundColor: .lightGrayBgColorForTag, containerBorderColor: UIColor.makeColor(red: 228, green: 228, blue: 237, alpha: 1))
//            }
//        }
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
        
//        init(labelText: String, textColor: UIColor, textFont: UIFont = UIFont.systemFont(ofSize: 11), containerBackgroundColor: UIColor, containerBorderColor: UIColor = .clear) {
        init(labelText: String, textColor: UIColor, textFont: UIFont = UIFont.bold(ofSize: 13), containerBackgroundColor: UIColor, containerBorderColor: UIColor = .clear) {
            self.labelText = labelText
            self.textColor = textColor
            self.textFont = textFont
            self.containerBckgrndColor = containerBackgroundColor
            self.containerBorderColor = containerBorderColor
        }
    }

    
}
