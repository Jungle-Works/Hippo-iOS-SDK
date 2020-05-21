//
//  BroadcastUserStatusCell.swift
//  Fugu
//
//  Created by Vishal on 11/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
protocol BroadcastUserStatusCellDelegate: class {
    func openChatButtonClickedFor(user: CustomerInfo)
}

class BroadcastUserStatusCell: UITableViewCell {

    @IBOutlet weak var openChatButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Variable
    var user: CustomerInfo!
    weak var delegate: BroadcastUserStatusCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUITheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func openChatButtonClicked(_ sender: Any) {
        delegate?.openChatButtonClickedFor(user: user)
    }
    
    private func setUITheme() {
        nameLabel.font = UIFont.regular(ofSize: 16)
        nameLabel.textColor = UIColor.black
        
        statusLabel.font = UIFont.regular(ofSize: 13)
        statusLabel.textColor = UIColor.gray
        
        openChatButton.setImage(HippoConfig.shared.theme.openChatIcon, for: .normal)
        openChatButton.tintColor = UIColor.white
        openChatButton.setTitle("", for: .normal)
        openChatButton.backgroundColor = UIColor.themeColor
        openChatButton.layer.cornerRadius = (openChatButton.bounds.height / 2)
    }
    
    func setCellData(user: CustomerInfo) {
        self.user = user
        
        nameLabel.text = user.customerName.isEmpty ? user.customerEmail : user.customerName
        
        let statusText: String
        
        if user.unreadCount > 0 {
            statusText = "Delivered"
        } else {
            let dateString = user.lastActivityDate?.toString(with: .broadcastDate) ?? ""
            statusText = dateString.isEmpty ? "Read" : "Read at \(dateString)"
        }
        statusLabel.text = statusText
        
        if let channelId = user.repliedOn, channelId > 0 {
            openChatButton.isHidden = false
        } else {
            openChatButton.isHidden = true
        }
    }
}
