//
//  CustomerTagsTableViewCell.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 16/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class CustomerTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var tagBgView: So_UIView!
    @IBOutlet weak var tagLabel: So_CustomLabel!
    @IBOutlet weak var tagSelectedImage: So_UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCustomerCell(resetProperties: Bool, tagsDetail: TagDetail) -> CustomerTagsTableViewCell {
        
        if resetProperties {
            self.resetPropertiesOfCustomerTagsTableViewCell()
            
        }
        tagBgView.backgroundColor = UIColor.hexStringToUIColor(hex: tagsDetail.colorCode ?? "").withAlphaComponent(1.0)
        tagLabel.text = tagsDetail.tagName
        tagLabel.textColor = .white
        if tagsDetail.isSelected == true {
            self.tagSelectedImage.isHidden = false
        } else {
            self.tagSelectedImage.isHidden = true
        }
        return self
    }
    
    func resetPropertiesOfCustomerTagsTableViewCell() {
        selectionStyle = .none
        backgroundColor = .white
        tagBgView.backgroundColor = .white
        tagLabel.text = ""
    }
}
