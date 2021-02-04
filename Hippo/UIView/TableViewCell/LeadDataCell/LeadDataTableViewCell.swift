//
//  LeadDataTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 24/04/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol LeadDataCellDelegate: class {
    func didTapSend(withReply reply: String, cell: LeadDataTableViewCell)
    func enableError(isEnabled: Bool, cell: LeadDataTableViewCell, text: String?)
    func textfieldShouldBeginEditing(textfield: UITextField)
    func textfieldShouldEndEditing(textfield: UITextField)
}

class LeadDataTableViewCell: UITableViewCell {
    static let rowHeight: CGFloat = 90.0
    fileprivate enum TextfieldType: String {
        case string = "string"
        case phone = "phone"
        case email = "email"
        case name = "name"
    }
    
    fileprivate var dataType: String = ""
    
    weak var delegate: LeadDataCellDelegate?
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueContainer: UIView!
    @IBOutlet var labelNoOfQuestions: UILabel!
    @IBOutlet var labelValidationError: UILabel! {
        didSet {
            labelValidationError.textColor = UIColor.red
        }
    }
    @IBOutlet var constraintValidationTop: NSLayoutConstraint!
    @IBOutlet var constraintValidationBottom: NSLayoutConstraint!
    @IBOutlet var constraintViewTop: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellView()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard self.dataType == "phone" else {
            return super.canPerformAction(action, withSender: sender)
        }
        return false
    }

    @IBAction func didTapSend(_ sender: UIButton) {
        guard let text = self.valueTextfield.text else {
            self.delegate?.enableError(isEnabled: true, cell: self, text: HippoStrings.requiredField)
            return
        }
        guard text != "" else {
            self.delegate?.enableError(isEnabled: true, cell: self, text: HippoStrings.requiredField)
            return
        }
        guard self.isValidData(dataType: self.dataType, data: text) else {
            // Show error
            return
        }
        self.delegate?.enableError(isEnabled: false, cell: self, text: nil)
        self.delegate?.didTapSend(withReply: text, cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(data: FormData) {
        titleLabel.text = data.title
        valueTextfield.text = data.value
        valueTextfield.placeholder = data.value
        DispatchQueue.main.async {
            if data.isCompleted {
                let image = UIImage(named: "tick_green", in: FuguFlowManager.bundle, compatibleWith: nil)
                self.buttonSend.setImage(image, for: .normal)
                self.buttonSend.isUserInteractionEnabled = false
                self.valueTextfield.isUserInteractionEnabled = false
                self.buttonSend.backgroundColor = UIColor.clear
            } else {
                let image = UIImage(named: "next_dark_icon", in: FuguFlowManager.bundle, compatibleWith: nil)
                self.buttonSend.setImage(image!.withRenderingMode(.alwaysTemplate), for: .normal)
                self.buttonSend.tintColor = UIColor.white
                self.buttonSend.isUserInteractionEnabled = true
                self.valueTextfield.isUserInteractionEnabled = true
                self.buttonSend.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.5882352941, blue: 1, alpha: 1)
            }
        }
        if data.isErrorEnabled {
            labelValidationError.isHidden = false
        } else {
            labelValidationError.isHidden = true
        }
        setTextFieldType(data: data)
        self.dataType = data.dataType
    }
    
    func setTextFieldType(data: FormData) {
        let type = TextfieldType(rawValue: data.dataType.lowercased()) ?? .string
        switch type {
        case .string:
            self.valueTextfield.keyboardType = .default
        case .name:
            self.valueTextfield.keyboardType = .default
        case .phone:
            self.valueTextfield.keyboardType = .phonePad
        case .email:
            self.valueTextfield.keyboardType = .emailAddress
        }
    }
    
    func isValidData(dataType: String, data: String) -> Bool {
        guard let type = TextfieldType(rawValue: dataType) else {
            return true
        }
        switch type {
        case .string:
            return true
        case .phone:
            return true
        case .name:
            return true
        case .email:
            if let error = isValidEmail(string: data) {
                self.delegate?.enableError(isEnabled: true, cell: self, text: error)
                return false
            } else {
                return true
            }
        }
    }
    
    func setupCellView() {
        //valueContainer.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        //valueContainer.layer.borderWidth = 1
        valueContainer.layer.masksToBounds = true
        valueContainer.backgroundColor = UIColor.white
        valueContainer.layer.cornerRadius = 10
        self.valueTextfield.delegate = self
        backgroundColor = UIColor.clear
    }

    
    func isValidEmail(string: String) -> String? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: string) {
            return HippoStrings.enterValidEmail
        } else {
            return nil
        }
    }
    
}

extension LeadDataTableViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        HippoKeyboardManager.shared.enable = true
        self.delegate?.textfieldShouldBeginEditing(textfield: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        HippoKeyboardManager.shared.enable = false
        self.delegate?.textfieldShouldEndEditing(textfield: textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let type = TextfieldType(rawValue: dataType)  ?? .string
        switch type {
        case .phone:
            let allowedCharacters = CharacterSet(charactersIn: "0123456789+")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        default:
            return true
        }
    }
}
