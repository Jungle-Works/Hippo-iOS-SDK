//
//  BroadCastTextFieldCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol BroadCastTextFieldCellDelegate: class {
    func textFieldTextChanged(newText: String)
}

class BroadCastTextFieldCell: UITableViewCell {
    
    //MARK: Constants
    let errorText = "*Broadcast title is required"
    
    //MARK: Outlets
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var cellTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: BroadCastTextFieldCellDelegate?
    var form: FormData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cellTextField.delegate = self
        
        setErrorLabelView(isHidden: true)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setErrorLabelView(isHidden: Bool, message: String? = nil) {
        
        let newHiddenValue = isHidden //cellTextField.text!.isEmpty ? isHidden : true
        let displayError = message == nil ? errorText : message!
        errorLabel.textColor = UIColor.red
//        errorLabelHeightConstraint.constant = newHiddenValue ? 18 : 18
        errorLabel.text = newHiddenValue ? "" : displayError
        errorLabel.isHidden = newHiddenValue
        
        titleLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    
    func setupCellFor(form: FormData) {
        self.form = form
        cellTextField.text = form.value
        titleLabel.text = form.title
        cellTextField.placeholder = form.placeHolder
        cellTextField.keyboardType = form.validationType.keyBoardType
        cellTextField.borderStyle = .roundedRect
        
        bottomLineView.isHidden = true
        
        setErrorMessageIfNeed()
    }
    
    func setErrorMessageIfNeed() {
        guard let form = self.form else {
            return
        }
        if form.errorMessage.isEmpty {
            setErrorLabelView(isHidden: true, message: nil)
        } else {
            setErrorLabelView(isHidden: false, message: form.errorMessage)
        }
    }
}


extension BroadCastTextFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let countForNewString = updatedString?.count ?? 0
        
        guard countForNewString < 100 else {
            return false
        }
        form?.value = updatedString ?? form?.value ?? ""
        form?.validate()
        setErrorMessageIfNeed()
        delegate?.textFieldTextChanged(newText: updatedString ?? "")
        return true
    }
}
