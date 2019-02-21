//
//  VideoCallView.swift
//  Hippo
//
//  Created by Vishal on 10/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Hippo
import UserNotifications
#if canImport(HippoCallClient)
import HippoCallClient
#endif

extension UIView {
    class var safeAreaInsetsForAllOS: UIEdgeInsets {
        var insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets()
        } else {
            insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return insets
    }
    static var safeAreaInsetOfKeyWindow: UIEdgeInsets {
        return safeAreaInsetsForAllOS
    }
}
func HippoDelay(_ withDuration: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + withDuration) {
        completion()
    }
}
let defaultPlaceHolder: UIImage = UIImage(named: "Image01") ?? UIImage()

#if canImport(HippoCallClient)
class VideoCallView: UIView {
   
   // MARK: - Properties
   var callAnswered: (() -> Void)?
   var callHungUp: (() -> Void)?
   var muteAudioButtonPressed: (() -> Void)?
   var unMuteAudioButtonPressed: (() -> Void)?
   var pauseVideoButtonPressed: (() -> Bool)?
   var startVideoButtonPressed: (() -> Bool)?
   var switchCameraButtonPressed: (() -> Bool)?
   var switchRemoteAndLocalVideoViewButtonPressed: (() -> Void)?
   var frameOfRemoteVideoViewChanged: (() -> Void)?
   var frameOfLocalVideoViewChanged: (() -> Void)?
   
   var configureAudioSession: (() -> Void)?
   var audioSessionDeactivated: ((AVAudioSession) -> Void)?
   var audioSessionActivated: ((AVAudioSession) -> Void)?
   
   var setAudioOutputToSpeaker: ((Bool, @escaping (Bool) -> Void) -> Void)?
   
   fileprivate var peer: CallerInfo?
   fileprivate var player: AVAudioPlayer?

   fileprivate let pulseLayer = CallPulsator()
   
   var isFullScreen = false
   var canSwitchToFullScreen = false
   
   var isLocalAndRemoteViewSwitched = false
   
   var isViewMinimized = false
   
   // MARK: - IBOutlets
   @IBOutlet weak var remoteVideoView: UIImageView!
   @IBOutlet weak var localVideoView: UIImageView!
   
   @IBOutlet weak var userImageView: UIImageView!
   @IBOutlet weak var statusLabel: UILabel!
   @IBOutlet weak var peerNameLabel: UILabel!
   @IBOutlet weak var startCallButton: UIButton!
   @IBOutlet weak var endIncomingCallButton: UIButton!
   @IBOutlet weak var endCallOutgoingOrConnected: UIButton!
   
   @IBOutlet weak var bottomDistanceOfLocalVideoView: NSLayoutConstraint!
   @IBOutlet weak var pulseView: UIView!
   
   @IBOutlet weak var muteCallButton: UIButton!
   @IBOutlet weak var switchCameraButton: UIButton!
   @IBOutlet weak var pauseVideoButton: UIButton!
   
   @IBOutlet weak var backButton: UIButton!
   @IBOutlet weak var viewBehindBackButton: UIImageView!
   @IBOutlet weak var heightWidthOfLocalVideoView: NSLayoutConstraint!
   @IBOutlet weak var sideDistanceOfLocalVideoView: NSLayoutConstraint!
   @IBOutlet weak var topDistanceOfBackButton: NSLayoutConstraint!
   
   // MARK: - View Life Cycle
   override func awakeFromNib() {
      super.awakeFromNib()
      
      hideEverythingExceptVideoViews()
      UIApplication.shared.isIdleTimerDisabled = true
      
      if UIView.safeAreaInsetsForAllOS.top == 0 {
         topDistanceOfBackButton.constant = 20
      }
   }

   // MARK: - IBAction
   @IBAction func startCallButtonPressed(_ sender: UIButton) {
      sender.isHidden = true
      callAnswered?()
   }
   
   @IBAction func endCallButtonPressed(_ sender: UIButton) {
      sender.isEnabled = false
      callHungUp?()
      removeWith(delay: 0.3)
   }
   
   @IBAction func muteAudioButtonPressed(_ sender: UIButton) {
      let isMuted = sender.isSelected
      sender.isEnabled = false

      if isMuted {
         unMuteAudioButtonPressed?()
      } else {
         muteAudioButtonPressed?()
      }
      
   }
   
