//
//  AssignedAgentTableViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 21/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit


class AssignedAgentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        resetPropertiesAssignedAgentCell()
    }
    
    internal func resetPropertiesAssignedAgentCell() {
        backgroundColor = .clear
        clipsToBounds = true
        selectionStyle = .none
        messageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
    }
    
    func setupCell(reset: Bool = true, message: HippoMessage) {
        if reset {
            resetPropertiesAssignedAgentCell()
        }
        
        messageLabel.text = message.message
    }
}
