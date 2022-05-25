//
//  RecentSearchedCustomerTableViewCell.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 14/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol RecentSearchedProtocol: class {
    func cancelTapped()
}

class RecentSearchedCustomerTableViewCell: UITableViewCell {

    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    
    weak var delegate: RecentSearchedProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        if #available(iOS 13.0, *) {
            imgClose.image = imgClose.image?.withRenderingMode(.alwaysTemplate)
            imgClose.tintColor = .white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellData(resetProperties: Bool, data: SearchCustomerData) {
        if resetProperties {
            self.resetPropertiesOfRecentSearch()
        }
        var text = data.email ?? ""
        
        if text.isEmpty {
            text = data.full_name ?? ""
        }
        if text.isEmpty {
            text = data.phone_number ?? "Visitor"
        }
        self.emailLabel.text = text
    }
    
    
    // MARK: Reset properties
    func resetPropertiesOfRecentSearch() {
        selectionStyle = .none
        backgroundColor = .white
        emailLabel.text = ""
        emailContainer.backgroundColor = .themeColor
        emailContainer.layer.cornerRadius = emailContainer.frame.height / 2
        
    }
    
    // cancel pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.cancelTapped()
        //ConversationManager.sharedInstance.selectedCustomerObject = nil
    }
}
