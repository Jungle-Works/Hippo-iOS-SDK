//
//  CustomerPaymentCardCell.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class CustomerPaymentCardCell: UITableViewCell {

    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var innerViewtopConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var selctionImageView: UIImageView!
    @IBOutlet weak var innerCard: UIView!
    @IBOutlet weak var bgView: UIView!{
        didSet{
            addShadow()
        }
    }
    @IBOutlet weak var label_PaidStatus : UILabel!
    
    var isMultiplePaymentCell : Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    internal func setTheme() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        let theme = HippoConfig.shared.theme
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.numberOfLines = 0
        
        descriptionLabel.textColor = theme.descriptionTextColor
        descriptionLabel.font = theme.descriptionFont
        descriptionLabel.numberOfLines = 0
            
        amountLabel.textColor = theme.descriptionTextColor
        amountLabel.font = theme.pricingFont
        amountLabel.numberOfLines = 0
        
        label_PaidStatus.font = UIFont.boldSystemFont(ofSize: 15.0)
        label_PaidStatus.textColor = .black
        
        innerCard.backgroundColor = UIColor.white
        labelView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear

        bgView.layer.borderWidth = 0.2
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor.white
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension CustomerPaymentCardCell {
    func set(card: CustomerPayment) {
        setConstraint(config: card.cardConfig)
        let paidString = card.isPaid ? "\n \(HippoStrings.paymentPaid)" : "\n \(HippoStrings.paymentPending)"
        if HippoConfig.shared.appUserType == .agent{
            setLabel(label: label_PaidStatus, text: paidString)
        }else if card.isPaid , HippoConfig.shared.appUserType == .customer{
            setLabel(label: label_PaidStatus, text: paidString)
        }else{
            setLabel(label: label_PaidStatus, text: "")
        }
        
        setLabel(label: titleLabel, text: card.title)
        setLabel(label: descriptionLabel, text: card.description)
        amountLabel.attributedText = card.displayAmount
        
        if HippoConfig.shared.appUserType == .customer{
            self.selctionImageView?.image = card.isLocalySelected ? HippoConfig.shared.theme.radioActive : HippoConfig.shared.theme.radioInActive
        }
        
    }
}

extension CustomerPaymentCardCell {
    
    private func setLabel(label: UILabel, text: String?) {
        let parsedText = text?.trimWhiteSpacesAndNewLine() ?? ""
        label.text = parsedText
        label.isHidden = parsedText.isEmpty
    }
    
    private func setConstraint(config: PaymentCardConfig) {
        bgViewTopConstraint.constant = config.bgView.top
        bgViewBottomConstraint.constant = config.bgView.bottom
        bgViewLeadingConstraint.constant = config.bgView.leading
        bgViewTrailingConstraint.constant = config.bgView.trailing
        
        innerViewtopConstraint.constant = config.innerCard.top
        innerViewBottomConstraint.constant = config.innerCard.bottom
        innerViewLeadingConstraint.constant = config.innerCard.leading
        innerViewTrailingConstraint.constant = config.innerCard.trailing
        
        labelViewTopConstraint.constant = config.labelView.top
        labelViewBottomConstraint.constant = config.labelView.bottom
        labelViewLeadingConstraint.constant = config.labelView.leading
        labelViewTrailingConstraint.constant = config.labelView.trailing
        
        imageViewWidthConstraint.constant = config.imageWidth
        amountLabelWidthConstraint.constant = config.amountWidth
        
        labelStackView.spacing = config.labelSpacing
        if  config.imageWidth <= 0 {
            imageView?.isHidden = true
        }
        self.layoutIfNeeded()
        
    }
    
    func addShadow(){
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: bgView.bounds.width, height: 2)
        bgView.layer.shadowRadius = 6
        bgView.layer.shadowOpacity = 1
    }
    
}
