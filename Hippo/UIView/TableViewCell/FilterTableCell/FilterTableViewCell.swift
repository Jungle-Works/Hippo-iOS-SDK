//
//  FilterTableViewCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 12/07/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

//class FilterTableViewCell: CoreTabelViewCell {
class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var heightWidthOfImage: NSLayoutConstraint!
    @IBOutlet weak var horizontalLineColor: UIView!
    @IBOutlet weak var centerYTickImageView: NSLayoutConstraint!
    
    @IBOutlet weak var topSpaceHorizontalLine: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension FilterTableViewCell {

    func resetPropertiesOfFilterCell() {
        backgroundColor = .clear
        selectionStyle = .none
        clipsToBounds = true
        horizontalLineColor.isHidden = true
    }
    
    func configureFilterCell(resetProperties: Bool, isLastCell: Bool = false, cellInfo: FilterField) -> FilterTableViewCell {
        if resetProperties == true {
            resetPropertiesOfFilterCell()
        }
        
        var textleadingSpace = ""
        if cellInfo.isAnyImage == true {
            heightWidthOfImage.constant = 24
            textleadingSpace = "  "
        } else {
            heightWidthOfImage.constant = 0
        }
        
        filterLabel.text = textleadingSpace + (cellInfo.nameOfField)
        
        if cellInfo.selected == true {
//            filterLabel.font = UIFont.boldProximaNova(withSize: 19)
            filterLabel.font = UIFont.bold(ofSize: 19)//UIFont.boldSystemFont(ofSize: 19)
//            filterLabel.textColor = .darkColor
//            tickImageView.image = HippoImage.current.multipleAgentSelected
            tickImageView.image = HippoConfig.shared.theme.checkBoxActive
//            tickImageView.tintColor = HippoTheme.current.themeColor
            tickImageView.tintColor = HippoConfig.shared.theme.checkBoxActiveTintColor
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
        } else {
//            filterLabel.font = UIFont.regularProximaNova(withSize: 19)
            filterLabel.font = UIFont.regular(ofSize: 19)
//            filterLabel.textColor = .dirtyPurple
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
//            tickImageView.image = HippoImage.current.multipleAgentUnSelected?.withRenderingMode(.alwaysOriginal)
            tickImageView.image = HippoConfig.shared.theme.checkBoxInActive
//            tickImageView.tintColor = HippoTheme.current.buttonUnselectedColor
            tickImageView.tintColor = HippoConfig.shared.theme.checkBoxInActiveTintColor

        }
        
        if cellInfo.isSectionTitle == true {
            centerYTickImageView.constant = 4
        } else {
            centerYTickImageView.constant = 0
        }
        
        if isLastCell == true {
            topSpaceHorizontalLine.constant = 16
            horizontalLineColor.isHidden = false
        } else {
            topSpaceHorizontalLine.constant = -1
        }
        return self
    }
    
//    func configureAgentAnalyticsCell(resetProperties: Bool, agentObject: Agent, selectedAgents: [Int]) -> FilterTableViewCell {
//        if resetProperties == true {
//            resetPropertiesOfFilterCell()
//        }
//
//        let agentId = agentObject.userId ?? -1
//
//        if agentId == agentUserID {
//            filterLabel.text = "  You"
//        } else {
//            filterLabel.text = "  " + (agentObject.fullName ?? "")
//        }
//
//        if selectedAgents.contains(agentId) {
//            filterLabel.font = UIFont.boldProximaNova(withSize: 19)
//            filterLabel.textColor = .darkColor
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
//        } else {
//            filterLabel.font = UIFont.regularProximaNova(withSize: 19)
//            filterLabel.textColor = .dirtyPurple
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
//        }
//
//        return self
//    }
//
//    func configureChannelAnalyticsCell(resetProperties: Bool, channelObject: Channel, selectedChannels: [Int]) -> FilterTableViewCell {
//        if resetProperties == true {
//            resetPropertiesOfFilterCell()
//        }
//
//        let channelId = channelObject.channelID ?? -1
//
//        filterLabel.text = "  " + (channelObject.channelName ?? "")
//
//        if selectedChannels.contains(channelId) {
//            filterLabel.font = UIFont.boldProximaNova(withSize: 19)
//            filterLabel.textColor = .darkColor
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
//        } else {
//            filterLabel.font = UIFont.regularProximaNova(withSize: 19)
//            filterLabel.textColor = .dirtyPurple
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
//        }
//
//        return self
//    }
//
//    func configureTagAnalyticsCell(resetProperties: Bool, tagObject: TagDetail, selectedTags: [Int]) -> FilterTableViewCell {
//        if resetProperties == true {
//            resetPropertiesOfFilterCell()
//        }
//
//        let tagId = tagObject.tagId ?? -1
//        filterLabel.text = "  " + (tagObject.tagName ?? "")
////        if tagId == agentUserID {
////            filterLabel.text = "  You"
////        } else {
////            filterLabel.text = "  " + (agentObject.fullName ?? "")
////        }
//
//        if selectedTags.contains(tagId) {
//            filterLabel.font = UIFont.boldProximaNova(withSize: 19)
//            filterLabel.textColor = .darkColor
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
//        } else {
//            filterLabel.font = UIFont.regularProximaNova(withSize: 19)
//            filterLabel.textColor = .dirtyPurple
//            tickImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
//        }
//
//        return self
//    }
    
    func configureFilterCellSelected(resetProperties: Bool, isSelected: Bool) -> FilterTableViewCell {
        if resetProperties == true {
            resetPropertiesOfFilterCell()
        }
        
        filterLabel.text = "  Select All"
        
        if isSelected {
//            filterLabel.font = UIFont.boldProximaNova(withSize: 19)
            filterLabel.font = UIFont.bold(ofSize: 19)//UIFont.boldSystemFont(ofSize: 19)
            filterLabel.textColor = .darkColor
            tickImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
        } else {
//            filterLabel.font = UIFont.regularProximaNova(withSize: 19)
            filterLabel.font = UIFont.regular(ofSize: 19)
            filterLabel.textColor = .dirtyPurple
            tickImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
        }
        
        return self
    }
}
