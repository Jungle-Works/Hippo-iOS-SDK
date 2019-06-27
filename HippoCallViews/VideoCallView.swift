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
//
//#if canImport(HippoCallClient)
//class VideoCallView: UIView {
//
//   // MARK: - Properties
//   var callAnswered: (() -> Void)?
//   var callHungUp: (() -> Void)?
//   var muteAudioButtonPressed: (() -> Void)?
//   var unMuteAudioButtonPressed: (() -> Void)?
//   var pauseVideoButtonPressed: (() -> Bool)?
//   var startVideoButtonPressed: (() -> Bool)?
//   var switchCameraButtonPressed: (() -> Bool)?
//   var switchRemoteAndLocalVideoViewButtonPressed: (() -> Void)?
//   var frameOfRemoteVideoViewChanged: (() -> Void)?
//   var frameOfLocalVideoViewChanged: (() -> Void)?
//
//   var configureAudioSession: (() -> Void)?
//   var audioSessionDeactivated: ((AVAudioSession) -> Void)?
//   var audioSessionActivated: ((AVAudioSession) -> Void)?
//   var publishData: ((CustomData) -> Void)?
//
//   var setAudioOutputToSpeaker: ((Bool, @escaping (Bool) -> Void) -> Void)?
//
//   fileprivate var peer: CallerInfo?
//   fileprivate var player: AVAudioPlayer?
//
//   fileprivate let pulseLayer = CallPulsator()
//
//   var isFullScreen = false
//   var canSwitchToFullScreen = false
//
//   var isLocalAndRemoteViewSwitched = false
//
//   var isViewMinimized = false
//
//   // MARK: - IBOutlets
//   @IBOutlet weak var remoteVideoView: UIImageView!
//   @IBOutlet weak var localVideoView: UIImageView!
//
//   @IBOutlet weak var userImageView: UIImageView!
//   @IBOutlet weak var statusLabel: UILabel!
//   @IBOutlet weak var peerNameLabel: UILabel!
//   @IBOutlet weak var startCallButton: UIButton!
//   @IBOutlet weak var endIncomingCallButton: UIButton!
//   @IBOutlet weak var endCallOutgoingOrConnected: UIButton!
//
//   @IBOutlet weak var bottomDistanceOfLocalVideoView: NSLayoutConstraint!
//   @IBOutlet weak var pulseView: UIView!
//
//   @IBOutlet weak var muteCallButton: UIButton!
//   @IBOutlet weak var switchCameraButton: UIButton!
//   @IBOutlet weak var pauseVideoButton: UIButton!
//
//   @IBOutlet weak var backButton: UIButton!
//   @IBOutlet weak var viewBehindBackButton: UIImageView!
//   @IBOutlet weak var heightWidthOfLocalVideoView: NSLayoutConstraint!
//   @IBOutlet weak var sideDistanceOfLocalVideoView: NSLayoutConstraint!
//   @IBOutlet weak var topDistanceOfBackButton: NSLayoutConstraint!
//
//   // MARK: - View Life Cycle
//   override func awakeFromNib() {
//      super.awakeFromNib()
//
//      hideEverythingExceptVideoViews()
//      UIApplication.shared.isIdleTimerDisabled = true
//
//      if UIView.safeAreaInsetsForAllOS.top == 0 {
//         topDistanceOfBackButton.constant = 20
//      }
//   }
//
//   // MARK: - IBAction
//   @IBAction func startCallButtonPressed(_ sender: UIButton) {
//      sender.isHidden = true
//      callAnswered?()
//   }
//
//   @IBAction func endCallButtonPressed(_ sender: UIButton) {
//      sender.isEnabled = false
//      callHungUp?()
//      removeWith(delay: 0.3)
//   }
//
//   @IBAction func muteAudioButtonPressed(_ sender: UIButton) {
////      let isMuted = sender.isSelected
////      sender.isEnabled = false
////
////      if isMuted {
////         unMuteAudioButtonPressed?()
////      } else {
////         muteAudioButtonPressed?()
////      }
//       let data = CustomData(uniqueId: "uniqueId xxxxxx", flag: "flag-1", message: "message")!
//       publishData?(data)
//   }
//
//   @IBAction func pauseVideoButtonPressed(_ sender: UIButton) {
//      let isVideoPaused = sender.isSelected
//      sender.isEnabled = false
//
//      guard let wasOperationSuccessful = isVideoPaused ? startVideoButtonPressed?() : pauseVideoButtonPressed?(), wasOperationSuccessful else {
//         sender.isEnabled = true
//         return
//      }
//
//    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
//        sender.isSelected = !sender.isSelected
//        sender.isEnabled = true
//    })
//   }
//
//   @IBAction func switchCameraButton(_ sender: UIButton) {
//      sender.isEnabled = false
//
//      guard let wasSwitched = switchCameraButtonPressed?(), wasSwitched else {
//         sender.isEnabled = true
//         return
//      }
//
//    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
//        sender.isSelected = !sender.isSelected
//        sender.isEnabled = true
//    })
//   }
//
//   @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
//      guard !isViewMinimized else {
//         maximizeScreen()
//         return
//      }
//
//      guard canSwitchToFullScreen else {
//         return
//      }
//
//      if isFullScreen {
//         setUIWhenCallConnected()
//         bottomDistanceOfLocalVideoView.constant = 100
//      } else {
//         hideEverythingExceptVideoViews()
//         bottomDistanceOfLocalVideoView.constant = 20
//      }
//
//      isFullScreen = !isFullScreen
//   }
//
//   @IBAction func localVideoViewTapped(_ sender: Any) {
//      isLocalAndRemoteViewSwitched = !isLocalAndRemoteViewSwitched
//      switchRemoteAndLocalVideoViewButtonPressed?()
//   }
//
//   @IBAction func backButtonPressed(_ sender: UIButton) {
//      guard !isViewMinimized else {
//         return
//      }
//
//      minimizeScreen()
//   }
//
//
//   // MARK: - Methods
//   fileprivate func hideEverythingExceptVideoViews() {
//      backButton.isHidden = true
//      viewBehindBackButton.isHidden = true
//      userImageView.isHidden = true
//      statusLabel.isHidden = true
//      peerNameLabel.isHidden = true
//      startCallButton.isHidden = true
//      endIncomingCallButton.isHidden = true
//      muteCallButton.isHidden = true
//      switchCameraButton.isHidden = true
//      pauseVideoButton.isHidden = true
//      endCallOutgoingOrConnected.isHidden = true
//      pulseView.isHidden = true
//      pulseLayer.stop()
//   }
//
//   fileprivate func setUIForIncomingCall() {
//      showIncomingUI()
//      setDataInIncomingCallUI()
//   }
//
//   fileprivate func showIncomingUI() {
//      userImageView.isHidden = false
//      peerNameLabel.isHidden = false
//      startCallButton.isHidden = false
//      endIncomingCallButton.isHidden = false
//      statusLabel.isHidden = false
//
//      statusLabel.text = "Incoming Call"
//      addPulseAroundUserImage()
//   }
//
//   fileprivate func setDataInIncomingCallUI() {
//    // Set Image in userImageView for string peer.image
//      peerNameLabel.text = peer?.name
//   }
//
//   fileprivate func setUIWhenCallConnected() {
//      muteCallButton.isHidden = false
//      pauseVideoButton.isHidden = false
//      endCallOutgoingOrConnected.isHidden = false
//      switchCameraButton.isHidden = false
//      backButton.isHidden = false
//      viewBehindBackButton.isHidden = false
//   }
//    fileprivate func setUIForConnectingCall() {
//        muteCallButton.isHidden = false
//        pauseVideoButton.isHidden = false
//        endCallOutgoingOrConnected.isHidden = false
//        switchCameraButton.isHidden = false
//        statusLabel.isHidden = false
//        userImageView.isHidden = false
//        peerNameLabel.isHidden = false
//
//        //TODO: Set Image in userImageView for string peer.image
//        peerNameLabel.text = peer?.name
//        statusLabel.text = "Connecting..."
//        addPulseAroundUserImage()
//    }
//
//   fileprivate func setUIForOutgoinfCall() {
//      muteCallButton.isHidden = false
//      pauseVideoButton.isHidden = false
//      endCallOutgoingOrConnected.isHidden = false
//      switchCameraButton.isHidden = false
//      statusLabel.isHidden = false
//      userImageView.isHidden = false
//      peerNameLabel.isHidden = false
//
//    _ = URL(string: peer?.image ?? "")
//     // Set Image in userImageView for string peer.image
//
//      peerNameLabel.text = peer?.name
//
//      statusLabel.text = "Ringing..."
//
//      addPulseAroundUserImage()
//   }
//
//   func addPulseAroundUserImage() {
//      pulseView.isHidden = false
//      pulseLayer.backgroundColor = UIColor.blue.cgColor
//      pulseLayer.position = CGPoint(x: 40, y: 40)
//      pulseLayer.radius = 80
//      pulseLayer.instanceCount = 3
//      pulseLayer.fromValueForRadius = 0.5
//      pulseView.layer.addSublayer(pulseLayer)
//      pulseLayer.start()
//   }
//
//   fileprivate func minimizeScreen() {
//      isViewMinimized = true
//
//      hideEverythingExceptVideoViews()
//
//      let x = UIScreen.main.bounds.width - 100
//      let newFrame = CGRect(x: x, y: 60, width: 90, height: 90)
//
//
//      heightWidthOfLocalVideoView.constant = 40
//      bottomDistanceOfLocalVideoView.constant = -10
//      sideDistanceOfLocalVideoView.constant = -10
//
//      remoteVideoView.layer.cornerRadius = 45
//      remoteVideoView.layer.masksToBounds = true
//      localVideoView.layer.cornerRadius = 20
//      localVideoView.layer.masksToBounds = true
//      localVideoView.backgroundColor = .black
//
//      UIView.animate(withDuration: 0.5, animations: {
//         self.frame = newFrame
//         self.layoutIfNeeded()
//      }) { (_) in
//         HippoDelay(0.1) { [weak self] in
//            self?.frameOfRemoteVideoViewChanged?()
//            self?.frameOfLocalVideoViewChanged?()
//         }
//      }
//
//   }
//
//   fileprivate func maximizeScreen() {
//      isViewMinimized = false
//      heightWidthOfLocalVideoView.constant = 100
//      bottomDistanceOfLocalVideoView.constant = 100
//      sideDistanceOfLocalVideoView.constant = 15
//
//      remoteVideoView.layer.cornerRadius = 0
//      remoteVideoView.layer.masksToBounds = false
//      localVideoView.layer.cornerRadius = 0
//      localVideoView.layer.masksToBounds = false
//      localVideoView.backgroundColor = .clear
//
//      UIView.animate(withDuration: 0.5, animations: {
//         self.frame = UIApplication.shared.keyWindow!.bounds
//         self.layoutIfNeeded()
//      }) { (_) in
//         self.setUIWhenCallConnected()
//
//         HippoDelay(0.1) { [weak self] in
//            self?.frameOfRemoteVideoViewChanged?()
//            self?.frameOfLocalVideoViewChanged?()
//         }
//      }
//
//   }
//
//   // MARK: - Sound
//
//    func playSound(soundName: String, numberOfLoops: Int) {
//        guard let url =  Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
//
//        do {
//            #if swift(>=5.0)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//            #elseif swift(>=4.2)
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowBluetooth)
//            #else
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            #endif
//
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            #if swift(>=4.0)
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//            #else
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//            #endif
//
//            guard let player = player else { return }
//
//            if AVAudioSession.sharedInstance().outputVolume < 0.4 {
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//            }
//
//            player.numberOfLoops = numberOfLoops
//            player.play()
//
//
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//
//   func stopPlaying() {
//      player?.stop()
//      player = nil
//   }
//
//   // MARK: - Type Methods
//   static func loadVideoCallView() -> VideoCallView {
//      let view = Bundle.main.loadNibNamed("VideoCallView", owner: nil, options: nil)?.first as! VideoCallView
//      guard let keyWindow = UIApplication.shared.keyWindow else {
//         return view
//      }
//
//      keyWindow.endEditing(true)
//      view.frame = keyWindow.bounds
//      keyWindow.addSubview(view)
//
//      return view
//   }
//
//}
//
//extension VideoCallView: CallPresenter {
//    func remoteRetryToConnect() {
//        let string = ""
//    }
//    func remoteConnected() {
//
//    }
//
//    func newDataRecieved(data: CustomData) {
//        Helper.showAlertWith(message: "\(data.getJson())", action: nil)
//        print("\(#function) ==== \(data)")
//    }
//    func startConnectingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
//        self.peer = request.peer
//        setUIForConnectingCall()
////        playSound(soundName: "ringing", numberOfLoops: Int.max)
//        completion(true)
//    }
//
//
//   func callMuted() {
//      muteCallButton.isEnabled = true
//      muteCallButton.isSelected = true
//   }
//
//   func callUnMuted() {
//      muteCallButton.isEnabled = true
//      muteCallButton.isSelected = false
//   }
//
//   func callConnected() {
//      hideEverythingExceptVideoViews()
//      setUIWhenCallConnected()
//      stopPlaying()
//      canSwitchToFullScreen = true
//   }
//
//   func remoteUserRejectedTheCall() {
//      statusLabel.text = "Busy"
//      removeWith(delay: 1)
//   }
//
//   func remoteUserHungUp() {
//      statusLabel.text = ""
//      removeWith(delay: 0.5)
//   }
//
//   func userBusy() {
//      statusLabel.text = "Busy on another call"
//      removeWith(delay: 3)
//   }
//
//   func reportIncomingCallWith(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
//      self.peer = request.peer
//      self.setUIForIncomingCall()
//      playSound(soundName: "incoming_call", numberOfLoops: Int.max)
//      completion(true)
//   }
//
//   func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
//      self.peer = request.peer
//      setUIForOutgoinfCall()
//      playSound(soundName: "ringing", numberOfLoops: Int.max)
//      completion(true)
//   }
//
//   func viewForLocalVideoRendering() -> UIView? {
//      return isLocalAndRemoteViewSwitched ? remoteVideoView : localVideoView
//   }
//
//   func viewForRemoteVideoRendering() -> UIView? {
//      return isLocalAndRemoteViewSwitched ? localVideoView : remoteVideoView
//
//   }
//
//   func removeWith(delay: Double) {
//      playSound(soundName: "disconnect_call", numberOfLoops: 1)
//      self.isUserInteractionEnabled = false
//      UIApplication.shared.isIdleTimerDisabled = false
//
//      HippoDelay(delay) {
//         self.stopPlaying()
//         try? AVAudioSession.sharedInstance().setActive(false)
//         self.removeFromSuperview()
//      }
//   }
//    func addLocalIncomingCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
//        guard UIApplication.shared.applicationState != .active else {
//            return
//        }
//        let message = "🎥 Video Call from \(peerName)"
//        let soundName = "incoming_call.mp3"
//
//        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
//    }
//
//    func addLocalMissedCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
//        guard UIApplication.shared.applicationState != .active else {
//            return
//        }
//        let message = "🎥 Missed a Video Call from \(peerName)"
//        let soundName = "disconnect_call.mp3"
//
//        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
//    }
//    private func addLocalNotificationWith(message: String, soundName: String, identifier: String) {
//        if #available(iOS 10.0, *) {
//            let content = UNMutableNotificationContent()
//            #if swift(>=5.0)
//            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
//            #elseif swift(>=4.2)
//            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
//            #else
//            notification.soundName = soundName
//            #endif
//
//            content.title = "Hippo Video Call"
//            content.body = message
//            content.subtitle = ""
//
//            let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
//
//            UNUserNotificationCenter.current().add(notificationRequest) { (error) in
//                if error != nil {
//                    print(error.debugDescription)
//                }
//            }
//
//        } else {
//            let notification = UILocalNotification()
//            notification.alertBody = message
//            notification.alertTitle = "Hippo Video Call"
//            notification.soundName = soundName
//            UIApplication.shared.scheduleLocalNotification(notification)
//        }
//    }
//}
//#endif
class VideoCallView: UIView {
    
