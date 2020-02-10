//
//  PaymentSecureView.swift
//  HippoChat
//
//  Created by Vishal on 04/12/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class PaymentSecureView: UITableViewCell {

    @IBOutlet weak var iageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var bgViewTraillingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingViewgbgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewBottomCosntraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelContainerTaillingConstraint: NSLayoutConstraint!
    
    
    var card: PaymentSecurely?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func setTheme() {
        selectionStyle = .none
        cellLabel.text = ""
        
        cellLabel.numberOfLines = 0
        backgroundColor = .clear
        self.contentView.backgroundColor = .clear
//        cellLabel.textAlignment = .center
        
       //cellLabel.textColor = .black//
        
        bgView.backgroundColor = .clear
        labelContainerView.backgroundColor = .clear
    }
}

extension PaymentSecureView {
    func set(card: PaymentSecurely) {
        self.card = card
        cellLabel.attributedText = card.attributedText
        cellLabel.textColor = .black
        cellImage.image = card.image
        cellImage.tintColor = card.imageTintColor
        setConstraint()
    }
    
    internal func setConstraint() {
        guard let card = self.card else {
            return
        }
        bgViewTopConstraint.constant = card.bgViewLayout.top
        bgViewBottomCosntraint.constant = card.bgViewLayout.bottom
        bgViewTraillingConstraint.constant = card.bgViewLayout.trailing
        leadingViewgbgViewLeadingConstraint.constant = card.bgViewLayout.leading
        
        labelContainerTopConstraint.constant = card.labelContainerLayout.top
        labelContainerBottomConstraint.constant = card.labelContainerLayout.bottom
        labelContainerTaillingConstraint.constant = card.labelContainerLayout.trailing
        labelContainerLeadingConstraint.constant = card.labelContainerLayout.leading
        
        iageWidthConstraint.constant = card.imageWidth
        
        self.layoutIfNeeded()
    }
}
