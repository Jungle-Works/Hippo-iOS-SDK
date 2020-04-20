//
//  VideoTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 18/07/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class VideoTableViewCell: MessageTableViewCell {
   
   // MARK: - IBOutlets
   @IBOutlet weak var viewFrameImageView: UIImageView!
   @IBOutlet weak var messageBackgroundView: UIView!
   @IBOutlet weak var downloadButton: UIButton!
   @IBOutlet weak var playButton: UIButton!
   @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var bottomDistanceOfMessageBgView: NSLayoutConstraint!
   @IBOutlet weak var sizeLabel: UILabel!
   
   
   // MARK: - Properties
   weak var delegate: VideoTableViewCellDelegate?
   
   //MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
      
      viewFrameImageView.contentMode = .scaleAspectFill

      timeLabel.text = ""
      timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
      timeLabel.textAlignment = .right
      timeLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
      
      messageBackgroundView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
      messageBackgroundView.backgroundColor = HippoConfig.shared.theme.outgoingChatBoxColor
      messageBackgroundView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
      messageBackgroundView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
      
      addNotificationObservers()
   }
   
   func addNotificationObservers() {
      NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadCompleted(_:)), name: Notification.Name.fileDownloadCompleted, object: nil)
   }
   
   @objc func fileDownloadCompleted(_ notification: Notification) {
      guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String else {
         return
      }
      
      if message?.fileUrl == url {
         setDownloadView()
      }
   }
   
   // MARK: - IBAction
   @IBAction func downloadButtonPressed() {
      guard let unwrappedMessage = message else {
         print("-------ERROR\nCannot download, Message is nil\n-------")
         return
      }
      delegate?.downloadFileIn(message: unwrappedMessage)
      setDownloadView()
   }
   
   @IBAction func playVideoButtonPressed() {
      guard let unwrappedMessage = message else {
         print("-------ERROR\nCannot play, Message is nil\n-------")
         return
      }
      
      delegate?.openFileIn(message: unwrappedMessage)
      setDownloadView()
   }
   
   // MARK: - Methods
   func setBottomDistance() {
      let bottomDistance: CGFloat = 2
      
      guard let _ = message else {
         return
      }
      bottomDistanceOfMessageBgView.constant = bottomDistance
   }
   
   func setDisplayView() {
      if let imageThumbnailURL = message?.thumbnailUrl, let url = URL(string: imageThumbnailURL) {
        viewFrameImageView.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage)
      } else {
         viewFrameImageView.image = HippoConfig.shared.theme.placeHolderImage
      }

      
      setTime()
      sizeLabel.text = message?.fileSize ?? nil
   }

   func setDownloadView() {
      guard let unwrappedMessage = message else {
         hideDownloadView()
         return
      }
      let readyToDownload = !unwrappedMessage.isSentByMe() || unwrappedMessage.status != .none
      
      guard let fileURL = unwrappedMessage.fileUrl else {
         hideDownloadView()
         return
      }
      
      guard (readyToDownload ? unwrappedMessage.fileUrl != nil : true) else {
         print("ERROR------\nNo URL Found to download Video\n--------")
         return
      }
      
      let isDownloading = DownloadManager.shared.isFileBeingDownloadedWith(url: fileURL)
      let isDownloaded = DownloadManager.shared.isFileDownloadedWith(url: fileURL)
      
      
      switch (isDownloading, isDownloaded) {
      case (false, false):
         playButton.isHidden = true
         downloadButton.isHidden = false
         downloadActivityIndicator.isHidden = true
      case (true, _):
         playButton.isHidden = true
         downloadButton.isHidden = true
         downloadActivityIndicator.startAnimating()
         downloadActivityIndicator.isHidden = false
      case (_, true):
         playButton.isHidden = false
         downloadButton.isHidden = true
         downloadActivityIndicator.isHidden = true
      }
   }
   
   func hideDownloadView() {
      downloadButton.isHidden = true
      playButton.isHidden = true
      downloadActivityIndicator.isHidden = true
   }

}
