//
//  VideoTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 18/07/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import AVFoundation

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

      // Revamped customer thread: no grey chip behind the file size - the xib gives the
      // label's container a 30% black fill. Agent screen keeps it.
      if HippoConfig.shared.appUserType == .customer {
         sizeLabel.superview?.backgroundColor = .clear
      }

      addNotificationObservers()
   }
   
   /// The xibs centre the download/upload/play overlays on the whole bubble. Once a caption
   /// makes the bubble taller, that centre lands in the caption - so re-pin every overlay
   /// centred on the bubble to the video thumbnail instead.
   func centerOverlaysOnThumbnail() {
      guard let bubble = messageBackgroundView, let thumbnail = viewFrameImageView else { return }
      let bubbleCentering = bubble.constraints.filter { constraint in
         let isCentering = constraint.firstAttribute == .centerX || constraint.firstAttribute == .centerY
         return isCentering && constraint.secondItem === bubble && constraint.firstItem !== thumbnail
      }
      for constraint in bubbleCentering {
         guard let overlay = constraint.firstItem as? UIView else { continue }
         constraint.isActive = false
         let anchor = constraint.firstAttribute == .centerX
            ? overlay.centerXAnchor.constraint(equalTo: thumbnail.centerXAnchor)
            : overlay.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor)
         anchor.isActive = true
      }
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
      if message?.type == .embeddedVideoUrl{
        delegate?.openFileIn(message: unwrappedMessage)
      }else{
        delegate?.openFileIn(message: unwrappedMessage)
        setDownloadView()
      }
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
      if message?.type == .embeddedVideoUrl{
        if let videoLinkStr = message?.customAction?.videoLink, let _ = URL(string: videoLinkStr) {
            //Other method to get video ID using extension
            print(videoLinkStr.youtubeID as Any)
            //genarateThumbnailFromYouTubeID(youTubeID: youTubeID)
            //getThumbnailFromVideoUrl(urlString: url)
            if let youTubeID = videoLinkStr.youtubeID{
                if let img = genarateThumbnailFromYouTubeID(youTubeID: youTubeID){
                    viewFrameImageView.image = img
                    self.showPlayButtonForEmbeddedVideoUrl()
                }else{
                    viewFrameImageView.image = HippoConfig.shared.theme.placeHolderImage
                    self.hidePlayButtonForEmbeddedVideoUrl()
                }
            }else{
                if let img = getThumbnailFromVideoUrl(urlString: videoLinkStr){
                    viewFrameImageView.image = img
                    self.showPlayButtonForEmbeddedVideoUrl()
                }else{
                    viewFrameImageView.image = HippoConfig.shared.theme.placeHolderImage
                    self.hidePlayButtonForEmbeddedVideoUrl()
                }
            }
        } else {
            viewFrameImageView.image = HippoConfig.shared.theme.placeHolderImage
            self.hidePlayButtonForEmbeddedVideoUrl()
        }
      }else{
        if let imageThumbnailURL = message?.thumbnailUrl, let url = URL(string: imageThumbnailURL) {
            viewFrameImageView.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage)
        } else {
            viewFrameImageView.image = HippoConfig.shared.theme.placeHolderImage
        }
      }
    
      setTime()
      sizeLabel.text = message?.fileSize ?? nil
   }
    
    //MARK:- Generate Thumbnail Functions
    func genarateThumbnailFromYouTubeID(youTubeID: String) -> UIImage? {
        let urlString = "http://img.youtube.com/vi/\(youTubeID)/1.jpg"
        let image = try! (UIImage(withContentsOfUrl: urlString))!
        return image
    }
    func getThumbnailFromVideoUrl(urlString: String) -> UIImage? {
//        DispatchQueue.global().async {
            let asset = AVAsset(url: URL(string: urlString)!)
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 20)
            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            if img != nil {
                let frameImg  = UIImage(cgImage: img!)
//                DispatchQueue.main.async(execute: {
//                    // assign your image to UIImageView
//                })
                return frameImg
            }else{
                return nil
            }
//        }
    }
    func showPlayButtonForEmbeddedVideoUrl(){
        playButton.isHidden = false
        downloadButton.isHidden = true
        downloadActivityIndicator.isHidden = true
    }
    func hidePlayButtonForEmbeddedVideoUrl(){
        playButton.isHidden = true
        downloadButton.isHidden = true
        downloadActivityIndicator.isHidden = true
    }
    
   func setDownloadView() {
    if message?.type == .embeddedVideoUrl{
        
    }else{
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
   }
   
   func hideDownloadView() {
      downloadButton.isHidden = true
      playButton.isHidden = true
      downloadActivityIndicator.isHidden = true
   }

}

extension UIImage {
    convenience init?(withContentsOfUrl imageUrlString: String) throws {
        let imageUrl = URL(string: imageUrlString)!
        let imageData = try Data(contentsOf: imageUrl)
        self.init(data: imageData)
    }
}
extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        return (self as NSString).substring(with: result.range)
    }
}
