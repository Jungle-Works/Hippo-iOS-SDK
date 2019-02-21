//
//  OutgoingImageCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 31/07/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
protocol ImageCellDelegate: class {
    func reloadCell(withIndexPath indexPath: IndexPath)
    func retryUploadForImage(message: HippoMessage)
    func showImageFor(message: HippoMessage)
}

class OutgoingImageCell: MessageTableViewCell {
    
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var thumbnailImageView: So_UIImageView!
//    @IBOutlet weak var timeLabel: So_CustomLabel!
    @IBOutlet weak var readUnreadImageView: So_UIImageView!
    @IBOutlet weak var customIndicator: So_UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var retryButton: UIButton!
    
    
    var indexPath: IndexPath?
    weak var delegate: ImageCellDelegate?
    
    @IBAction func retryButtonClicked(_ sender: UIButton) {
        guard let messageObject = message, FuguNetworkHandler.shared.isNetworkConnected else {
            self.setupIndicatorView(false)
            self.retryButton.isHidden = false
            return
        }
        self.setupIndicatorView(true)
        self.retryButton.isHidden = true
        delegate?.retryUploadForImage(message: messageObject)
    }
    
    @IBAction func imageTapped(_ sender: UIButton) {
        guard let messageObject = message else {
            return
        }
        delegate?.showImageFor(message: messageObject)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
    }
    
    deinit { stopIndicatorAnimation() }
}

//MARK: - Configure Cell
extension OutgoingImageCell {
    func setupBoxBackground(messageType: Int) {
        mainContentView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
    }
    
    func adjustShadow() {
        shadowView.layoutIfNeeded()
        mainContentView.layoutIfNeeded()
        
        shadowView.layer.cornerRadius = self.mainContentView.layer.cornerRadius
        shadowView.clipsToBounds = true
        shadowView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor
    }
    
    func resetPropertiesOfOutgoingCell() {
        backgroundColor = .clear
        selectionStyle = .none
        timeLabel.text = ""
        mainContentView.layer.cornerRadius = 5
        
        thumbnailImageView.image = nil
        thumbnailImageView.layer.cornerRadius = mainContentView.layer.cornerRadius
        thumbnailImageView.clipsToBounds = true
        
        retryButton.isHidden = true
        
        readUnreadImageView.image = UIImage(named: "unreadMsgTick", in: FuguFlowManager.bundle, compatibleWith: nil)
    }
    
    func configureCellOfOutGoingImageCell(resetProperties: Bool, chatMessageObject: HippoMessage, indexPath: IndexPath) {
        if resetProperties {
            resetPropertiesOfOutgoingCell()
        }
        
        message?.statusChanged = nil
        
        super.intalizeCell(with: chatMessageObject)
        self.message = chatMessageObject
        self.indexPath = indexPath
        
        
        message?.statusChanged = {
            DispatchQueue.main.async {
                guard self.message != nil, self.indexPath != nil else {
                    return
                }
                self.configureCellOfOutGoingImageCell(resetProperties: true, chatMessageObject: self.message!, indexPath: self.indexPath!)
            }
        }
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        
        setReadUnreadStatus()
        hideUnhideRetryButton(hide: true)
        self.setupIndicatorView(true)
        
        if let thumbnailUrl = chatMessageObject.thumbnailUrl, !thumbnailUrl.isEmpty, let url = URL(string: thumbnailUrl) {
            
            setupIndicatorView(true)
            hideUnhideRetryButton(hide: true)
            let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
            
            thumbnailImageView.kf.setImage(with: url, placeholder: placeHolderImage,  completionHandler: { [weak self] (_, error, _, _) in
                self?.retryButton.isHidden = !chatMessageObject.wasMessageSendingFailed
                self?.setupIndicatorView(false)
                if error != nil {
                    self?.setupIndicatorView(true)
                    self?.retryButton.isHidden = true
                }
            })
        } else if let imageFile = chatMessageObject.localImagePath, imageFile.isEmpty == false {
            if chatMessageObject.isFileUploading {
                hideUnhideRetryButton(hide: true)
                self.setupIndicatorView(true)
            } else {
                self.setupIndicatorView(false)
                self.thumbnailImageView.image = nil
                hideUnhideRetryButton(hide: !chatMessageObject.wasMessageSendingFailed)
            }
            thumbnailImageView.image = UIImage(contentsOfFile: imageFile)
        } else {
            hideUnhideRetryButton(hide: false)
            self.setupIndicatorView(false)
        }
        
        let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        timeLabel.text = "\(timeOfMessage)"
        
    }
    
    
    func hideUnhideRetryButton(hide: Bool) {
        DispatchQueue.main.async {
            self.retryButton.isHidden = hide
        }
    }
    
    private func setReadUnreadStatus() {
        readUnreadImageView.tintColor = nil
        
        guard let messageReadStatus = message?.status else {
            return
        }
        
        switch messageReadStatus {
        case .sent:
            readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
            if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
            
        case .read:
            readUnreadImageView.image = HippoConfig.shared.theme.readMessageTick
            if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        default:
            readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
            if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
                readUnreadImageView.tintColor = tintColor
            }
        }
    }
    
}

//MARK: - HELPERS
extension OutgoingImageCell {
    func setupIndicatorView(_ show: Bool) {
        customIndicator.image = UIImage(named: "app_loader_shape", in: FuguFlowManager.bundle, compatibleWith: nil)
        if show {
            startIndicatorAnimation()
            customIndicator.isHidden = false
        } else {
            stopIndicatorAnimation()
            customIndicator.isHidden = true
        }
    }
    
    func startIndicatorAnimation() {
        customIndicator.startRotationAnimation()
    }
    
    func stopIndicatorAnimation() {
        customIndicator.stopRotationAnimation()
    }
}