   @IBAction func pauseVideoButtonPressed(_ sender: UIButton) {
      let isVideoPaused = sender.isSelected
      sender.isEnabled = false
      
      guard let wasOperationSuccessful = isVideoPaused ? startVideoButtonPressed?() : pauseVideoButtonPressed?(), wasOperationSuccessful else {
         sender.isEnabled = true
         return
      }
      
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
        sender.isSelected = !sender.isSelected
        sender.isEnabled = true
    })
   }
   
   @IBAction func switchCameraButton(_ sender: UIButton) {
      sender.isEnabled = false
      
      guard let wasSwitched = switchCameraButtonPressed?(), wasSwitched else {
         sender.isEnabled = true
         return
      }
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
        sender.isSelected = !sender.isSelected
        sender.isEnabled = true
    })
   }
   
   @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
      guard !isViewMinimized else {
         maximizeScreen()
         return
      }
      
      guard canSwitchToFullScreen else {
         return
      }
      
      if isFullScreen {
         setUIWhenCallConnected()
         bottomDistanceOfLocalVideoView.constant = 100
      } else {
         hideEverythingExceptVideoViews()
         bottomDistanceOfLocalVideoView.constant = 20
      }
      
      isFullScreen = !isFullScreen
   }
   
   @IBAction func localVideoViewTapped(_ sender: Any) {
      isLocalAndRemoteViewSwitched = !isLocalAndRemoteViewSwitched
      switchRemoteAndLocalVideoViewButtonPressed?()
   }
   
   @IBAction func backButtonPressed(_ sender: UIButton) {
      guard !isViewMinimized else {
         return
      }
      
      minimizeScreen()
   }
   
   
   // MARK: - Methods
   fileprivate func hideEverythingExceptVideoViews() {
      backButton.isHidden = true
      viewBehindBackButton.isHidden = true
      userImageView.isHidden = true
      statusLabel.isHidden = true
      peerNameLabel.isHidden = true
      startCallButton.isHidden = true
      endIncomingCallButton.isHidden = true
      muteCallButton.isHidden = true
      switchCameraButton.isHidden = true
      pauseVideoButton.isHidden = true
      endCallOutgoingOrConnected.isHidden = true
      pulseView.isHidden = true
      pulseLayer.stop()
   }
   
   fileprivate func setUIForIncomingCall() {
      showIncomingUI()
      setDataInIncomingCallUI()
   }
   
   fileprivate func showIncomingUI() {
      userImageView.isHidden = false
      peerNameLabel.isHidden = false
      startCallButton.isHidden = false
      endIncomingCallButton.isHidden = false
      statusLabel.isHidden = false
      
      statusLabel.text = "Incoming Call"
      addPulseAroundUserImage()
   }
   
   fileprivate func setDataInIncomingCallUI() {
    // Set Image in userImageView for string peer.image
      peerNameLabel.text = peer?.name
   }
   
   fileprivate func setUIWhenCallConnected() {
      muteCallButton.isHidden = false
      pauseVideoButton.isHidden = false
      endCallOutgoingOrConnected.isHidden = false
      switchCameraButton.isHidden = false
      backButton.isHidden = false
      viewBehindBackButton.isHidden = false
   }
    fileprivate func setUIForConnectingCall() {
        muteCallButton.isHidden = false
        pauseVideoButton.isHidden = false
        endCallOutgoingOrConnected.isHidden = false
        switchCameraButton.isHidden = false
        statusLabel.isHidden = false
        userImageView.isHidden = false
        peerNameLabel.isHidden = false
        
         // Set Image in userImageView for string peer.image
        
        peerNameLabel.text = peer?.name
        
        statusLabel.text = "Connecting..."
        
        addPulseAroundUserImage()
    }
    
   fileprivate func setUIForOutgoinfCall() {
      muteCallButton.isHidden = false
      pauseVideoButton.isHidden = false
      endCallOutgoingOrConnected.isHidden = false
      switchCameraButton.isHidden = false
      statusLabel.isHidden = false
      userImageView.isHidden = false
      peerNameLabel.isHidden = false
      
    _ = URL(string: peer?.image ?? "")
     // Set Image in userImageView for string peer.image
      
      peerNameLabel.text = peer?.name
      
      statusLabel.text = "Ringing..."
      
      addPulseAroundUserImage()
   }
   
   func addPulseAroundUserImage() {
      pulseView.isHidden = false
      pulseLayer.backgroundColor = UIColor.blue.cgColor
      pulseLayer.position = CGPoint(x: 40, y: 40)
      pulseLayer.radius = 80
      pulseLayer.instanceCount = 3
      pulseLayer.fromValueForRadius = 0.5
      pulseView.layer.addSublayer(pulseLayer)
      pulseLayer.start()
   }
   
   fileprivate func minimizeScreen() {
      isViewMinimized = true
      
      hideEverythingExceptVideoViews()
      
      let x = UIScreen.main.bounds.width - 100
      let newFrame = CGRect(x: x, y: 60, width: 90, height: 90)
      
      
      heightWidthOfLocalVideoView.constant = 40
      bottomDistanceOfLocalVideoView.constant = -10
      sideDistanceOfLocalVideoView.constant = -10
      
      remoteVideoView.layer.cornerRadius = 45
      remoteVideoView.layer.masksToBounds = true
      localVideoView.layer.cornerRadius = 20
      localVideoView.layer.masksToBounds = true
      localVideoView.backgroundColor = .black
      
      UIView.animate(withDuration: 0.5, animations: {
         self.frame = newFrame
         self.layoutIfNeeded()
      }) { (_) in
         HippoDelay(0.1) { [weak self] in
            self?.frameOfRemoteVideoViewChanged?()
            self?.frameOfLocalVideoViewChanged?()
         }
      }
      
   }
   
   fileprivate func maximizeScreen() {
      isViewMinimized = false
      heightWidthOfLocalVideoView.constant = 100
      bottomDistanceOfLocalVideoView.constant = 100
      sideDistanceOfLocalVideoView.constant = 15
      
      remoteVideoView.layer.cornerRadius = 0
      remoteVideoView.layer.masksToBounds = false
      localVideoView.layer.cornerRadius = 0
      localVideoView.layer.masksToBounds = false
      localVideoView.backgroundColor = .clear
      
      UIView.animate(withDuration: 0.5, animations: {
         self.frame = UIApplication.shared.keyWindow!.bounds
         self.layoutIfNeeded()
      }) { (_) in
         self.setUIWhenCallConnected()

         HippoDelay(0.1) { [weak self] in
            self?.frameOfRemoteVideoViewChanged?()
            self?.frameOfLocalVideoViewChanged?()
         }
      }
      
   }
   
   // MARK: - Sound
   
    func playSound(soundName: String, numberOfLoops: Int) {
        guard let url =  Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            #if swift(>=4.0)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            #else
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            #endif
            
            guard let player = player else { return }
            
            if AVAudioSession.sharedInstance().outputVolume < 0.4 {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            player.numberOfLoops = numberOfLoops
            player.play()
            
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
   
   func stopPlaying() {
      player?.stop()
      player = nil
   }
   
   // MARK: - Type Methods
   static func loadVideoCallView() -> VideoCallView {
      let view = Bundle.main.loadNibNamed("VideoCallView", owner: nil, options: nil)?.first as! VideoCallView
      guard let keyWindow = UIApplication.shared.keyWindow else {
         return view
      }
      
      keyWindow.endEditing(true)
      view.frame = keyWindow.bounds
      keyWindow.addSubview(view)
      
      return view
   }
   
}

extension VideoCallView: CallPresenter {
    func startConnectingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        self.peer = request.peer
        setUIForConnectingCall()
//        playSound(soundName: "ringing", numberOfLoops: Int.max)
        completion(true)
    }
    
   
   func callMuted() {
      muteCallButton.isEnabled = true
      muteCallButton.isSelected = true
   }
   
   func callUnMuted() {
      muteCallButton.isEnabled = true
      muteCallButton.isSelected = false
   }
   
   func callConnected() {
      hideEverythingExceptVideoViews()
      setUIWhenCallConnected()
      stopPlaying()
      canSwitchToFullScreen = true
   }
   
   func remoteUserRejectedTheCall() {
      statusLabel.text = "Busy"
      removeWith(delay: 1)
   }
   
   func remoteUserHungUp() {
      statusLabel.text = ""
      removeWith(delay: 0.5)
   }
   
   func userBusy() {
      statusLabel.text = "Busy on another call"
      removeWith(delay: 3)
   }
   
   func reportIncomingCallWith(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
      self.peer = request.peer
      self.setUIForIncomingCall()
      playSound(soundName: "incoming_call", numberOfLoops: Int.max)
      completion(true)
   }
   
   func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
      self.peer = request.peer
      setUIForOutgoinfCall()
      playSound(soundName: "ringing", numberOfLoops: Int.max)
      completion(true)
   }
   
   func viewForLocalVideoRendering() -> UIView? {
      return isLocalAndRemoteViewSwitched ? remoteVideoView : localVideoView
   }
   
   func viewForRemoteVideoRendering() -> UIView? {
      return isLocalAndRemoteViewSwitched ? localVideoView : remoteVideoView

   }
   
   func removeWith(delay: Double) {
      playSound(soundName: "disconnect_call", numberOfLoops: 1)
      self.isUserInteractionEnabled = false
      UIApplication.shared.isIdleTimerDisabled = false
      
      HippoDelay(delay) {
         self.stopPlaying()
         try? AVAudioSession.sharedInstance().setActive(false)
         self.removeFromSuperview()
      }
   }
    func addLocalIncomingCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        let message = "🎥 Video Call from \(peerName)"
        let soundName = "incoming_call.mp3"
        
        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
    }
    
    func addLocalMissedCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        let message = "🎥 Missed a Video Call from \(peerName)"
        let soundName = "disconnect_call.mp3"
        
        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
    }
    private func addLocalNotificationWith(message: String, soundName: String, identifier: String) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.sound = UNNotificationSound(named: soundName)
            content.title = "Hippo Video Call"
            content.body = message
            content.subtitle = ""
            
            let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                if error != nil {
                    print(error.debugDescription)
                }
            }
            
        } else {
            let notification = UILocalNotification()
            notification.alertBody = message
            notification.alertTitle = "Hippo Video Call"
            notification.soundName = soundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}
#endif
