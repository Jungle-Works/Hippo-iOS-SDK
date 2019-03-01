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
}

class PaymentItemDescriptionCell: UITableViewCell {

    @IBOutlet weak var textViewBottomLineView: UIView!
    @IBOutlet weak var cancelIcon: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textviewHeightConstraint: NSLayoutConstraint!
    
    //MARK:
    let min_height_textview: CGFloat = 50
    let max_height_textview: CGFloat = 120
    weak var delegate: PaymentItemDescriptionCellDelegate?
    var item: PaymentItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceTextField.delegate = self
        descriptionTextView.delegate = self
        setUI()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        delegate?.cancelButtonClicked(item: item)
    }
    
    func setUI() {
        priceLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        
        descriptionLabel.textColor = HippoConfig.shared.theme.broadcastTitleColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 5
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        bgView.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        
        cancelIcon.backgroundColor = UIColor.themeColor
        cancelIcon.tintColor = UIColor.white
        cancelIcon.layer.cornerRadius = cancelIcon.bounds.height / 2
         cancelIcon.layer.masksToBounds = true
        cancelIcon.setImage(HippoConfig.shared.theme.cancelIcon, for: .normal)
        
        textViewBottomLineView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setupCellFor(item: PaymentItem) {
        
        self.item = item
        
        priceTextField.keyboardType = item.priceField.validationType.keyBoardType
        priceTextField.text = item.priceField.value
        priceTextField.placeholder = item.priceField.placeHolder
        priceLabel.text = item.priceField.title
        
        descriptionTextView.keyboardType = item.descriptionField.validationType.keyBoardType
        descriptionTextView.text = item.descriptionField.value
        descriptionLabel.text = item.descriptionField.title
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
        self.delegate?.updateHeightFor(self)
        self.layoutIfNeeded()
    }
    
}


extension PaymentItemDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        item.descriptionField.value = textView.text
        updateHeightOf(textView: textView)
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
        
        let maxCount = 10
        
        guard countForNewString <= maxCount else {
            return false
        }
        item.priceField.value = updatedString ?? ""
        return true
    }
}
