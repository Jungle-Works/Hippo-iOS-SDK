//
//  BroadcastListTableViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class BroadcastListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var broadcastStackView: UIStackView!
    @IBOutlet weak var forwardImageView: UIImageView!
    @IBOutlet weak var fallbackStackView: UIStackView!
    @IBOutlet weak var fallbackNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var broadcastTypeLabel: UILabel!
    
    
    var broadcast: BroadcastInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        setTheme()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTheme() {
        bgView.layer.cornerRadius = 5
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        forwardImageView.tintColor = HippoConfig.shared.theme.headerBackgroundColor
        forwardImageView.image = HippoConfig.shared.theme.forwardIcon
        
        let font = UIFont.regular(ofSize: 15)
        
        dateLabel.font = font
        senderNameLabel.font = font
        titleLabel.font = font
        fallbackNameLabel.font = font
        messageLabel.font = font
        broadcastTypeLabel.font = font
    }
    
    func setupCellWith(broadcast: BroadcastInfo) {
        
        self.broadcast = broadcast
        
        dateLabel.text = (broadcast.creationDate ?? Date()).toString(with: .broadcastDate)
        
        messageLabel.text = ""
        messageLabel.attributedText = broadcast.attributedMessage
        
        titleLabel.text = broadcast.title
        senderNameLabel.text = broadcast.agentName.isEmpty ? broadcast.agentEmail : broadcast.agentName
        
        fallbackStackView.isHidden = broadcast.fallbackText.isEmpty
        fallbackNameLabel.text = broadcast.fallbackText
        
        broadcastTypeLabel.text = broadcast.broadcastType.description
        broadcastStackView.isHidden = broadcast.broadcastType == .unknown
    }
    
    func setHomeUI() {
        messageLabel.numberOfLines = 6
        titleLabel.numberOfLines = 3
        fallbackNameLabel.numberOfLines = 1
        forwardImageView.isHidden = false
    }
    
    func setDetailUI() {
        titleLabel.numberOfLines = 0
        messageLabel.numberOfLines = 0
        fallbackNameLabel.numberOfLines = 0
        forwardImageView.isHidden = true
    }
}
