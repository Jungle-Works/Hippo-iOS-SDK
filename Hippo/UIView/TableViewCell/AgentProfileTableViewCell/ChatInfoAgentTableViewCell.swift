//
//  ChatInfoAgentTableViewCell.swift
//  Fugu
//
//  Created by clickpass on 10/11/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class ChatInfoAgentTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var agentProfileImage: UIImageView!
    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var namePlaceHolderImage: UIImageView!
    @IBOutlet weak var assignedToTextLabel: UILabel!
    @IBOutlet weak var downArrowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetData()
        setFonts()
    }
    
    func setUpData(agentId: Int, agentName: String) -> ChatInfoAgentTableViewCell {
        agentNameLabel.text = agentName.isEmpty ? HippoStrings.unassigned : agentName
        //containerView.layer.borderColor = UIColor.paleGrey.cgColor
        containerView.layer.borderColor = UIColor.clear.cgColor
        return self
    }
    
    func resetData() {
        selectionStyle = .none
        agentProfileImage.image = UIImage()
        agentNameLabel.text = ""
        assignedToTextLabel.text = HippoStrings.assignedTo
    }
    
    func setFonts(){
        agentNameLabel.font = UIFont.regular(ofSize: 18.0)
        assignedToTextLabel.font = UIFont.regular(ofSize: 15.0)
    }

}
