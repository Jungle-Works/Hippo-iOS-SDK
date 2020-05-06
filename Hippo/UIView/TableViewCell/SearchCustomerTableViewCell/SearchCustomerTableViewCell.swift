//
//  SearchCustomerTableViewCell.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 13/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class SearchCustomerTableViewCell: CoreTabelViewCell {

  //  @IBOutlet weak var profilePicture: So_UIImageView!
    @IBOutlet weak var customerName: So_CustomLabel!
    @IBOutlet weak var customerPhone: So_CustomLabel!
    @IBOutlet weak var customerEmail: So_CustomLabel!
    @IBOutlet weak var addChatButton: So_CustomButton!
    @IBOutlet weak var bottomLineView: So_UIView!
    
    weak var delegate: FilterDelegate?
    private var selectedCustomerData: SearchCustomerData?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureSearchDataCell(resetProperties: Bool, searchedCustomerData: SearchCustomerData, section: Int, newChatEnabled: Bool) -> SearchCustomerTableViewCell {
        
        if resetProperties {
            resetPropertiesOfSearchedDataCell()
        }
        
        self.customerName.text = searchedCustomerData.full_name
        self.customerEmail.text = searchedCustomerData.email
        self.customerPhone.text = searchedCustomerData.phone_number
        self.selectedCustomerData = searchedCustomerData
        self.addChatButton.isHidden = !newChatEnabled
        
        return self
    }
    
    // MARK: Reset properties
    func resetPropertiesOfSearchedDataCell() {
        selectionStyle = .none
//        backgroundColor = .white
        customerName.text = ""
        customerEmail.text = ""
        addChatButton.isHidden = true
        
        addChatButton.backgroundColor = HippoTheme.defaultTheme().themeColor
        addChatButton.setTitleColor(HippoTheme.defaultTheme().headerTextColor, for: .normal)
//        profilePicture.image = nil
        
    }
    
    @IBAction func addNewChatAction(_ sender: UIButton) {
        guard let selectedCustomerData = selectedCustomerData else {
            return
        }
        delegate?.newChatClicked(selectedPersonData: selectedCustomerData)
    }
    
}
