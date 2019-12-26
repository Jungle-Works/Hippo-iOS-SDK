//
//  PromotionTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/24/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class PromotionTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var promotionTitle: UILabel!
    @IBOutlet weak var promotionImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpUI()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI()
    {
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = HippoConfig.shared.theme.multiselectUnselectedButtonColor
    }
    
    func set(data: PromotionCellDataModel)
    {
        self.promotionTitle.text = "This is a new tittle"
        self.descriptionLabel.text = "This is description of promotion in a new format"        
        self.layoutIfNeeded()
        
        
    }
    
}
