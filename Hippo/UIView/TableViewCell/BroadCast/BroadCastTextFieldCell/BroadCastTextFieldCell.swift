//
//  BroadCastTextFieldCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

@objc protocol BroadCastTextFieldCellDelegate {
    @objc func textFieldTextChanged(newText: String)
    @objc optional func pickerSelected(currency: PaymentCurrency)
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
    @IBOutlet weak var label_TextCount : UILabel!
    
    
    weak var delegate: BroadCastTextFieldCellDelegate?
    var form: FormData?
    var pickerView: UIPickerView?
    var currency: [PaymentCurrency] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cellTextField.delegate = self        
        setErrorLabelView(isHidden: true)
//        selectionStyle = .none
//        cellTextField.delegate = self
//        backgroundColor = .clear
//        setErrorLabelView(isHidden: true)
//        let theme = HippoTheme.theme
//        cellTextField.textColor = theme.label.primary
//        cellTextField.backgroundColor = theme.systemBackgroundColor.primary
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setErrorLabelView(isHidden: Bool, message: String? = nil) {
        
//        let newHiddenValue = isHidden //cellTextField.text!.isEmpty ? isHidden : true
//        let displayError = message == nil ? errorText : message!
//        errorLabel.textColor = UIColor.red
////        errorLabelHeightConstraint.constant = newHiddenValue ? 18 : 18
//        errorLabel.text = newHiddenValue ? "" : displayError
//        errorLabel.isHidden = newHiddenValue
//
//        titleLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
//        titleLabel.font = UIFont.regular(ofSize: 14)
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
    
    func setupCell(form: PaymentField) {
        self.form = form
        cellTextField.text = form.value
        
        titleLabel.text = form.title
        cellTextField.placeholder = form.placeHolder
        
        cellTextField.borderStyle = .roundedRect
        
        bottomLineView.isHidden = true
        
        switch form.validationType {
        case .currency:
            currency = PaymentCurrency.getAllCurrency()
            setPickerView()
        default:
            label_TextCount.text = "\(cellTextField.text?.count ?? 0)" + "/60"
            cellTextField.inputView = nil
        }
        
        cellTextField.keyboardType = form.validationType.keyBoardType
        
        setErrorMessageIfNeed()
    }
    func setPickerView() {
        pickerView = UIPickerView()
        pickerView?.delegate = self
        pickerView?.dataSource = self
        
        
        pickerView?.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: HippoStrings.Done, style: UIBarButtonItem.Style.plain, target: self, action: #selector(prickerDoneButtonClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        cellTextField.inputView = pickerView
        cellTextField.inputAccessoryView = toolBar
    }
    
    
    @objc func prickerDoneButtonClicked() {
        cellTextField.resignFirstResponder()
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
        
        guard countForNewString <= 60 else {
            return false
        }
        form?.value = updatedString ?? form?.value ?? ""
        //form?.validate()
        //setErrorMessageIfNeed()
        
        delegate?.textFieldTextChanged(newText: updatedString ?? "")
        return true
    }

    @IBAction func textFieldChange(_ textField : UITextField){
        label_TextCount.text = "\(cellTextField.text?.count ?? 0)" + "/60"
    }
}

extension BroadCastTextFieldCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = currency[row]
        form?.value = value.displayName
        cellTextField.text = form?.value
        delegate?.pickerSelected?(currency: value)
    }
}

extension BroadCastTextFieldCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currency.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = currency[row]
        
        return value.displayName
    }
    
    
}
