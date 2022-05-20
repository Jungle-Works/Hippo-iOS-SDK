//
//  NoCustomersFoundTableViewCell.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 14/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class NoCustomersFoundTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noCustomersLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureNoCustomerCell(resetProperties: Bool, textToShow: String) -> NoCustomersFoundTableViewCell {
        
        if resetProperties {
            resetPropertiesOfNoCustomerCell()
        }
        
        self.noCustomersLabel.text = textToShow
        return self
    }
    
    // MARK: Reset properties
    func resetPropertiesOfNoCustomerCell() {
        selectionStyle = .none
        backgroundColor = .white
        noCustomersLabel.text = ""
        
    }
}
