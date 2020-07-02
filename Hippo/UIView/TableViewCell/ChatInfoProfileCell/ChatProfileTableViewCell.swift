//
//  ChatProfileTableViewCell.swift
//  Fugu
//
//  Created by clickpass on 10/10/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
protocol ChatProfileCellDelegate: class {
    func editProfileButtonClicked()
}
class ChatProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var addressTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberTopconstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerViewForStatus: UIView!
    @IBOutlet weak var userLocationTextView: UITextView!
    @IBOutlet weak var userNumberTextView: UITextView!
    @IBOutlet weak var userEmailTextView: UITextView!
    @IBOutlet weak var addressViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lastActiveTimeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChatProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userEmailTextView.textContainer.maximumNumberOfLines = 1
        setFonts()
    }
    
    func setupCell(with data: ChatDetail) {
        userNameLabel.text = data.customerName.isEmpty ? "NA" : data.customerName
        userLocationTextView.text = "NA"
        userEmailTextView.text = data.customerEmail.isEmpty ? "NA" : data.customerEmail
        userNumberTextView.text = data.customerContactNumber.isEmpty ? "NA" : data.customerContactNumber
    }
    
    func setFonts(){
        userLocationTextView.font = UIFont.regular(ofSize: 16.0)
        userNumberTextView.font = UIFont.regular(ofSize: 16.0)
        userEmailTextView.font = UIFont.regular(ofSize: 16.0)
        lastActiveTimeLabel.font = UIFont.regular(ofSize: 15.0)
        userNameLabel.font = UIFont.bold(ofSize: 22.0)
    }
    
}

