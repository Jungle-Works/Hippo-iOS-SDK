//
//  AudioCallPresenter.swift
//  Hippo
//
//  Created by Asim on 17/10/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import Hippo
import UserNotifications
import os

#if canImport(HippoCallClient)
import HippoCallClient
#endif

class AudioCallPresenter: NSObject, CallPresenter, CXProviderDelegate {
    func startConnectingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "startNewOutgoingCall")
        }
        isDialedByUser = true
        self.peer = request.peer
        configureAudioSession?()
        
        self.loadInCallView()
        inCallView?.setUIForConnectingCall()
        completion(true)
    }
    
    func newDataRecieved(data: CustomData) {
        
    }
    
    var publishData: ((CustomData) -> Void)?
    
    
    
    static var shared = AudioCallPresenter()
    
    let notifiID = "b92fe9990692a1c62cc414a0"
    var count: Int = 0
    var isEndCall: Bool = false
    var timer: Timer?
    
    var player: AVAudioPlayer?
    
    // MARK: - Properties
    private static var provider: CXProvider = {
        let nameOfApp = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Fugu"
        let configuration = CXProviderConfiguration(localizedName: nameOfApp)
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.ringtoneSound = "incoming_call.mp3"
        let provider = CXProvider(configuration: configuration)
        return provider
    }()
    
    private var provider = AudioCallPresenter.provider
    private var callKitController = CXCallController()
    private var callUUID: UUID!
    private var isDialedByUser: Bool!
    private var inCallView: AudioCallView?
    private var peer: CallerInfo?
    
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
    private var presentingController: UIViewController?
    
    // MARK: - Intializer
    override init() {
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    func setWith(callUUID: UUID, isDialedByUser: Bool) {
        self.isDialedByUser = isDialedByUser
        self.callUUID = callUUID
    }
    
    
    // MARK: - Methods
    func reportIncomingCallWith(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "reportIncomingCallWith")
        }
        
        isDialedByUser = false
        
        self.peer = request.peer
        
        
        //Logger.shared.printVar(for: "Call")
        
        
        if PermissionManager.isShowLocalNotificationForAudioCall() {
            self.showLocalNotification()
            completion(false)
        }else{
            stopPlay()
            configureAudioSession?()
            let update = CXCallUpdate()
            update.hasVideo = false
            update.supportsDTMF = false
            update.supportsHolding = false
            update.supportsUngrouping = false
            update.supportsGrouping = false
            update.localizedCallerName = request.peer.name
            provider.reportNewIncomingCall(with: callUUID, update: update) { [weak self] (error) in
                guard error == nil else {
                    print("Call Kit Error in starting call -> \(error.debugDescription)")
                    completion(false)
                    return
                }
                
                self?.loadInCallView(with: 1.0)
                completion(true)
            }
        }
    }
    
    func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "startNewOutgoingCall")
        }
        isDialedByUser = true
        self.peer = request.peer
        configureAudioSession?()
        
        let handle = CXHandle(type: .generic, value: request.peer.name)
        let startCallAction = CXStartCallAction(call: callUUID, handle: handle)
        let transaction = CXTransaction(action: startCallAction)
        
        callKitController.request(transaction) { [weak self] (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(false)
                    return
                }
                
                self?.loadInCallView()
                self?.inCallView?.setUIForOutgoingCall()
                completion(true)
            }
        }
    }
    
    func offerRecieved() {
        self.inCallView?.setupRingingText()
    }
    
    func callConnected() {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "callConnected")
        }
        DispatchQueue.main.async {
            if self.isDialedByUser {
                self.provider.reportOutgoingCall(with: self.callUUID, connectedAt: nil)
            }
            self.inCallView?.callConnected()
        }
    }
    
    func remoteUserRejectedTheCall() {
        let reason = CXCallEndedReason.remoteEnded
        endCallWith(reason: reason)
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "remoteUserRejectedTheCall")
        }
    }
    func addLocalIncomingCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        //        let message = "Audio Call from \(peerName)"
        //        let soundName = "incoming_call.mp3"
        //
        //        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
    }
    func addLocalMissedCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
        postMissedCallNotification()
    }

    
    func remoteUserHungUp() {
        let reason = CXCallEndedReason.unanswered
        //os_log(.error, "OS_HIPPO" , reason)
        
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "remoteUserHungUp")
        }
        endCallWith(reason: reason)
