//
//  BroadcastAgentCell.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class BroadcastAgentCell: UITableViewCell {
    //MARK: constants
    
    
    //MARK: variable
    var agentInfo: UserDetail?
    var teamInfo: TagDetail?
    var type: selectionType = .none

    //MARK: Outlet
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        switch type {
        case .multiple:
            cellImageView.image = selected ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive
        case .single:
            cellImageView.image = selected ? HippoConfig.shared.theme.radioActive : HippoConfig.shared.theme.radioInActive
        case .none:
            break
            
        }
    }
    
    func setData(agentInfo: UserDetail) {
        self.agentInfo = agentInfo
        type = .multiple
        cellLabel.text = (agentInfo.name ?? agentInfo.email ?? "-----")
    }
    
    func setData(teamInfo: TagDetail, isSelected: Bool) {
        self.teamInfo = teamInfo
        type = .single
        cellLabel.text = (teamInfo.tagName ?? "-----")
    }
    
    enum selectionType {
        case multiple
        case single
        case none
    }
    
}
