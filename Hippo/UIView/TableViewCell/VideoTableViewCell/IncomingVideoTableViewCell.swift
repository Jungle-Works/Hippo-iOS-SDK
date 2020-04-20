//
//  IncomingVideoTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 18/07/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class IncomingVideoTableViewCell: VideoTableViewCell {
    
    @IBOutlet weak var senderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBackgroundView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        messageBackgroundView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        messageBackgroundView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        messageBackgroundView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        senderNameLabel.font = HippoConfig.shared.theme.senderNameFont
        senderNameLabel.textColor = HippoConfig.shared.theme.senderNameColor
        
        //      addTapGestureInNameLabel()
    }
    
    // MARK: - Methods
    func addTapGestureInNameLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        senderNameLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func nameTapped() {
        //      if message != nil {
        //         interactionDelegate?.nameOnMessageTapped(message!)
        //      }
    }
    
    func setCellWith(message: HippoMessage) {
        self.message?.statusChanged = nil
        
        super.intalizeCell(with: message, isIncomingView: true)
        
        self.senderNameLabel.text = message.senderFullName
        
        message.statusChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.setCellWith(message: message)
            }
            
        }
        
        self.setSenderImageView()
        setDisplayView()
        setDownloadView()
        setBottomDistance()
    }
    
}