    enum CallState {
        case incoming, outgoing, connected, disconnected
    }
    
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
    var publishData: ((CustomData) -> Void)?
    
    var configureAudioSession: (() -> Void)?
    var audioSessionDeactivated: ((AVAudioSession) -> Void)?
    var audioSessionActivated: ((AVAudioSession) -> Void)?
    
    var setAudioOutputToSpeaker: ((Bool, @escaping (Bool) -> Void) -> Void)?
    
    private var callType: Call.CallType!
    private var callUUID: String!
    private var peer: CallerInfo?
    private var player: AVAudioPlayer?
    
    private var callStatus: CallState!
    
    private let pulseLayer = Pulsator()
    
    var isFullScreen = false
    var canSwitchToFullScreen = false
    
    var isLocalAndRemoteViewSwitched = false
    var isOutgoingCall = false
    
    var isViewMinimized = false
    var isAudioMute = false
    var isSpeaker = true
    var isMarkAsSelected: Bool = true
    
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
    
    @IBOutlet weak var reconnetingView: UIView!
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
        
        if #available(iOS 11.0, *), isMultiAvailableInputs() {
            showAudioOutputsOption(with: isAudioMute, isSpeaker: isSpeaker, isBluetooth: !isSpeaker)
        }else {
            let isMuted = sender.isSelected
            sender.isEnabled = false
            
            if isMuted {
                unMuteAudioButtonPressed?()
            } else {
                muteAudioButtonPressed?()
            }
        }
    }
    
    
    @IBAction func pauseVideoButtonPressed(_ sender: UIButton) {
        let isVideoPaused = sender.isSelected
        sender.isEnabled = false
        
        guard let wasOperationSuccessful = isVideoPaused ? startVideoButtonPressed?() : pauseVideoButtonPressed?(), wasOperationSuccessful else {
            sender.isEnabled = true
            return
        }
        
        HippoDelay(0.5) {
            sender.isSelected = !sender.isSelected
            sender.isEnabled = true
        }
    }
    
    @IBAction func switchCameraButton(_ sender: UIButton) {
        sender.isEnabled = false
        
        guard let wasSwitched = switchCameraButtonPressed?(), wasSwitched else {
            sender.isEnabled = true
            return
        }
        HippoDelay(2) {
            sender.isEnabled = true
            sender.isSelected = !sender.isSelected
        }
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
    
//    @IBAction func switchToConference(_ sender: Any) {
//        let userView = AddOtherUserForConferenceCallView.loadView()
//        if let someWin = UIApplication.shared.keyWindow {
//            userView?.videoView = self
//            someWin.addSubview(userView!)
//            userView?.setup()
//        }
//    }
    
    // MARK: - Methods
    private func hideEverythingExceptVideoViews() {
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
    
    private func setUIForIncomingCall() {
        showIncomingUI()
        setDataInIncomingCallUI()
//        startPublishingLocalNotificationForIncomingCall()
    }
    
    private func showIncomingUI() {
        userImageView.isHidden = false
        peerNameLabel.isHidden = false
        startCallButton.isHidden = false
        endIncomingCallButton.isHidden = false
        statusLabel.isHidden = false
        statusLabel.text = "Incoming Call"
        addPulseAroundUserImage()
    }
    
    private func setDataInIncomingCallUI() {
        //TODO: Set image according to use
//        let peerImageUrl = URL(string: peer?.image ?? "")
//        userImageView.kf.setImage(with: peerImageUrl, placeholder: #imageLiteral(resourceName: "Image01"))
        peerNameLabel.text = peer?.name
    }
    
    private func setUIWhenCallConnected() {
        muteCallButton.isHidden = false
        pauseVideoButton.isHidden = false
        endCallOutgoingOrConnected.isHidden = false
        switchCameraButton.isHidden = false
        backButton.isHidden = false
        viewBehindBackButton.isHidden = false
        switchCameraButton.isHidden = false
    }
    
    private func setUIForOutgoinfCall() {
        muteCallButton.isHidden = false
        pauseVideoButton.isHidden = false
        endCallOutgoingOrConnected.isHidden = false
        switchCameraButton.isHidden = false
        statusLabel.isHidden = false
        userImageView.isHidden = false
        peerNameLabel.isHidden = false
        //TODO: Set image according to the use
//        let peerImageUrl = URL(string: peer?.image ?? "")
//        userImageView.kf.setImage(with: peerImageUrl, placeholder: #imageLiteral(resourceName: "userImagePlaceholder"))
        
        peerNameLabel.text = peer?.name
        
        statusLabel.text = "Ringing..."
        
        addPulseAroundUserImage()
    }
    fileprivate func setUIForConnectingCall() {
        setUIForOutgoinfCall()
        statusLabel.text = "Connecting..."
    }
    
    private func startPublishingLocalNotificationForIncomingCall() {
        guard callStatus == .incoming else {
            return
        }
        
        let callTypeInMessage: String
        let title: String
        
        switch callType! {
        case .audio:
            callTypeInMessage = "Voice"
            title = "HippoVoice Call"
        case .video:
            callTypeInMessage = "🎥 Video"
            title = "HippoVideo Call"
        }
        
        let message = "\(callTypeInMessage) Call from \(peer?.name ?? "")"
        let soundName = "incoming_call.mp3"
        addLocalNotificationWith(message: message, title: title, soundName: soundName, identifier: callUUID)
        if player == nil {
            playSound(soundName: "incoming_call", numberOfLoops: 1)
        }
    }
    
    private func addLocalNotificationWith(message: String, title: String, soundName: String, identifier: String) {
        let content = UNMutableNotificationContent()
        // content.sound = UNNotificationSound(named: soundName)
        content.title = title
        content.body = message
        content.subtitle = ""
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if error != nil {
                print(error.debugDescription)
            }
        }
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
    
    private func shouldPostMissedCallNotification() -> Bool {
        return !isOutgoingCall && callStatus == .disconnected
    }
    
    private func postMissedCallNotification() {
        let message: String
        let title: String
        
        switch callType! {
        case .video:
            message = "🎥 Missed a Video Call from \(peer?.name ?? "")"
            title = "HippoVideo Call"
        case .audio:
            message = "Missed a Voice Call from \(peer?.name ?? "")"
            title = "HippoVoice Call"
        }
        let soundName = "disconnect_call.mp3"
        player?.stop()
        player = nil
        addLocalNotificationWith(message: message, title: title, soundName: soundName, identifier: callUUID)
    }
    
    private func minimizeScreen() {
        isViewMinimized = true
        
        hideEverythingExceptVideoViews()
        
        
        let x = UIScreen.main.bounds.width - 100
        let newFrame = CGRect(x: x, y: 60, width: 90, height: 90)
        
        
        heightWidthOfLocalVideoView.constant = 40
        bottomDistanceOfLocalVideoView.constant = -10
        sideDistanceOfLocalVideoView.constant = -10
        
        reconnetingView.layer.cornerRadius = 45
        reconnetingView.layer.masksToBounds = true
        
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
    
    private func maximizeScreen() {
        isViewMinimized = false
        heightWidthOfLocalVideoView.constant = 100
        bottomDistanceOfLocalVideoView.constant = 100
        sideDistanceOfLocalVideoView.constant = 15
        
        reconnetingView.layer.cornerRadius = 0
        reconnetingView.layer.masksToBounds = false
        
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
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            #if swift(>=4.2)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth,.allowBluetoothA2DP,.mixWithOthers,.allowAirPlay,.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            #else
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetooth,.allowBluetoothA2DP,.mixWithOthers,.allowAirPlay,.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            #endif
            
            if #available(iOS 11.0, *) {
                self.initialSetup()
            }
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
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
        let nib = Bundle.main.loadNibNamed("VideoCallView", owner: nil, options: nil)!
        var view: VideoCallView!
        for each in nib {
            if let parsedView = each as? VideoCallView {
                view = parsedView
                break
            }
        }
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
    
    func addLocalIncomingCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        guard UIApplication.shared.applicationState != .active else {
            return
        }
        startPublishingLocalNotificationForIncomingCall()
    }
    
    func addLocalMissedCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        postMissedCallNotification()
    }
    
    func newDataRecieved(data: CustomData) {
        
    }
    
    func offerRecieved() {
        
    }
    
    
    func callMuted() {
        muteCallButton.isEnabled = true
        if isMarkAsSelected {
            muteCallButton.isSelected = true
        }
        isMarkAsSelected = true
    }
    
    func callUnMuted() {
        muteCallButton.isEnabled = true
        if isMarkAsSelected{
            muteCallButton.isSelected = false
        }
        isMarkAsSelected = true
    }
    
    func callConnected() {
        
        let manger = PermissionManager(with: .both, call: .in)
        let response = manger.checkPermission()
        if response.isDenied {
            manger.showSettingAlert(for: response)
            let sender = UIButton()
            sender.tag = 11
            endCallButtonPressed(sender)
        }else {
            hideEverythingExceptVideoViews()
            setUIWhenCallConnected()
            stopPlaying()
            canSwitchToFullScreen = true
            callStatus = .connected
            if #available(iOS 11.0, *) {
                setHeadPhone()
            }
        }
    }
    
    func remoteUserRejectedTheCall() {
        callStatus = .disconnected
        statusLabel.text = "Busy"
        removeWith(delay: 1, name: "call_busy")
    }
    
    func remoteUserHungUp() {
        callStatus = .disconnected
        remoteConnected()
        statusLabel.text = ""
        removeWith(delay: 0.5)
    }
    
    func remoteRetryToConnect() {
        DispatchQueue.main.async {
            self.reconnetingView.isHidden = false
        }
    }
    
    func remoteConnected() {
        DispatchQueue.main.async {
            self.reconnetingView.isHidden = true
        }
    }
    
    func hungupSignalAkcRecieved() {
        
    }
    
    func userBusy() {
        callStatus = .disconnected
        statusLabel.text = "Busy on another call"
        removeWith(delay: 3, name: "call_busy")
    }
    
    func reportIncomingCallWith(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        callStatus = .incoming
        peer = request.peer
        callType = request.callType
        callUUID = request.callUuid
        setUIForIncomingCall()
        
        playSound(soundName: "incoming_call", numberOfLoops: Int.max)
        completion(true)
    }
    
    func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        isOutgoingCall = true
        callStatus = .outgoing
        self.peer = request.peer
        self.callType = request.callType
        self.callUUID = request.callUuid
        setUIForOutgoinfCall()
        playSound(soundName: "ringing", numberOfLoops: Int.max)
        completion(true)
    }
    
    func viewForLocalVideoRendering() -> UIView? {
        if callType == .audio {
            return nil
        }
        return isLocalAndRemoteViewSwitched ? remoteVideoView : localVideoView
    }
    
    func viewForRemoteVideoRendering() -> UIView? {
        if callType == .audio {
            return nil
        }
        return isLocalAndRemoteViewSwitched ? localVideoView : remoteVideoView
        
    }
    
    func removeWith(delay: Double , name: String = "disconnect_call" ) {
        playSound(soundName:name , numberOfLoops: 1)
        self.isUserInteractionEnabled = false
        UIApplication.shared.isIdleTimerDisabled = false
        
        HippoDelay(delay) {
            self.stopPlaying()
            try? AVAudioSession.sharedInstance().setActive(false)
            self.removeFromSuperview()
        }
    }
}

