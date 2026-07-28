//
//  DropDownTableViewCell.swift
//  HippoAgent
//
//  Created by Neha Vaish on 21/04/23.
//  Copyright © 2023 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class DropDownTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {

    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var issuesDropDownTf: CustomUITextField!
    @IBOutlet var pickerView: UIPickerView! = UIPickerView()

    var callBack: ((String)->())?
    var arrayOfItms = [String?]()

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
        issuesDropDownTf.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        issuesDropDownTf.tintColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - UIPicker Funcs

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return arrayOfItms.count > 0 ? 1 : 0
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfItms.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfItms[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        issuesDropDownTf.text = arrayOfItms[row]
        callBack?(issuesDropDownTf.text ?? "")
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerView.isHidden = false
        return true
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
