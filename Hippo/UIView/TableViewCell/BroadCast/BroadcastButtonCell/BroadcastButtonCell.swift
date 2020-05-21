//
//  BroadcastButtonCell.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol BroadcastButtonCellDelegate: class {
    func previousMessageButtonClicked()
    func sendButtonClicked()
}

class BroadcastButtonCell: UITableViewCell {

    @IBOutlet weak var sendButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousMessagesButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate: BroadcastButtonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        selectionStyle = .none
    }
    func setupCell() {
//        sendButton.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
//        sendButton.setTitleColor(HippoConfig.shared.theme.headerTextColor, for: .normal)
        sendButton.backgroundColor = HippoConfig.shared.theme.themeTextcolor
        sendButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        
//        previousMessagesButton.setTitleColor(HippoConfig.shared.theme.headerBackgroundColor, for: .normal)
        previousMessagesButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
        previousMessagesButton.backgroundColor = UIColor.clear
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func previousMEssageButtonClicked(_ sender: UIButton) {
        delegate?.previousMessageButtonClicked()
    }
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        delegate?.sendButtonClicked()
    }
    func setupCellFor(form: FormData) {
        previousMessagesButton.isHidden = true
        
        sendButton.setTitle(form.title, for: .normal)
//        sendButton.setTitleColor(form.titleColor, for: .normal)
//        sendButton.backgroundColor = form.backgroundColor
        sendButton.backgroundColor = HippoConfig.shared.theme.themeTextcolor
        sendButton.setTitleColor(HippoConfig.shared.theme.themeColor, for: .normal)
        
        sendButtonHeightConstraint.constant = 50
        
        sendButton.layer.cornerRadius = 6
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = form.titleColor?.cgColor
    }
}


