//
//  DescriptionTableViewCell.swift
//  Hippo
//
//  Created by Neha Vaish on 26/04/23.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!

    var callBack : ((String)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            textView.placeholderColor = UIColor.placeholderText
        }
        textView.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        textView.tintColor = .black
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        textView.textContainer.lineFragmentPadding = 0

        fieldLabel.styleAsFieldLabel()
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
        textView.layer.borderColor = (hasError ? UIColor.systemRed : UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1)).cgColor
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        callBack?(textView.text ?? "")
    }

    func textViewDidChange(_ textView: UITextView) {
        callBack?(textView.text ?? "")
        setError(nil)
    }

}
