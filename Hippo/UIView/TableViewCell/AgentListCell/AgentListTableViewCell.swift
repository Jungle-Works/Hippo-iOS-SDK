//
//  AgentListTableViewswift
//  Fugu
//
//  Created by Gagandeep Arora on 22/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class AgentListTableViewCell: UITableViewCell { //CoreTabelViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusContanierView: UIView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSelectionLine: UIView!
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var userImageView: So_UIImageView!
    @IBOutlet weak var nameLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLineView: So_UIView!
    @IBOutlet weak var userOnlineStatus: UIView!
    
    var agent: Agent?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageWidthConstraint.constant = 44
        setTheme()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setTheme() {
//        let theme = HippoTheme.theme
        nameLabel.font = UIFont.regular(ofSize: 17.0)
        nameLabel.textColor = HippoConfig.shared.theme.lightThemeTextColor//theme.label.primary
        backgroundColor = .clear
        horizontalLineView.backgroundColor = UIColor.gray//theme.sepratorColor
    }
   
}

//MARK: - Configure Cell
extension AgentListTableViewCell {
    func resetPropertiesOfAgentCell() {
        backgroundColor = .clear
        clipsToBounds = true
        statusContanierView.isHidden = true
        setTheme()
    }
    
    func configureAgentCell(resetProperties: Bool, agentObject: Agent) -> AgentListTableViewCell {
        if resetProperties == true {
            resetPropertiesOfAgentCell()
        }
        agent = agentObject

        if let agentId = agentObject.userId, agentId == currentUserId(){//agentUserID {
            nameLabel.text = HippoStrings.me
        } else {
            nameLabel.text = agentObject.fullName ?? ""
        }

        setImage()
        if let status = agentObject.onlineStatus {
            self.statusContanierView.isHidden = false
            statusImageView.setStatusImageView(status: status)
        }
        return self
    }
    
    func setupSuggestaionTableCell(resetProperties: Bool = true, agentObject: Agent) -> AgentListTableViewCell {
        if resetProperties == true {
            resetPropertiesOfAgentCell()
            userImageView.backgroundColor = .clear
            userImageView.contentMode = .scaleAspectFill
            selectionStyle = .none
        }
        agent = agentObject
        nameLabel.text =  agentObject.fullName ?? ""
//        mainContentView.backgroundColor = UIColor.veryLightBlue
        selectionStyle = .none
        imageWidthConstraint.constant = 44
        setImage()
//        nameLabel.textColor = UIColor.black
        
        if let status = agentObject.onlineStatus {
            statusContanierView.isHidden = false
            statusImageView.setStatusImageView(status: status)
        }
        return self
    }
    func configureAgentAnalyticsCell(resetProperties: Bool, agentObject: Agent, selectedAgents: [Int]) -> AgentListTableViewCell {
        if resetProperties == true {
            resetPropertiesOfAgentCell()
            userImageView.backgroundColor = .clear
            userImageView.contentMode = .center
            selectionStyle = .none
        }
        
        let agentId = agentObject.userId ?? -1
        
        if agentId == currentUserId() {
            nameLabel.text = HippoStrings.me
        } else {
            nameLabel.text = agentObject.fullName ?? ""
        }
        
        if let imageString = agentObject.userImageString {
            self.userImageView.displayImage(imageString: imageString, placeHolderImage: #imageLiteral(resourceName: "user_placeholder_icon"))
        }
        
        if selectedAgents.contains(agentId) {
            userImageView.image = HippoConfig.shared.theme.checkBoxActive//#imageLiteral(resourceName: "checkbox_active_icon")
        } else {
            userImageView.image = HippoConfig.shared.theme.checkBoxInActive//#imageLiteral(resourceName: "checkbox_inactive_icon")
        }
        return self
    }
    
    func setImage() {
        let placeHolder = HippoConfig.shared.theme.userPlaceHolderImage        
        if let imageString = agent?.userImageString?.trimmingCharacters(in: .whitespacesAndNewlines), !imageString.isEmpty {
            userImageView.displayImage(imageString: imageString, placeHolderImage: placeHolder)
        } else {
            userImageView.image = placeHolder
        }
    }
    
//    func configureChannelAnalyticsCell(resetProperties: Bool, channelObject: Channel, selectedChannels: [Int]) -> AgentListTableViewCell {
//        if resetProperties == true {
//            resetPropertiesOfAgentCell()
//            userImageView.backgroundColor = .clear
//            userImageView.contentMode = .center
//            selectionStyle = .none
//        }
//        
//        let channelId = channelObject.channelID ?? -1
//        
//        nameLabel.text = channelObject.channelName ?? ""
//        
//        if selectedChannels.contains(channelId) {
//            userImageView.image = #imageLiteral(resourceName: "checkbox_active_icon")
//        } else {
//            userImageView.image = #imageLiteral(resourceName: "checkbox_inactive_icon")
//        }
//        
//        return self
//    }
}
