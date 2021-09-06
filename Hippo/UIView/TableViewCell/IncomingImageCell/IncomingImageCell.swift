//
//  IncomingImageCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 31/07/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

//TODO: - Refactor

class IncomingImageCell: MessageTableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var thumbnailImageView: So_UIImageView!
//    @IBOutlet weak var timeLabel: So_CustomLabel!
    @IBOutlet weak var customIndicator: So_UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Variables
    weak var delegate: ImageCellDelegate?
    
    var indexPath: IndexPath?
    
    // MARK: - View Life Cycle
    deinit {
        stopIndicatorAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
    }
    
    // MARK: - IBAction
    @IBAction func retryButtonClicked(_ sender: Any) {
        if delegate != nil, let cellIndex = indexPath {
            delegate?.reloadCell(withIndexPath: cellIndex)
        }
    }
    
    @IBAction func imageTapped(_ sender: UIButton) {
        guard let message = self.message else {
            return
        }
        delegate?.showImageFor(message: message)
    }
    
    // MARK: - Methods
    func setupBoxBackground(messageType: Int) {
        mainContentView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor //HippoConfig.shared.theme.incomingChatBoxColor

//       // mainContentView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
//        DispatchQueue.main.async {
//            let gradient = CAGradientLayer()
//            gradient.frame = self.mainContentView.bounds
//            gradient.colors = [HippoConfig.shared.theme.gradientTopColor.cgColor, HippoConfig.shared.theme.gradientBottomColor.cgColor]
//            self.mainContentView.layer.insertSublayer(gradient, at: 0)
//
//            // self.shadowView.backgroundColor = UIColor.red
//        }
    }
    
    func adjustShadow() {
        shadowView.layoutIfNeeded()
        shadowView.clipsToBounds = true
        shadowView.backgroundColor = HippoConfig.shared.theme.chatBoxBorderColor

    }
}

//MARK: - Configure
extension IncomingImageCell {
    func resetPropertiesOfIncomingCell() {
        backgroundColor = .clear
        thumbnailImageView.image = nil
        selectionStyle = .none
        timeLabel.text = ""
        timeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
        
        retryButton.isHidden = true
        retryButton.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        mainContentView.layer.cornerRadius = 10
        thumbnailImageView.layer.cornerRadius = mainContentView.layer.cornerRadius
        shadowView.layer.cornerRadius = mainContentView.layer.cornerRadius
        thumbnailImageView.clipsToBounds = true
        mainContentView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            thumbnailImageView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            mainContentView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            shadowView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func configureIncomingCell(resetProperties: Bool, channelId: Int, chatMessageObject: HippoMessage, indexPath: IndexPath) -> IncomingImageCell {
        if resetProperties { resetPropertiesOfIncomingCell() }
        
        super.intalizeCell(with: chatMessageObject, isIncomingView: true)
        
        self.message = chatMessageObject
        
        self.indexPath = indexPath
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        
        
        if channelId <= 0 {
            
        } else {
            let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
            timeLabel.text = "\t" + "\(timeOfMessage)"
        }
        
        if let thumbnailUrl = chatMessageObject.thumbnailUrl, thumbnailUrl.isEmpty == false, let url = URL(string: thumbnailUrl) {
            setupIndicatorView(true)
            let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
            
            thumbnailImageView.kf.setImage(with: url, placeholder: placeHolderImage, completionHandler: { [weak self]  (_, error, _, _) in
                self?.setupIndicatorView(false)
                if error != nil {
                    self?.retryButton.isHidden = false
                }
            })
        }
        
        return self
    }
    
//    func configureIncomingCell(resetProperties: Bool, channelId: Int, chatMessageObject: HippoMessage, indexPath: IndexPath) -> IncomingImageCell {
//        if resetProperties { resetPropertiesOfIncomingCell() }
//        
//        msgObject = chatMessageObject
//        self.indexPath = indexPath
//        
//        let messageType = chatMessageObject.type.rawValue
//        setupBoxBackground(messageType: messageType)
//        
//        if channelId <= 0 {}
//        ese {
//            let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
//            timeLabel.text = "\t" + "\(timeOfMessage)"
//        }
//        
//        if let thumbnailUrl = chatMessageObject.thumbnailUrl, thumbnailUrl.isEmpty == false, let url = URL(string: thumbnailUrl) {
//            setupIndicatorView(true)
//            let placeHolderImage = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
//            
//            thumbnailImageView.kf.setImage(with: url, placeholder: placeHolderImage, completionHandler: { [weak self]  (_, error, _, _) in
//                self?.setupIndicatorView(false)
//                if error != nil {
//                    self?.retryButton.isHidden = false
//                }
//            })
//        }
//        
//        return self
//    }
}

//MARK: - HELPERS
extension IncomingImageCell {
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
