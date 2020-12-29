//
//  SearchAgentTableViewCell.swift
//  Hippo
//
//  Created by Arohi Sharma on 14/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SearchAgentTableViewCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var textField_SearchAgent : UITextField!

    var textFieldClicked : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField_SearchAgent.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
extension SearchAgentTableViewCell : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldClicked?()
        return false
    }
    
}
