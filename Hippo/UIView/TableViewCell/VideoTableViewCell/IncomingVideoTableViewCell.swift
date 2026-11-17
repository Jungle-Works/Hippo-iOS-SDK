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

        if HippoConfig.shared.appUserType == .customer {
            centerOverlaysOnThumbnail()
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
    
    override func setSenderImageView() {
        // No profile icon on incoming video cards in the revamped customer thread —
        // collapses the leading space so the card aligns with the other received messages.
        // The agent screen keeps its avatar.
        guard HippoConfig.shared.appUserType == .customer else {
            super.setSenderImageView()
            return
        }
        hideSenderImageView()
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
        
        // Revamped customer thread shows no sender name on received cards. Cleared as well as
        // hidden: the label isn't in a stack, so an empty label collapses to zero height and
        // the video (preferred 184pt, priority 750) grows into the freed space.
        let hidesSenderName = HippoConfig.shared.appUserType == .customer
        self.senderNameLabel.text = hidesSenderName ? nil : message.senderFullName
        self.senderNameLabel.isHidden = hidesSenderName
        self.messageView.text = message.message
        // The caption shares a row with the time; an empty non-scrolling text view still
        // keeps a line + insets (~33pt), which padded the time well beyond the sent video's.
        // Hiding it collapses the row to the time's height (customer thread only).
        if hidesSenderName {
            let hasCaption = !message.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            self.messageView.isHidden = !hasCaption
            // With a caption, stack it above the time instead of beside it - side by side,
            // a long caption squeezed the time off the right edge ("1..."). The time keeps
            // its right alignment on its own line; the row self-sizes for the caption.
            if let captionRow = messageView.superview as? UIStackView {
                captionRow.axis = hasCaption ? .vertical : .horizontal
                captionRow.spacing = hasCaption ? 2 : 10
            }
        }
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
