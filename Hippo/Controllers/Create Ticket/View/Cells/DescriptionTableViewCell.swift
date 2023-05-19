//
//  DescriptionTableViewCell.swift
//  Hippo
//
//  Created by Neha Vaish on 26/04/23.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: GrowingTextView!
    
    var callBack : ((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13.0, *) {
            textView.placeholderColor = UIColor.placeholderText
        } else {
            // Fallback on earlier versions
        }
        textView.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        textView.tintColor = .black
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        callBack?(textView.text ?? "")
    }
    
}