@available(iOS 11.0, *)
extension VideoCallView {
    
    func initialSetup() {
        if isBluetoothHeadphone() {
            isAudioMute = false
            setIcon(with: true)
        }
    }
    
    func setIcon(with  mark: Bool) {
        var image: UIImage?
        if mark{
            isSpeaker = false
            image = UIImage(named: "bgBluetooth")
        }else {
            isSpeaker = true
            image = UIImage(named: "bgSpeaker")
        }
        muteCallButton.setImage(image, for: .normal)
    }
    
    
    func showAudioOutputsOption(with isMute: Bool, isSpeaker: Bool, isBluetooth: Bool) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let speaker = UIAlertAction(title: "Speaker", style: .default) { (action) in
            self.setSpeaker()
        }
        
        let speakerImage = UIImage(named: "smallSpeaker")
        speaker.setValue(speakerImage, forKey: "image")
        speaker.setValue(isSpeaker, forKey: "checked")
        alertController.addAction(speaker)
        
        if isBluetoothHeadphone() {
            let name  = getNameOfBlusetoothDevice()
            let bluetooth = UIAlertAction(title: name, style: .default) { (action) in
                self.setHeadPhone()
            }
            let smallBluetoothImage = UIImage(named: "smallBluetoothSpeaker")
            bluetooth.setValue(smallBluetoothImage, forKey: "image")
            bluetooth.setValue(isBluetooth, forKey: "checked")
            alertController.addAction(bluetooth)
        }
        
