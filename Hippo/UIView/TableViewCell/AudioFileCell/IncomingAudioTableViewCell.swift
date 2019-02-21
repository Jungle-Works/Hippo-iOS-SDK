//
//  IncomingAudioTableViewCell.swift
//  OfficeChat
//
//  Created by Vishal on 22/03/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class IncomingAudioTableViewCell: AudioTableViewCell {
    
    @IBOutlet weak var downloadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var senderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
//      addTapGestureInNameLabel()
    }
    
    func setData(message: HippoMessage) {

        setUIAccordingToTheme()
        
        self.message = message
        self.cellIdentifier = message.fileUrl ?? ""
        
        setTime()
        
        senderNameLabel.text = message.senderFullName
        updateUI()
    }

    func setUIAccordingToTheme() {
        timeLabel.text = ""
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textAlignment = .left
        timeLabel.textColor = HippoConfig.shared.theme.timeTextColor
        downloadingIndicator.stopAnimating()
        
        bgView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        senderNameLabel.font = HippoConfig.shared.theme.senderNameFont
        senderNameLabel.textColor = HippoConfig.shared.theme.senderNameColor
        
        fileName.font = HippoConfig.shared.theme.incomingMsgFont
        fileName.textColor = HippoConfig.shared.theme.incomingMsgColor
        
        
        self.backgroundColor = UIColor.clear
    }
   
   func addTapGestureInNameLabel() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
      senderNameLabel.addGestureRecognizer(tapGesture)
   }
   @objc func nameTapped() {
//      if let msg = message {
//         interactionDelegate?.nameOnMessageTapped(msg)
//      }
   }
    
}

class AudioTableViewCell: MessageTableViewCell {
    var cellIdentifier = ""
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fullLengthLineview: UIView!
    @IBOutlet weak var progressViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var audioPlayedTimeLabel: UILabel!
    @IBOutlet weak var audiocompletionProgressView: UIView!
    @IBOutlet weak var fileName: UILabel!

   override func awakeFromNib() {
      super.awakeFromNib()
      
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
         updateDownloadProgressView()
         updateButtonAccordingToStatus()
      }
   }
    
    func updateUI() {
        updateButtonAccordingToStatus()
        self.updateProgressBarView()
        updateLabels()
        updateDownloadProgressView()
    }
    
    func updateButtonAccordingToStatus() {
        controlButton.isHidden = isFileBeingDownloaded()
        
        guard isFileDownloaded() else {
            controlButton.setImage(HippoConfig.shared.theme.downloadIcon, for: .normal)
            return
        }
        
        if  AudioPlayerManager.shared.tag != cellIdentifier {
            controlButton.setImage(HippoConfig.shared.theme.playIcon, for: .normal)
            return
        }
        if AudioPlayerManager.shared.audioPlayer?.isPlaying == false {
            controlButton.setImage(HippoConfig.shared.theme.playIcon, for: .normal)
        } else {
            controlButton.setImage(HippoConfig.shared.theme.pauseIcon, for: .normal)
        }
    }
    
    func isFileDownloaded() -> Bool {
        guard !self.cellIdentifier.isEmpty else {
            return false
        }
        return DownloadManager.shared.isFileDownloadedWith(url: self.cellIdentifier)
    }
    
    func updateDownloadProgressView() {
        if isFileBeingDownloaded() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func isFileBeingDownloaded() -> Bool {
        return DownloadManager.shared.isFileBeingDownloadedWith(url: cellIdentifier)
    }
    
    func updateProgressBarView() {
        DispatchQueue.main.async {
            guard AudioPlayerManager.shared.tag == self.cellIdentifier else {
                self.progressViewWidthConstraint.constant = 0
                self.layoutIfNeeded()
                return
            }
            
            let totalTime = round(AudioPlayerManager.shared.audioPlayer?.duration ?? 1)
            let completedTime = round(AudioPlayerManager.shared.audioPlayer?.currentTime ?? 0)
            
            let ratio = completedTime / totalTime
            self.progressViewWidthConstraint.constant = CGFloat(ratio * Double(self.fullLengthLineview.frame.width))
            
            self.layoutIfNeeded()
        }
    }
    
    func updateLabels() {
        DispatchQueue.main.async {
            self.fileName.text = self.message!.fileName

            guard AudioPlayerManager.shared.tag == self.cellIdentifier else {
                self.totalTimeLabel.text = ""
                self.audioPlayedTimeLabel.text = ""
                return
            }
            
            let totalTime = round(AudioPlayerManager.shared.audioPlayer?.duration ?? 0)
            let completedTime = round(AudioPlayerManager.shared.audioPlayer?.currentTime ?? 0)
            
            self.totalTimeLabel.text = self.getMintues(from: totalTime) + ":" + self.getSeconds(from: totalTime)
            self.audioPlayedTimeLabel.text = self.getMintues(from: completedTime) + ":" + self.getSeconds(from: completedTime)
        }
    }
    
    func getSeconds(from timeInterval: Double) -> String {
        
        guard isFileDownloaded() else {
            return "--"
        }
        
        var seconds = "00"
        
        guard timeInterval > 0 else {
            return seconds
        }
        
        let sec = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        seconds = String.init(format: "%.2d", sec)
        
        return seconds
    }
    
    func getMintues(from timeInterval: Double) -> String {
        guard isFileDownloaded() else {
            return "-"
        }
        
        var minutes = "0"
        
        guard timeInterval > 0 else {
            return minutes
        }
        let min = Int(timeInterval / 60)
        minutes = "\(min)"
        
        return minutes
    }
    
    
    func startDownloading() {
        guard !cellIdentifier.isEmpty else {
            return
        }
        let name = message?.fileName ?? ""
        DownloadManager.shared.downloadFileWith(url: cellIdentifier, name: name)
        updateDownloadProgressView()
        updateButtonAccordingToStatus()
    }
    
    @IBAction func controlButtonAction(_ sender: Any) {
        
        guard isFileDownloaded() else {
            self.startDownloading()
            return
        }
        
        if AudioPlayerManager.shared.tag == cellIdentifier {
            AudioPlayerManager.shared.delegate = self

            if AudioPlayerManager.shared.audioPlayer?.isPlaying == true {
                AudioPlayerManager.shared.stop()
            } else if AudioPlayerManager.shared.audioPlayer?.isPlaying == false {
                AudioPlayerManager.shared.play()
            }
            updateButtonAccordingToStatus()
            
            return
        }
        
        if let newInstance = AudioPlayerManager.getNewObject(with: cellIdentifier) {
            AudioPlayerManager.shared = newInstance
            AudioPlayerManager.shared.delegate = nil
        }
        AudioPlayerManager.shared.delegate = self
        AudioPlayerManager.shared.play()
        updateButtonAccordingToStatus()
    }
}

extension AudioTableViewCell: AudioPlayerManagerDelegate {
    func playerEnded(_ player: AVAudioPlayer) {
        updateUI()
    }
    
    func timer(_ player: AVAudioPlayer) {
        self.updateLabels()
        self.updateProgressBarView()
    }
}
