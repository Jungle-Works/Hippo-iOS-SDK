//
//  PrescipionTextFieldCell.swift
//  Hippo
//
//  Created by Arohi Sharma on 04/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

class PrescipionTextFieldCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {
    
    //MARK:- IBOutlets
    
    @IBOutlet var label_Name : UILabel!
    @IBOutlet var textField : UITextField!{
        didSet{
            textField.delegate = self
        }
    }
    @IBOutlet var textView : UITextView!{
        didSet{
            textView.delegate = self
        }
    }
    @IBOutlet var label_Placeholder : UILabel!
    
    //MARK:- Variables
    
    var bodyKeys : BodyKeys?
    var valueChanged : (()->())?
    var textViewEdited : (()->())?
    let datePickerView:UIDatePicker = UIDatePicker()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label_Name.font = UIFont.regular(ofSize: 12.0)
        textField.font = UIFont.bold(ofSize: 16.0)
        textView.font = UIFont.bold(ofSize: 16.0)
        label_Placeholder.font = UIFont.bold(ofSize: 16.0)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(){
        //Set keyboard type
        textField.keyboardType = PresciptionValidationType(rawValue: (bodyKeys?.type ?? "")?.lowercased() ?? "")?.keyBoardType ?? .default
        
        //Set heading
        label_Name.text = bodyKeys?.key?.replacingOccurrences(of: "_", with: " ").uppercased()
        updateAttributedStringWithCharacter(title: label_Name.text ?? "", uilabel: label_Name)
        
        //Set default value
        textField.text = bodyKeys?.value
        textView.text = bodyKeys?.value
        
        //set placeholder
        label_Placeholder.text = (bodyKeys?.placeholder ?? "")
        label_Placeholder.textColor = HippoConfig.shared.theme.applePlaceHolderColor
        textField.placeholder = (bodyKeys?.placeholder ?? "")
        //
        selectionStyle = .none
        
        
        switch bodyKeys?.type{
        case PresciptionValidationType.textArea.rawValue:
            textView.isHidden = false
            textField.isHidden = true
            label_Placeholder.isHidden = !(textView.text.isEmpty)
            self.textField.inputView = nil
        case PresciptionValidationType.date.rawValue:
            textView.isHidden = true
            textField.isHidden = false
            label_Placeholder.isHidden = true
            self.setUpDatePicker(value: textField.text)
        case PresciptionValidationType.date.rawValue:
            textView.isHidden = true
            textField.isHidden = false
            label_Placeholder.isHidden = true
            self.textField.inputView = nil
        default:
            textView.isHidden = true
            textField.isHidden = false
            label_Placeholder.isHidden = true
            self.textField.inputView = nil
        }
    }
    
    func updateAttributedStringWithCharacter(title : String, uilabel: UILabel) {
        let text = title + "*"
        let range = (text as NSString).range(of: "*")
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
        uilabel.attributedText = attributedString }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bodyKeys?.value = textField.text ?? ""
        valueChanged?()
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            bodyKeys?.value = textView.text ?? ""
            valueChanged?()
            label_Placeholder.isHidden = !textView.text.isEmpty
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        label_Placeholder.isHidden = true
        HippoKeyboardManager.shared.enable = true
        return true
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        HippoKeyboardManager.shared.enable = true
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        bodyKeys?.value = textView.text ?? ""
        valueChanged?()
        textViewEdited?()
        label_Placeholder.isHidden = !textView.text.isEmpty
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? textField.text ?? ""
        bodyKeys?.value = updatedString
        valueChanged?()
        return true
    }
    
    
    private func setUpDatePicker(value : String?) {
        guard let dateRecieved = value else{
            return
        }
        self.datePickerView.datePickerMode = .date
        self.datePickerView.locale = .current
        self.datePickerView.minimumDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let val = dateFormatter.date(from: dateRecieved) {
            self.datePickerView.setDate(val, animated: true)
        }
        self.textField.inputView = self.datePickerView
        self.datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        textField.text = dateFormatter.string(from: sender.date)
        bodyKeys?.value = textField.text
        self.valueChanged?()
    }
}
