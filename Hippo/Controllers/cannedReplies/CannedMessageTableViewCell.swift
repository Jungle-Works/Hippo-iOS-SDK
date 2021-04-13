//
//  CannedMessageTableViewCell.swift
//  HippoDemo
//
//  Created by sreshta bhagat on 05/04/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class CannedMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var titleLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLine: UIView!
    @IBOutlet weak var descriptionLabel: So_CustomLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension CannedMessageTableViewCell {
    func resetPropertiesOfCannedMessage() {
        clipsToBounds = true
        setTheme()
//        backgroundColor = .clear
//        accessoryType = .disclosureIndicator
        //horizontalLine.isHidden = true
    }

    func configureCannedMessageCell(resetProperties: Bool, cannedObject: CannedReply) -> CannedMessageTableViewCell {
        if resetProperties == true {
            resetPropertiesOfCannedMessage()
        }
        
        titleLabel.text = cannedObject.title ?? ""
        if let desc =  cannedObject.message {
        descriptionLabel.text = desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
         descriptionLabel.text = ""
        }
        return self
    }
    
    func setTheme() {
        let theme = HippoTheme.theme
        titleLabel.textColor = theme.label.primary
        descriptionLabel.textColor = theme.label.secondary
        
        horizontalLine.backgroundColor = theme.sepratorColor
    }
}

