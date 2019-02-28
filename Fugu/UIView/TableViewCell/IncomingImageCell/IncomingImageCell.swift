//
//  IncomingImageCell.swift
//  Fugu
//
//  Created by Gagandeep Arora on 31/07/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

//TODO: - Refactor

class IncomingImageCell: So_TableViewCell {
   
   // MARK: - IBOutlets
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var thumbnailImageView: So_UIImageView!
    @IBOutlet weak var timeLabel: So_CustomLabel!
    @IBOutlet weak var customIndicator: So_UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryButton: UIButton!
   
   // MARK: - Variables
    var msgObject = FuguMessage(message: "", type: .imageFile)
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
      delegate?.showImageFor(message: msgObject)
   }
   
   // MARK: - Methods
    func setupBoxBackground(messageType: Int) {
        mainContentView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
    }
    
    func adjustShadow() {
        shadowView.layoutIfNeeded()
        mainContentView.layoutIfNeeded()
        
        shadowView.layer.cornerRadius = mainContentView.layer.cornerRadius
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
        
        retryButton.isHidden = true
        retryButton.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        mainContentView.layer.cornerRadius = 5
        thumbnailImageView.layer.cornerRadius = mainContentView.layer.cornerRadius
        thumbnailImageView.clipsToBounds = true
    }
    
    func configureIncomingCell(resetProperties: Bool, channelId: Int, chatMessageObject: FuguMessage, indexPath: IndexPath) -> IncomingImageCell {
        if resetProperties { resetPropertiesOfIncomingCell() }
        
        msgObject = chatMessageObject
        self.indexPath = indexPath
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        
        if channelId <= 0 {}
        else {
            let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
            timeLabel.text = "\t" + "\(timeOfMessage)"
        }
        
        if let thumbnailUrl = chatMessageObject.thumbnailUrl, thumbnailUrl.isEmpty == false, let url = URL(string: thumbnailUrl) {
            setupIndicatorView(true)
            let placeHolderImage = UIImage(named: "placeholderImg", in: HippoFlowManager.bundle, compatibleWith: nil)
            
            thumbnailImageView.kf.setImage(with: url, placeholder: placeHolderImage, completionHandler: { [weak self]  (_, error, _, _) in
                self?.setupIndicatorView(false)
                if error != nil {
                    self?.retryButton.isHidden = false
                }
            })
        }
        
        return self
    }
}

//MARK: - HELPERS
extension IncomingImageCell {
    func setupIndicatorView(_ show: Bool) {
        customIndicator.image = UIImage(named: "app_loader_shape", in: HippoFlowManager.bundle, compatibleWith: nil)
        
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