//        if  !CallClient.shared.wasCallConnected {
//            postMissedCallNotification()
//        }
    }
    
    func remoteRetryToConnect() {
        if let someInCallView = inCallView {
            someInCallView.showReconnecting = true
        }
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "remoteRetryToConnect")
        }
    }
    
    func remoteConnected() {
        if let someInCallView = inCallView {
            someInCallView.showReconnecting = false
        }
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "remoteConnected")
        }
        
    }
    
    func hungupSignalAkcRecieved () {
        
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "hungupSignalAkcRecieved")
        }
        if let someInCallView = inCallView {
            someInCallView.isHidden = true
        }
//        CallClient.shared.isAlreadyHungupSent = true
        endCallWith(reason: nil)
    }
    
    func userBusy() {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "userBusy")
        }
        let reason = CXCallEndedReason.failed
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.inCallView?.timeLabel.text = "Busy on another call"
            self.inCallView?.playSound(soundName: "call_busy", numberOfLoops: 1)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.inCallView?.stopPlaying()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.endCallWith(reason: reason)
        }
    }
    
    func viewForLocalVideoRendering() -> UIView? {
        return nil
    }
    
    func viewForRemoteVideoRendering() -> UIView? {
        return nil
    }
    
    func callMuted() {
        inCallView?.audioMuted(true)
    }
    
    func callUnMuted() {
        inCallView?.audioMuted(false)
    }
    
    func sendHungupSiglan() {
        // CallClient.shared.isAlreadyHungupSent = true
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "sendHungupSiglan")
        }
        callHungUp?()
    }
    
    private func endCallWith(reason: CXCallEndedReason?, completion: (() -> Void)? = nil) {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "endCallWith")
        }
        
        guard callUUID != nil else {
            self.resetData()
            self.removeViewOnFailRequest()
            completion?()
            return
        }
        
        let endCallAction = CXEndCallAction(call: callUUID)
        let transaction = CXTransaction(action: endCallAction)
        
        callKitController.request(transaction) { [weak self] error in
            guard error == nil, let weakSelf = self else {
                NSLog("EndCallAction transaction request failed: \(error?.localizedDescription ?? "").")
                self?.resetData()
                self?.removeViewOnFailRequest()
                completion?()
                return
            }
            
            if reason != nil {
                weakSelf.provider.reportCall(with: weakSelf.callUUID, endedAt: nil, reason: reason!)
            }
            
            self?.resetData()
            completion?()
        }
    }
    
    private func resetData() {
        callUUID = nil
        isDialedByUser = nil
    }
    
    private func removeViewOnFailRequest() {
        DispatchQueue.main.async {
            self.removeInCallView()
            self.callHungUp?()
        }
       
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "removeViewOnFailRequest")
        }
//        if !CallClient.shared.isAlreadyHungupSent {
        
//        }
        
    }
    
    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {}
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        removeInCallView()
        action.fulfill()
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "perform action")
        }
//        if !CallClient.shared.isAlreadyHungupSent {
            callHungUp?()
//        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        callAnswered?()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        muteAudio(isMuted: action.isMuted)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        audioSessionDeactivated?(audioSession)
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        audioSessionActivated?(audioSession)
    }
    
    
    // MARK: - InCall View
    func loadInCallView(with delay: Double = 0.0) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        guard inCallView == nil else {
            return
        }
        
        inCallView = AudioCallView.get()
        inCallView?.frame = keyWindow.bounds
        inCallView?.delegate = self
        inCallView?.setUIWith(peer: self.peer!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: { [weak self] in
            if let someView = self?.inCallView {
                if #available(iOS 11.0, *) {
                    someView.setupNotifications()
                }
                
                self?.presentingController = UIViewController()
                self?.presentingController?.view.addSubview(someView)
                self?.presentingController?.modalPresentationStyle = .overCurrentContext
                
                
                if let callController = self?.presentingController {
                    let navVC = UINavigationController(rootViewController: callController)
                    navVC.isNavigationBarHidden = true
                    PermissionManager.getLastVisibleController()?.present(navVC, animated: false, completion: nil)
                }
            }
        })
    }
    
    func removeInCallView() {
        inCallView?.callDisconnected()
        presentingController?.dismiss(animated: false, completion: nil)
        if #available(iOS 11.0, *) {
            self.inCallView?.removeNotification()
        }
        self.inCallView?.removeFromSuperview()
        self.inCallView = nil
        
        presentingController = nil
    }
    
    // MARK: - Deinitializer
    deinit {
        print("Audio Call presenter deintialized")
    }
}

