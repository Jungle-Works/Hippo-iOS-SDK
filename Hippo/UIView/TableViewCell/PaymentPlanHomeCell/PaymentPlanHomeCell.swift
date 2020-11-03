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
    @IBOutlet weak var button_DeletePlan : UIButton!
    @IBOutlet weak var button_EditPlan : UIButton!
    
    var deletePlanClicked : (()->())?
    var editPlanClicked : (()->())?
    var sendPlanClicked : (()->())?
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
        
        //forwardImageView.tintColor = HippoConfig.shared.theme.titleTextColor//UIColor.themeColor
       // forwardImageView.image = HippoConfig.shared.theme.forwardIcon
        
        let font = UIFont.regular(ofSize: 15)//UIFont.regularProximaNova(withSize: 15)
        
        planIdLabel.font = font
        planNameLabel.font = font
        planeOwnerLabel.font = font
        updatedAtLabel.font = font
    }
    
    @IBAction func action_DeletePlan(){
        self.deletePlanClicked?()
    }
    
    @IBAction func action_EditPlan(){
        self.editPlanClicked?()
    }
    
    @IBAction func action_SendPlan(){
        self.sendPlanClicked?()
    }
    
}

extension PaymentPlanHomeCell {
    func set(plan: PaymentPlan) {
        self.plan = plan
        
        keyPlanIdLabel.text = HippoStrings.planId
        keyPlanNameLabel.text = HippoStrings.planNameTitle
        keyPlanOwnerLabel.text = HippoStrings.planOwner
        keyUpdatedAtLabel.text = HippoStrings.updatedAt
        
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
        button_DeletePlan.layer.borderColor = UIColor.clear.cgColor
        button_DeletePlan.layer.borderWidth = 1
        button_DeletePlan.imageView?.tintColor = .darkGray
        button_DeletePlan.setImage(HippoConfig.shared.theme.deleteIcon, for: .normal)
        button_DeletePlan.isHidden = plan.type == .agentPlan ? false : true
        button_DeletePlan.isEnabled = plan.type == .agentPlan ? true : false
        
        button_EditPlan.layer.borderColor =  UIColor.clear.cgColor
        button_EditPlan.layer.borderWidth = 1
        button_EditPlan.imageView?.tintColor = .darkGray
        button_EditPlan.setImage(plan.type == .agentPlan ? HippoConfig.shared.theme.editIcon : HippoConfig.shared.theme.eyeIcon, for: .normal)
        
    }
}
