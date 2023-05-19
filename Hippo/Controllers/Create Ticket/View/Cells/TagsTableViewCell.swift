//
//  TagsTableViewCell.swift
//  Hippo
//
//  Created by Neha Vaish on 05/05/23.
//

import UIKit

class TagsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var tagsTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagsTextField.placeholder = "Add Tags"
        tagsTextField.layer.cornerRadius = 6
        tagsTextField.layer.borderWidth = 1
        tagsTextField.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        tagsTextField.setRightPaddingPoints(20)
        tagsTextField.tintColor = .darkGray
        tagsTextField.backgroundColor = .white
        doneBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        doneBtn.isHidden = true
    }
    @IBAction func editingDidBegin(_ sender: UITextField) {
        doneBtn.isHidden = false
    }
}
