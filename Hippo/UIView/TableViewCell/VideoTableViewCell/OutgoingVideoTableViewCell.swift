//
//  OutgoingVideoTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 18/07/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class OutgoingVideoTableViewCell: VideoTableViewCell {
   
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var uploadActivityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var retryUploadButton: UIButton!
   @IBOutlet weak var messageStatusImageView: UIImageView!
   
    weak var retryDelegate: RetryMessageUploadingDelegate?
    var messageLongPressed : ((HippoMessage)->())?
    
   // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGestureFired))
        longPressGesture.minimumPressDuration = 0.3
        messageBackgroundView?.addGestureRecognizer(longPressGesture)
        nameLbl.font = HippoConfig.shared.theme.broadcastTitleInfoFont

        // Revamped customer thread: sent video bubble reads the accent token, matching
        // the sent text/image bubbles instead of the legacy grey outgoingChatBoxColor.
        if HippoConfig.shared.appUserType == .customer {
            let colorConfig = HippoConfig.shared.colorConfig
            messageBackgroundView.backgroundColor = colorConfig.hippoAccent
            messageBackgroundView.layer.borderWidth = 0
            timeLabel.textColor = colorConfig.hippoOnAccent
            // Per-corner radii replace the uniform chatBoxCornerRadius; applied in
            // layoutSubviews once bounds are final (CAShapeLayer path is a one-shot snapshot).
            messageBackgroundView.layer.cornerRadius = 0
            viewFrameImageView.layer.cornerRadius = 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard HippoConfig.shared.appUserType == .customer else { return }
        // Same shape as the sent text bubble: three 10pt corners, bottom-right tucked to 5pt.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.messageBackgroundView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
            self.viewFrameImageView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
        }
    }
   
    @objc func longPressGestureFired(sender: UIGestureRecognizer) {
       guard sender.state == .began else {
          return
       }
        if let message = message{
            messageLongPressed?(message)
        }
    }
   // MARK: - IBAction
   @IBAction func retryUploadButtonPressed() {
      guard let unwrappedMessage = message else {
         print("Error Retrying to upload video")
         return
      }
      
      retryDelegate?.retryUploadFor(message: unwrappedMessage)
      setUploadingView()
   }

   
   func setCellWith(message: HippoMessage) {
      self.message?.statusChanged = nil
       if message.senderFullName != HippoConfig.shared.agentDetail?.fullName ?? ""{
           nameLbl.text = message.senderFullName
       }else{
           nameLbl.text = "You"
       }
      super.intalizeCell(with: message, isIncomingView: false)
    
//      self.forwardButtonView.isHidden = message.status == .none
      
      message.statusChanged = { [weak self] in
         DispatchQueue.main.async {
            self?.setCellWith(message: message)
         }
         
      }
      
      setDisplayView()
      setUploadingView()
      setMessageStatusView()
      setDownloadView()
      setBottomDistance()
   }
   
   func setUploadingView() {
      retryUploadButton.isHidden = true
      uploadActivityIndicator.isHidden = true
      
      guard let unwrappedMessage = message, unwrappedMessage.status == .none else {
         return
      }
      
      let isFileUploaded = unwrappedMessage.imageUrl != nil
      let isFileUploading = unwrappedMessage.isFileUploading
      let isMessageSendingFailed = unwrappedMessage.wasMessageSendingFailed
      
      switch (isFileUploaded, isFileUploading) {
      case (true, false):
         retryUploadButton.isHidden = false
//         retryUploadButton.setTitle("Retry Sending", for: .normal)
      case (false, false):
         retryUploadButton.isHidden = !isMessageSendingFailed
//         retryUploadButton.setTitle("Retry Upload", for: .normal)
      case (false, true):
         uploadActivityIndicator.isHidden = false
         uploadActivityIndicator.startAnimating()
      case (true, true):
         assertionFailure("File cannot be both uploading and uploaded")
      }
   }
  
   func setMessageStatusView() {
      guard let unwrappedMessage = message else {
         messageStatusImageView.image = HippoConfig.shared.theme.unsentMessageIcon
         return
      }
      
      let status = unwrappedMessage.status
      
      switch status {
      case .none:
         messageStatusImageView.image = HippoConfig.shared.theme.unsentMessageIcon
//      case .sent, .delivered:
      case .sent:
         messageStatusImageView.image = HippoConfig.shared.theme.unreadMessageTick
//      case .read:
      case .read, .delivered:
         messageStatusImageView.image = HippoConfig.shared.theme.readMessageTick
      }
   }
}
