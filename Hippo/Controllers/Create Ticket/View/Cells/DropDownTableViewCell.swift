//
//  DropDownTableViewCell.swift
//  HippoAgent
//
//  Created by Neha Vaish on 21/04/23.
//  Copyright © 2023 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class DropDownTableViewCell: UITableViewCell, UITextFieldDelegate  {

    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var issuesDropDownTf: CustomUITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!

    var callBack: ((String)->())?
    var arrayOfItms = [String?]()
    var openPicker: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldLabel.styleAsFieldLabel()
        issuesDropDownTf.layer.cornerRadius = 8
        issuesDropDownTf.layer.borderWidth = 1
        issuesDropDownTf.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        issuesDropDownTf.setLeftPaddingPoints(12)
        issuesDropDownTf.setRightPaddingPoints(12)
        issuesDropDownTf.tintColor = .darkGray
        issuesDropDownTf.backgroundColor = .clear
        issuesDropDownTf.delegate = self
        issuesDropDownTf.inputView = UIView()
        issuesDropDownTf.tintColor = UIColor.clear
        setError(nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        let hasError = !(message ?? "").isEmpty
        errorLabel.isHidden = !hasError
        errorLabelHeightConstraint.constant = hasError ? 16 : 0
        issuesDropDownTf.layer.borderColor = (hasError ? UIColor.systemRed : UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1)).cgColor
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        openPicker?()
        return false
    }
}

class CustomUITextField: UITextField {
   override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
   }
}