        let mute = UIAlertAction(title: "Mute", style: .default) { (action) in
            self.muteActionTaken()
        }
        
        let muteImage = UIImage(named: "smallMute")
        mute.setValue(muteImage, forKey: "image")
        mute.setValue(isMute, forKey: "checked")
        
        
        alertController.addAction(mute)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // show alert
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        #if swift(>=4.2)
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        #else
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        #endif
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func muteActionTaken() {
        self.isAudioMute = !self.isAudioMute
        let isMuted = muteCallButton.isSelected
        muteCallButton.isEnabled = false
        isMarkAsSelected = false
        if isMuted {
            unMuteAudioButtonPressed?()
        } else {
            muteAudioButtonPressed?()
        }
    }
    
    
    func  isBluetoothHeadphone()->Bool {
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        if let someInputs = availableInputs {
            #if swift(>=4.2)
            let head = someInputs.first(where: {$0.portType == AVAudioSession.Port.bluetoothHFP})
            #else
            let head = someInputs.first(where: {$0.portType == AVAudioSessionPortBluetoothHFP})
            #endif
            if head !=  nil {
                return true
            }
            return false
        }else {
            return false
        }
    }
    
    func getNameOfBlusetoothDevice() -> String  {
        
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        if let someInputs = availableInputs {
            #if swift(>=4.2)
            let head = someInputs.first(where: {$0.portType == AVAudioSession.Port.bluetoothHFP})
            #else
            let head = someInputs.first(where: {$0.portType == AVAudioSessionPortBluetoothHFP})
            #endif
            
            if head !=  nil {
                return head!.portName
            }
            return "HeadPhone"
        }else {
            return "HeadPhone"
        }
    }
    
    func isMultiAvailableInputs()-> Bool {
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        if let some = availableInputs, some.count > 1 {
            return true
        }
        return false
    }
    
    func setHeadPhone() {
        #if swift(>=4.2)
        let head = AVAudioSession.sharedInstance().availableInputs?.first(where: {$0.portType == AVAudioSession.Port.bluetoothHFP})
        #else
        let head = AVAudioSession.sharedInstance().availableInputs.first(where: {$0.portType == AVAudioSessionPortBluetoothHFP})
        #endif
        if let someHead = head  {
            isSpeaker = false
            do {
                try AVAudioSession.sharedInstance().setPreferredInput(someHead)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                setIcon(with: true)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func setSpeaker() {
        isSpeaker = true
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            setIcon(with: false)
        }catch let error{
            isSpeaker = false
            setIcon(with: true)
            print(error.localizedDescription)
        }
    }
}
