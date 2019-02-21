//
//  BroadCastTextViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol BroadCastTextViewCellDelegate: class {
    func textViewTextChanged(newText: String)
}

class BroadCastTextViewCell: UITableViewCell {
    
    //MARK: Constants
    let errorText = "*Message is required"

    //MARK: Outlets
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var cellTextView: UITextView!
    
    weak var delegate: BroadCastTextViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setInitalView()
        cellTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInitalView() {
        selectionStyle = .none
        
        textViewContainer.layer.cornerRadius = 3
        textViewContainer.layer.borderWidth = 1
        textViewContainer.layer.borderColor = UIColor.lightGray.cgColor
        
        setErrorLabelView(isHidden: true)
    }
    
    func setErrorLabelView(isHidden: Bool) {
        let newHiddenValue = cellTextView.text.isEmpty ? isHidden : true
        errorLabel.textColor = UIColor.red
        errorLabelHeightConstraint.constant = newHiddenValue ? 0 : 20
        errorLabel.text = newHiddenValue ? "" : errorText
        errorLabel.isHidden = newHiddenValue
    }
}

extension BroadCastTextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let countForNewString = textView.text.count
        if countForNewString > 0 {
            setErrorLabelView(isHidden: false)
        }
      delegate?.textViewTextChanged(newText: textView.text)
    }
}
