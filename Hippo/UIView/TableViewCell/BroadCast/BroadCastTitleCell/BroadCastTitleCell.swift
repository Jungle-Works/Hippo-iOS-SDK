//
//  BroadCastTitleCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class BroadCastTitleCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setInitalStrings()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInitalStrings() {
        headingLabel.text = HippoConfig.shared.strings.broadCastTitle + " " + HippoConfig.shared.strings.displayNameForCustomers + "."
        headingLabel.font =  HippoConfig.shared.theme.broadcastTitleFont
        headingLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        
        descLabel.text = HippoConfig.shared.strings.broadCastTitleInfo
        descLabel.font = HippoConfig.shared.theme.broadcastTitleInfoFont
        descLabel.textColor = HippoConfig.shared.theme.broadcastTitleInfoColor
    }
    func setupCellFor(form: FormData) {
        descLabel.text = form.desc
        headingLabel.text = form.title
    }
}
