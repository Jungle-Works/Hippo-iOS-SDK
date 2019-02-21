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

#if canImport(HippoCallClient)
import HippoCallClient
#endif


#if canImport(HippoCallClient)
@available(iOS 10.0, *)
class AudioCallPresenter: NSObject, CallPresenter, CXProviderDelegate {
    
  static let shared = AudioCallPresenter()
   
   // MARK: - Properties
   private static var provider: CXProvider = {
      let nameOfApp = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
      let configuration = CXProviderConfiguration(localizedName: nameOfApp)
      configuration.maximumCallGroups = 1
      configuration.maximumCallsPerCallGroup = 1
    
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
      isDialedByUser = false

      self.peer = request.peer
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
         
         self?.loadInCallView()
         completion(true)
      }
   }
    func startConnectingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
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
    
   func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
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
   
   func callConnected() {
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
   }
   
   func remoteUserHungUp() {
      let reason = CXCallEndedReason.unanswered
      endCallWith(reason: reason)
   }
   
   func userBusy() {
      let reason = CXCallEndedReason.failed
      endCallWith(reason: reason)
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
    fileprivate func endCallWith(reason: CXCallEndedReason?, completion: (() -> Void)? = nil) {
      
      let endCallAction = CXEndCallAction(call: callUUID)
      let transaction = CXTransaction(action: endCallAction)
      
      callKitController.request(transaction) { [weak self] error in
         guard error == nil, let weakSelf = self else {
            NSLog("EndCallAction transaction request failed: \(error?.localizedDescription ?? "").")
            self?.resetData()
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
    fileprivate func resetData() {
        callUUID = nil
        isDialedByUser = nil
    }
   // MARK: - CXProviderDelegate
   func providerDidReset(_ provider: CXProvider) {
    
    }
   
   func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
      removeInCallView()
      action.fulfill()
      callHungUp?()
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
   func loadInCallView() {
      guard let keyWindow = UIApplication.shared.keyWindow else {
         return
      }
      
      inCallView = AudioCallView.get()
      inCallView?.frame = keyWindow.bounds
      inCallView?.delegate = self
      inCallView?.setUIWith(peer: self.peer!)
      keyWindow.addSubview(inCallView!)
   }
   
   func removeInCallView() {
      inCallView?.callDisconnected()
      inCallView?.removeFromSuperview()
      inCallView = nil
   }
   
   // MARK: - Deinitializer
   deinit {
      print("Audio Call presenter deintialized")
   }
}

// MARK: - AudioCallViewDelegate
@available(iOS 10.0, *)
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
   }
    func addLocalIncomingCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
//        let message = "Audio Call from \(peerName)"
//        let soundName = "incoming_call.mp3"
//
//        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
    }
    func addLocalMissedCallNotification(peerName: String, callType: Call.CallType, identifier: String) {
//        let message = "Missed a Audio Call from \(peerName)"
//        let soundName = "disconnect_call.mp3"
//
//        self.addLocalNotificationWith(message: message, soundName: soundName, identifier: identifier)
    }
    private func addLocalNotificationWith(message: String, soundName: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound(named: soundName)
        content.title = "Hippo Audio Call"
        content.body = message
        content.subtitle = ""
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
}

#endif
