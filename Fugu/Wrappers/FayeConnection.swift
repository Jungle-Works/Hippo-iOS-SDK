//
//  FayeConnection.swift
//  Fugu
//
//  Created by Gagandeep Arora on 21/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import MZFayeClient

class FayeConnection: NSObject {
   
   // MARK: - Type Properties
   static let shared = FayeConnection()
   static let channelPrefix = "/"
   static let channelUnsubscribeNotification: Notification.Name = {
      let channelUnSubscribeNotification = Notification.Name("ChannelUnsubscribed")
      return channelUnSubscribeNotification
   }()
   
   // MARK: - Properties
   fileprivate var localFaye: MZFayeClient! = MZFayeClient(url: URL(string: HippoConfig.shared.fayeBaseURLString))
   fileprivate var retryTimer: Timer?
   fileprivate let retryTime: TimeInterval = 3
   
   // MARK: - Computed Properties
   fileprivate var subscribedChannels: [String] {
      if let openSubscriptions = localFaye!.openSubscriptions {
         return openSubscriptions.map { return "\($0)" }
      }
      return []
   }
   var isConnected: Bool {
      return localFaye.isConnected && isWebSocketConnected
   }
   
   private var isWebSocketConnected: Bool {
      if let webSocket = localFaye.webSocket {
         return webSocket.readyState == .OPEN
      }
      return false
   }
   
   // MARK: - Intialization
   fileprivate override init() {
      super.init()
      setConnectionRetryAttemptConfig()
      setupFayeClient()
   }
   
   private func setConnectionRetryAttemptConfig() {
      localFaye.shouldRetryConnection = false
      localFaye.retryAttempt = 0
      localFaye.retryInterval = 0
      localFaye.maximumRetryAttempts = 0
   }
   
   // MARK: - Methods
    func enviromentSwitchedWith(urlString: String) {
        localFaye = MZFayeClient(url: URL(string: urlString))
        setConnectionRetryAttemptConfig()
        setupFayeClient()
    }
   
   @objc fileprivate func setupFayeClient() {
      
      
      localFaye?.delegate = self
      let webSocketState = localFaye?.webSocket?.readyState ?? .CLOSED
      
      if webSocketState != .CONNECTING && webSocketState != .OPEN {
         localFaye?.connect({}, failure: {_ in })
      }
      
      if isConnected {
         stopRetryTimer()
      }
   }
   
   
   func isChannelSubscribed(channelID: String) -> Bool {
      guard !channelID.isEmpty else {
         return false
      }
      
      var channelIdForValidation = channelID
      validate(channelID: &channelIdForValidation)
      
      return subscribedChannels.contains(channelIdForValidation)
   }
   
   func subscribeTo(channelId: String, completion: ((_ connected: Bool) -> Void)? = nil, messageReceived: (([String: Any]) -> Void)? = nil) {
      
      var channelIdForValidation = channelId
      validate(channelID: &channelIdForValidation)
      
      guard isConnected else {
         completion?(false)
         return
      }
      
      guard isChannelSubscribed(channelID: channelIdForValidation) == false else {
         completion?(true)
         return
      }
      
      localFaye?.subscribe(toChannel: channelIdForValidation, success: {
         completion?(true)
      }, failure: { (error) in
         completion?(false)
         print("error==>\(error?.localizedDescription ?? "")")
      }, receivedMessage: { (messageInfo) in
         if let messageDict = messageInfo as? [String: Any] {
            messageReceived?(messageDict)
         }
      })
   }
    
    func send(messageDict: [String: Any], toChannelID channelID: String, completion: @escaping (_ success: Bool) -> Void) {
      
      var channelIdForValidation = channelID
      validate(channelID: &channelIdForValidation)
      
      guard isConnected else {
         fuguDelay(5, completion: {
            completion(false)
         })
         startTimer()
         return
      }
      
        localFaye.sendMessage(messageDict, toChannel: channelIdForValidation, success: {
            completion(true)
        }) { (error) in
            print("Sending of message failed due to \(error?.localizedDescription ?? "")")
            completion(false)
        }
    }
   
    func unsubscribe(fromChannelId channelID: String, completion: ((Bool, Error?) -> Void)?) {
      var channelIdForValidation = channelID
      validate(channelID: &channelIdForValidation)
      
      localFaye?.unsubscribe(fromChannel: channelIdForValidation, success: {
        completion?(true, nil)
      }, failure: {error in
        completion?(false, error)
      })
   }
   
   // MARK: - Helpers
   
   private func validate(channelID: inout String) {
      if "\(channelID.first!)" != FayeConnection.channelPrefix {
         channelID = FayeConnection.channelPrefix + channelID
      }
   }
   
   
   
}

//MARK: - MZFayeClient Delegate

 extension FayeConnection: MZFayeClientDelegate {
    func fayeClient(_ client: MZFayeClient!, didConnectTo url: URL!) {
        print("didConnectTo==>\(url.absoluteString)")
      stopRetryTimer()
    }
    
    func fayeClient(_ client: MZFayeClient!, didDisconnectWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didDisconnectWithError==>\(errorMessage)")
      startTimer()
      
    }
    
    func fayeClient(_ client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
        print("didUnsubscribeFromChannel==>\(channel ?? "")")
    }
    
    func fayeClient(_ client: MZFayeClient!, didSubscribeToChannel channel: String!) {
        print("didSubscribeToChannel==>\(channel ?? "")")
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didFailWithError==>\(errorMessage)")
      startTimer()
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailDeserializeMessage message: [AnyHashable : Any]!, withError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didFailDeserializeMessage==>\(message ?? [:]) \n and error==>\(errorMessage)")
    }
    
    func fayeClient(_ client: MZFayeClient!, didReceiveMessage messageData: [AnyHashable : Any]!, fromChannel channel: String!) {
        print("didReceiveMessage==>\(messageData ?? [:])")
    }
   
   fileprivate func startTimer() {
      guard retryTimer == nil else {
         return
      }
      
      setupFayeClient()
      retryTimer = Timer.scheduledTimer(timeInterval: retryTime, target: self, selector: #selector(setupFayeClient), userInfo: nil, repeats: true)
   }
   
   fileprivate func stopRetryTimer() {
      retryTimer?.invalidate()
      retryTimer = nil
   }
}
