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
   func retryUploadFor(message: FuguMessage)
   func showImageFor(message: FuguMessage)
}

class OutgoingImageCell: So_TableViewCell {
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var thumbnailImageView: So_UIImageView!
    @IBOutlet weak var timeLabel: So_CustomLabel!
    @IBOutlet weak var readUnreadImageView: So_UIImageView!
    @IBOutlet weak var customIndicator: So_UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var retryButton: UIButton!
    
   var msgObject = FuguMessage(message: "", type: .imageFile)
    var indexPath: IndexPath?
    weak var delegate: ImageCellDelegate?
    
    @IBAction func retryButtonClicked(_ sender: UIButton) {
        
        if delegate != nil, let cellIndex = indexPath {
            if HippoConnection.isNetworkConnected {
                self.setupIndicatorView(true)
                self.retryButton.isHidden = true
                delegate?.retryUploadFor(message: msgObject)
            } else {
                self.setupIndicatorView(false)
                self.retryButton.isHidden = false
            }
            
        } else if delegate != nil, let cellIndex = indexPath  {
            delegate?.reloadCell(withIndexPath: cellIndex)
        }
    }
   
   @IBAction func imageTapped(_ sender: UIButton) {
      delegate?.showImageFor(message: msgObject)
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
      
        readUnreadImageView.image = UIImage(named: "unreadMsgTick", in: HippoFlowManager.bundle, compatibleWith: nil)
    }
    
   func configureCellOfOutGoingImageCell(resetProperties: Bool, chatMessageObject: FuguMessage, indexPath: IndexPath) -> OutgoingImageCell {
      if resetProperties {
         resetPropertiesOfOutgoingCell()
      }
      
      self.msgObject = chatMessageObject
      self.indexPath = indexPath
      
      let messageType = chatMessageObject.type.rawValue
      setupBoxBackground(messageType: messageType)
      
      readUnreadImageView.tintColor = nil
      let messageReadStatus = chatMessageObject.status.rawValue
      if messageReadStatus == ReadUnReadStatus.none.rawValue {
         readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
         if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
            readUnreadImageView.tintColor = tintColor
         }
      } else if messageReadStatus == ReadUnReadStatus.sent.rawValue && chatMessageObject.localImagePath == nil {
         readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
         if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
            readUnreadImageView.tintColor = tintColor
         }
      } else if messageReadStatus == ReadUnReadStatus.delivered.rawValue && chatMessageObject.localImagePath == nil {
         readUnreadImageView.image = HippoConfig.shared.theme.unreadMessageTick
         if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
            readUnreadImageView.tintColor = tintColor
         }
      } else if messageReadStatus == ReadUnReadStatus.read.rawValue && chatMessageObject.localImagePath == nil {
         readUnreadImageView.image = HippoConfig.shared.theme.readMessageTick
         if let tintColor = HippoConfig.shared.theme.readMessageTintColor {
            readUnreadImageView.tintColor = tintColor
         }
      } else {
         readUnreadImageView.image = HippoConfig.shared.theme.unsentMessageIcon
         if let tintColor = HippoConfig.shared.theme.unsentMessageTintColor {
            readUnreadImageView.tintColor = tintColor
         }
      }
      
      retryButton.isHidden = true
      self.setupIndicatorView(true)
      
      if let thumbnailUrl = chatMessageObject.thumbnailUrl, thumbnailUrl.characters.count > 0, let url = URL(string: thumbnailUrl) {
         
         setupIndicatorView(true)
         self.retryButton.isHidden = true
         let placeHolderImage = UIImage(named: "placeholderImg", in: HippoFlowManager.bundle, compatibleWith: nil)
         
        thumbnailImageView.kf.setImage(with: url, placeholder: placeHolderImage,  completionHandler: { [weak self] (_, error, _, _) in
            self?.retryButton.isHidden = !chatMessageObject.wasMessageSendingFailed
            self?.setupIndicatorView(false)
            if error != nil {
                self?.setupIndicatorView(true)
                self?.retryButton.isHidden = true
            }
        })
      } else if let imageFile = chatMessageObject.localImagePath, imageFile.isEmpty == false {
         if chatMessageObject.isImageUploading {
            retryButton.isHidden = true
            self.setupIndicatorView(true)
         } else {
            self.setupIndicatorView(false)
            self.thumbnailImageView.image = nil
            retryButton.isHidden = !chatMessageObject.wasMessageSendingFailed
         }
         
         thumbnailImageView.image = UIImage(contentsOfFile: imageFile)
      }
      
      let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
      timeLabel.text = "\(timeOfMessage)"
      
      
      return self
   }
}

//MARK: - HELPERS
extension OutgoingImageCell {
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
