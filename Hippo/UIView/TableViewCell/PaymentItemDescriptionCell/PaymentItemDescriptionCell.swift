//
//  PaymentItemDescriptionCell.swift
//  Hippo
//
//  Created by Vishal on 22/02/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PaymentItemDescriptionCellDelegate: class {
     func updateHeightFor(_ cell: PaymentItemDescriptionCell)
     func cancelButtonClicked(item: PaymentItem)
     func itemPriceUpdated()
}

class PaymentItemDescriptionCell: UITableViewCell,UIPickerViewDelegate,UIPickerViewDataSource {
  
    

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textviewPlaceHolderLabel: UILabel!
    @IBOutlet weak var textViewBottomLineView: UIView!
    @IBOutlet weak var cancelIcon: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField_Currency : UITextField!
    
    
    //MARK:
    let min_height_textview: CGFloat = 50
    let max_height_textview: CGFloat = 120
    weak var delegate: PaymentItemDescriptionCellDelegate?
    var item: PaymentItem!
    var pickerView: UIPickerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.delegate = self
        priceTextField.delegate = self
        descriptionTextView.delegate = self
        textField_Currency.delegate = self

        setUI()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        delegate?.cancelButtonClicked(item: item)
    }
    
    func setUI() {
//        let theme = HippoTheme.theme
//
//        self.backgroundColor = .clear
        
        priceLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        priceLabel.font = UIFont.regular(ofSize: 14)
        
        titleLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        titleLabel.font = UIFont.regular(ofSize: 14)
        
        descriptionLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        descriptionLabel.font = UIFont.regular(ofSize: 14)
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 5
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        bgView.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        
        cancelIcon.backgroundColor = HippoConfig.shared.theme.themeTextcolor//UIColor.themeColor
        cancelIcon.tintColor = UIColor.white
        cancelIcon.layer.cornerRadius = cancelIcon.bounds.height / 2
        cancelIcon.layer.masksToBounds = true
        cancelIcon.setImage(HippoConfig.shared.theme.cancelIcon, for: .normal)
        
//        bgView.backgroundColor = theme.systemBackgroundColor.primary
//
//        descriptionTextView.textColor = theme.label.primary
//        titleTextField.textColor = theme.label.primary
//        priceTextField.textColor = theme.label.primary
//
//
//        titleTextField.backgroundColor = theme.systemBackgroundColor.secondary
//        priceTextField.backgroundColor = theme.systemBackgroundColor.secondary
//        descriptionTextView.backgroundColor = theme.systemBackgroundColor.secondary
        
        
        textviewPlaceHolderLabel.text = ""
//        textviewPlaceHolderLabel.textColor = theme.label.secondary
        
        textViewBottomLineView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setupCellFor(item: PaymentItem) {
        setPickerView()
        self.item = item
        
        priceTextField.keyboardType = item.priceField.validationType.keyBoardType
        priceTextField.text = item.priceField.value
        priceTextField.placeholder = item.priceField.placeHolder
        priceLabel.text = item.priceField.title
        textField_Currency.text = item.currency == nil ? BussinessProperty.current.currencyArr?.first?.currencySymbol ?? "" : item.currency?.symbol
        if BussinessProperty.current.currencyArr?.count ?? 0 == 1 && item.currency == nil{
            item.currency = PaymentCurrency(BussinessProperty.current.currencyArr?[0].currencySymbol ?? "", BussinessProperty.current.currencyArr?[0].currency ?? "")
        }
        
        
        titleTextField.keyboardType = item.titleField.validationType.keyBoardType
        titleTextField.text = item.titleField.value
        titleTextField.placeholder = item.titleField.placeHolder
        titleLabel.text = item.titleField.title
        
        
        descriptionTextView.keyboardType = item.descriptionField.validationType.keyBoardType
        descriptionTextView.text = item.descriptionField.value
        descriptionLabel.text = item.descriptionField.title
        
        textviewPlaceHolderLabel.text = item.descriptionField.placeHolder
        textviewPlaceHolderLabel.isHidden = !descriptionTextView.text.isEmpty
        
        //updateHeightOf(textView: self.descriptionTextView)
    }
    
    private func updateHeightOf(textView: UITextView) {
        
        var heightOfTextView = textView.contentSize.height - (textView.frame.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom)
        
        heightOfTextView = textView.contentSize.height + textView.textContainerInset.top + textView.textContainerInset.bottom
        
        
        if heightOfTextView < self.min_height_textview {
            heightOfTextView = self.min_height_textview
        } else if heightOfTextView > self.max_height_textview {
            heightOfTextView = self.max_height_textview
        }
        self.textviewHeightConstraint.constant = heightOfTextView
        //self.delegate?.updateHeightFor(self)
        self.layoutIfNeeded()
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
        
        textField_Currency.inputView = pickerView
        textField_Currency.inputAccessoryView = toolBar
    }
    
    @objc func prickerDoneButtonClicked() {
        if textField_Currency?.text == ""{
            textField_Currency.text = BussinessProperty.current.currencyArr?.first?.currencySymbol ?? ""
        }
        textField_Currency.resignFirstResponder()
    }
    
}
extension PaymentItemDescriptionCell {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BussinessProperty.current.currencyArr?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = BussinessProperty.current.currencyArr?[row]
        return value?.currencySymbol
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField_Currency.text = BussinessProperty.current.currencyArr?[row].currencySymbol
        item.currency = PaymentCurrency(BussinessProperty.current.currencyArr?[row].currencySymbol ?? "", BussinessProperty.current.currencyArr?[row].currency ?? "")
    }
}



extension PaymentItemDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        item.descriptionField.value = textView.text
       // updateHeightOf(textView: textView)
        textviewPlaceHolderLabel.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let updatedString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        let countForNewString = updatedString?.count ?? 0
        
        let maxCount = 250
        
        guard countForNewString <= maxCount else {
            return false
        }
        return true
    }
}

extension PaymentItemDescriptionCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        let countForNewString = updatedString?.count ?? 0
        
        
        
        let maxCount = 6
        
        switch textField {
        case priceTextField:
            guard countForNewString <= maxCount else {
                return false
            }
            item.priceField.value = updatedString ?? ""
            delegate?.itemPriceUpdated()
        case titleTextField:
            item.titleField.value = updatedString ?? ""
        default:
            break
        }
        
        return true
    }
}
