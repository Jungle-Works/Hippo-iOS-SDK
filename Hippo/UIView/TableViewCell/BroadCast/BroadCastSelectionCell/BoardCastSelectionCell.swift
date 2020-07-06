//
//  BoardCastSelectionCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class BoardCastSelectionCell: UITableViewCell {
    

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    //MARK: Variables
    var manager: HippoBroadcaster?
    var selectionType: BroadCastScreenRow?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInitalUI()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInitalUI() {
        cellImageView.image = HippoConfig.shared.theme.forwardIcon
        cellImageView.tintColor = HippoConfig.shared.theme.forwordIconTintColor
    }
    
    func setData(manager: HippoBroadcaster, type: BroadCastScreenRow) {
        self.manager = manager
        self.selectionType = type
        switch type {
        case .selectAgent:
            setUpForAgentSelection()
        case .selectTeam:
            setUpForTeamSelection()
        case .showAgent:
            setUpForShowAgents()
        default:
            break
        }
    }
    
    func setUpForTeamSelection() {
        cellImageView.isHidden = false
        cellLabel.textColor = UIColor.black
        bottomLineView.backgroundColor = UIColor.lightGray
        
        cellLabel.text = manager?.selectedTeam?.tagName ?? HippoConfig.shared.strings.selectTeamsString
    }
    
    func setUpForAgentSelection() {
        let isTeamSelected = manager?.selectedTeam != nil &&  manager?.selectedTeam?.tagId != -100
        
        cellImageView.tintColor = isTeamSelected ? UIColor.black : UIColor.lightGray
        cellLabel.textColor = isTeamSelected ? UIColor.black : UIColor.lightGray
        bottomLineView.backgroundColor = isTeamSelected ? UIColor.lightGray : UIColor.lightGray.withAlphaComponent(0.5)
        
        cellLabel.text = HippoStrings.selectString.trimWhiteSpacesAndNewLine() + " " + HippoConfig.shared.strings.displayNameForCustomers.trimWhiteSpacesAndNewLine()
        
        
        if manager?.selectedTeam?.tagId == -100 {
            cellLabel.text = HippoStrings.allAgentsString + " " + HippoConfig.shared.strings.displayNameForCustomers + " " + HippoConfig.shared.strings.selectedString
        }
    }
    func setUpForShowAgents() {
        
        let totalSelectedCount = manager?.getSelectedAgentCount() ?? 0
        let isEnabled = totalSelectedCount > 0
        
        cellImageView.tintColor = isEnabled ? UIColor.black : UIColor.lightGray
        cellLabel.textColor = isEnabled ? UIColor.black : UIColor.lightGray
        bottomLineView.backgroundColor = isEnabled ? UIColor.lightGray : UIColor.lightGray.withAlphaComponent(0.5)
        
        
        let countString = "(\(totalSelectedCount) selected)"
        cellLabel.text = HippoConfig.shared.strings.showString.trimWhiteSpacesAndNewLine() + " " + HippoConfig.shared.strings.displayNameForCustomers.trimWhiteSpacesAndNewLine() + countString
        
    }
}
