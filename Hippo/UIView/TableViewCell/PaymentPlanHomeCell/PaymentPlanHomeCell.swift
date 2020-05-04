//
//  PaymentPlanHomeCell.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class PaymentPlanHomeCell: UITableViewCell {

    @IBOutlet weak var keyUpdatedAtLabel: UILabel!
    @IBOutlet weak var keyPlanOwnerLabel: UILabel!
    @IBOutlet weak var keyPlanNameLabel: UILabel!
    @IBOutlet weak var keyPlanIdLabel: UILabel!
    
    @IBOutlet weak var updatedAtStackView: UIStackView!
    @IBOutlet weak var planOwnerStackView: UIStackView!
    @IBOutlet weak var forwardImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var planeOwnerLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planIdLabel: UILabel!
    
    var plan: PaymentPlan?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setTheme() {
//        let theme = HippoTheme.theme
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView.layer.cornerRadius = 5
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        forwardImageView.tintColor = HippoConfig.shared.theme.titleTextColor//UIColor.themeColor
        forwardImageView.image = HippoConfig.shared.theme.forwardIcon
        
        let font = UIFont.systemFont(ofSize: 15)//UIFont.regularProximaNova(withSize: 15)
        
        planIdLabel.font = font
        planNameLabel.font = font
        planeOwnerLabel.font = font
        updatedAtLabel.font = font
        
//        planIdLabel.textColor = theme.label.primary
//        planNameLabel.textColor = theme.label.primary
//        planeOwnerLabel.textColor = theme.label.primary
//        updatedAtLabel.textColor = theme.label.primary
//
//        keyPlanIdLabel.textColor = theme.label.secondary
//        keyPlanNameLabel.textColor = theme.label.secondary
//        keyPlanOwnerLabel.textColor = theme.label.secondary
//        keyUpdatedAtLabel.textColor = theme.label.secondary
//
//        
//        bgView.backgroundColor = theme.systemBackgroundColor.tertiary
    }
}

extension PaymentPlanHomeCell {
    func set(plan: PaymentPlan) {
        self.plan = plan
        
        planIdLabel.text = "\(plan.planId)"
        planNameLabel.text = plan.planName
        
        if let ownerName = plan.displayOwner {
            planeOwnerLabel.text = ownerName
            planOwnerStackView.isHidden = false
        } else {
            planOwnerStackView.isHidden = true
        }
        
        if let date = plan.updatedAt?.toString(with: .broadcastDate) {
            updatedAtStackView.isHidden = false
            updatedAtLabel.text = date
        } else {
            updatedAtStackView.isHidden = true
        }

    }
}
