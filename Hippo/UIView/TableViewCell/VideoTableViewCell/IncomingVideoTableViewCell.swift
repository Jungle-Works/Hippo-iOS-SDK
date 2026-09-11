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

        // Revamped customer thread: received video bubble reads the receiver token, matching
        // the received text/image bubbles instead of the legacy grey incomingChatBoxColor.
        if HippoConfig.shared.appUserType == .customer {
            let colorConfig = HippoConfig.shared.colorConfig
            messageBackgroundView.backgroundColor = colorConfig.hippoReceiver
            // A layer.mask clips the rectangular border into corner gaps, so drop it and
            // let the white-on-surface contrast carry the bubble (same as the received image cell).
            messageBackgroundView.layer.borderWidth = 0
            timeLabel.textColor = colorConfig.hippoTextMuted
            // Per-corner radii replace the uniform chatBoxCornerRadius; applied in
            // layoutSubviews once bounds are final (CAShapeLayer path is a one-shot snapshot).
            messageBackgroundView.layer.cornerRadius = 0
            viewFrameImageView.layer.cornerRadius = 0
        }

        senderNameLabel.font = HippoConfig.shared.theme.senderNameFont
        senderNameLabel.textColor = HippoConfig.shared.theme.senderNameColor
        messageView.textColor = HippoConfig.shared.theme.incomingMsgColor
        //      addTapGestureInNameLabel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard HippoConfig.shared.appUserType == .customer else { return }
        // Mirror of the sent bubble shape: bottom-left tucked to 5pt on the received side.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messageBackgroundView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 5, bottomRight: 10)
            self.viewFrameImageView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 5, bottomRight: 10)
        }
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
        self.messageView.text = message.message
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