// MARK: - AudioCallViewDelegate
extension AudioCallPresenter: AudioCallViewDelegate {
    func muteAudio(isMuted: Bool) {
        if isMuted {
            muteAudioButtonPressed?()
        } else {
            unMuteAudioButtonPressed?()
        }
    }
    
    func switchToSpeaker(isSwitchedToSpeaker: Bool, completion: @escaping (Bool) -> Void) {
        setAudioOutputToSpeaker?(isSwitchedToSpeaker, { success in
            completion(success)
        })
    }
    
    func disconnectCallButtonPressed() {
        endCallWith(reason: nil)
        
//        sendHungupSiglan()
        //  endCallWith(reason: nil)
    }
    
    func pipMode(for mark:Bool) {
//        if mark {
//            presentingController?.dismiss(animated: false, completion: nil)
//        }else{
//            if let callController = presentingController {
//                let root =  UIApplication.shared.keyWindow?.rootViewController as? TabbedHomeViewController
//                if root != nil {
//                    root?.present(callController, animated: false, completion: nil)
//                }else {
//                    let lastViewController = UIApplication.shared.keyWindow?.visibleViewController
//                    if let someVC = lastViewController {
//                        someVC.present(callController, animated: false, completion: nil)
//                    }
//                }
//            }
//        }
    }
}


extension AudioCallPresenter {
    
    func showLocalNotification() {
        startPublishingLocalNotificationForIncomingCall(data: [:])
    }
    
    func sendLocalNotificationFor(data: [String : Any]) {
        
        let title = "☎️ voice call"
        let message = peer?.name ?? ""
        
        if count > 5 {
            timer?.invalidate()
            timer = nil
            postMissedCallNotification()
        } else {//"incoming_call.mp3"
            addLocalNotificationWith(message: message, title: title, soundName: nil, identifier: notifiID, userInfo: data  )
            count += 1
        }
        
        if player == nil {
            playSound(soundName: "incoming_call", numberOfLoops: Int.max)
        }
    }
    
    func startPublishingLocalNotificationForIncomingCall(data: [String : Any]) {
        if !isEndCall {
            isEndCall = true
            sendLocalNotificationFor(data: data)
            timer =  Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
                self.sendLocalNotificationFor(data: data)
            })
        }
    }
    
    func addLocalNotificationWith(message: String, title: String, soundName: String?, identifier: String , userInfo: [String : Any]) {
        let content = UNMutableNotificationContent()
        if let someSound = soundName {
            #if swift(>=4.2)
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: someSound))
            #else
            content.sound = UNNotificationSound(named: someSound)
            #endif
        }
        content.title = title
        content.body = message
        content.subtitle = ""
        content.userInfo = userInfo
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
    func clearPreviousNotification(for id: String) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [id])
        //  center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func postMissedCallNotification() {
        let message: String
        let title: String
        title = "☎️ Missed a voice call"
        message  = peer?.name ?? ""
        let soundName = "disconnect_call.mp3"
        DispatchQueue.main.async {
            self.stopPlay()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.addLocalNotificationWith(message: message, title: title, soundName: soundName, identifier: self.notifiID, userInfo: [String : Any]())
        })
    }
    
    func playSound(soundName: String, numberOfLoops: Int) {
        
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        
        do {
            #if swift(>=4.2)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.allowBluetooth,.allowBluetoothA2DP,.mixWithOthers,.allowAirPlay,.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            #else
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetooth,.allowBluetoothA2DP,.mixWithOthers,.allowAirPlay,.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
            #endif
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path), fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.numberOfLoops = numberOfLoops
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopPlay() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
        isEndCall = false
        count = 0
    }
    
    func endNotification() {
        stopPlay()
    }
}

