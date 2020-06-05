//
//  ContactNumberTableCell.swift
//  Hippo
//
//  Created by Vishal on 15/02/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class ContactNumberTableCell: UITableViewCell {

    
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var sepratorLineView: UIView!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonLineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var form: FormData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideErrorMessage()
        cellTextField.delegate = self
        countryCodeTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func hideErrorMessage() {
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    func showErrorMessage(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        errorLabel.textColor = UIColor.red
    }
    
    func setupCellFor(form: FormData) {
        self.form = form
        
        countryCodeTextField.text = form.countryCode
        cellTextField.text = form.value
        cellTextField.placeholder = form.placeHolder
        titleLabel.text = form.title
        cellTextField.keyboardType = .numberPad
        countryCodeTextField.keyboardType = .phonePad
        
        titleLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        titleLabel.font = UIFont.regular(ofSize: 14)
        
        setErrorMessageIfNeed()
    }
    
    func setErrorMessageIfNeed() {
        guard let form = self.form else {
            return
        }
        if form.errorMessage.isEmpty {
            hideErrorMessage()
        } else {
            showErrorMessage(message: form.errorMessage)
        }
    }
}

extension ContactNumberTableCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let countForNewString = updatedString?.count ?? 0
        
        guard countForNewString < 100 else {
            return false
        }
        switch textField {
        case countryCodeTextField:
            form?.countryCode = updatedString ?? form?.countryCode ?? ""
        case cellTextField:
            form?.value = updatedString ?? form?.value ?? ""
        default:
            break
        }
        
//        form?.validate()
        hideErrorMessage()
//        setErrorMessageIfNeed()
//        delegate?.textFieldTextChanged(newText: updatedString ?? "")
        return true
    }
}
