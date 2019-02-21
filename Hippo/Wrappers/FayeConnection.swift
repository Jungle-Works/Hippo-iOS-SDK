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
    //   fileprivate var retryTimer: Timer?
    //   fileprivate let retryTime: TimeInterval = 3
    
    // MARK: - Computed Properties
    fileprivate var subscribedChannels: [String] {
        if let openSubscriptions = localFaye?.subscriptions {
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
        //      NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: .internetDisconnected, object: nil)
    }
    
    private func setConnectionRetryAttemptConfig() {
        localFaye.shouldRetryConnection = true
        localFaye.retryAttempt = 0
        localFaye.retryInterval = 2
        localFaye.maximumRetryAttempts = Int.max
    }
    
    @objc fileprivate func setupFayeClient() {
        
        localFaye?.delegate = self
        let webSocketState = localFaye?.webSocket?.readyState ?? .CLOSED
        
        if webSocketState != .CONNECTING && webSocketState != .OPEN {
            localFaye?.connect({}, failure: {_ in })
        }
        
        //      if isConnected {
        //         stopRetryTimer()
        //      }
    }
    
    // MARK: - Methods
    func enviromentSwitchedWith(urlString: String) {
        localFaye = MZFayeClient(url: URL(string: urlString))
        setConnectionRetryAttemptConfig()
        setupFayeClient()
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
    
    func send(messageDict: [String: Any], toChannelID channelID: String, completion: @escaping (FayeResult) -> Void) {
        
        var channelIdForValidation = channelID
        validate(channelID: &channelIdForValidation)
        
        guard isConnected else {
            completion((false, FayeError.fayeNotConnected ))
            //         startTimer()
            return
        }
        
        // if channel is not subscribed MZFayeClient does not give callback
        if !isChannelSubscribed(channelID: channelIdForValidation) {
            //TODO: Send notifications typing read all, etc. without subscription check
            completion((false, .channelNotSubscribed))
            return
        }
//        print("++++++++\(messageDict)")
        var temp = messageDict
        temp["user_id"] = 53014
        localFaye.sendMessage(messageDict, toChannel: channelIdForValidation, success: {
            completion((true, nil))
        }) { (error) in
            guard let objcError = error as NSError?, let reasonInfo = objcError.userInfo[NSLocalizedFailureReasonErrorKey] as? [String: Any] else {
                completion((false, FayeError.fayeNotConnected))
                return
            }
            print("Sending of message failed due to \(error?.localizedDescription ?? "")")
            let failureReason = FayeError(reasonInfo: reasonInfo) ?? .fayeNotConnected
            completion((false, failureReason))
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
        NotificationCenter.default.post(name: .fayeConnected, object: nil)
        //      stopRetryTimer()
    }
    
    func fayeClient(_ client: MZFayeClient!, didDisconnectWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didDisconnectWithError==>\(errorMessage)")
        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
        //      startTimer()
        
    }
    
    func fayeClient(_ client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
        print("didUnsubscribeFromChannel==>\(channel ?? "")")
    }
    
    func fayeClient(_ client: MZFayeClient!, didSubscribeToChannel channel: String!) {
        print("didSubscribeToChannel==>\(channel ?? "")")
        NotificationCenter.default.post(name: .channelSubscribed, object: nil)
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didFailWithError==>\(errorMessage)")
        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
        //      startTimer()
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailDeserializeMessage message: [AnyHashable : Any]!, withError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        print("didFailDeserializeMessage==>\(message ?? [:]) \n and error==>\(errorMessage)")
    }
    
    func fayeClient(_ client: MZFayeClient!, didReceiveMessage messageData: [AnyHashable : Any]!, fromChannel channel: String!) {
        //        print("didReceiveMessage==>\(messageData ?? [:])")
    }
    
    //   @objc fileprivate func startTimer() {
    //      guard retryTimer == nil || retryTimer?.isValid == false else {
    //         return
    //      }
    //
    //      setupFayeClient()
    //      stopRetryTimer()
    //      DispatchQueue.main.async {
    //         self.retryTimer = Timer.scheduledTimer(timeInterval: self.retryTime, target: self, selector: #selector(self.setupFayeClient), userInfo: nil, repeats: true)
    //
    //      }
    //   }
    //
    //   fileprivate func stopRetryTimer() {
    //      retryTimer?.invalidate()
    //      retryTimer = nil
    //   }
}

extension FayeConnection {
    enum FayeError: Int, Error {
        case fayeNotConnected = 400
        case userBlocked = 401
        case channelDoesNotExist = 407
        case invalidThreadMuid = 408
        case userDoesNotBelongToChannel = 409
        case messageDeleted = 410
        case invalidMuid = 411
        case duplicateMuid = 412
        case channelNotSubscribed = 4000
        
        init?(reasonInfo: [String: Any]) {
            guard let statusCode = reasonInfo["statusCode"] as? Int else {
                return nil
            }
            
            guard let reason = FayeError(rawValue: statusCode) else {
                return nil
            }
            self = reason
        }
    }
    
    typealias FayeResult = (success: Bool, error: FayeError?)
}

extension Notification.Name {
    public static var fayeConnected = Notification.Name.init("fayeConnected")
    public static var fayeDisconnected = Notification.Name.init("fayeDisconnected")
    public static var channelSubscribed = Notification.Name.init("channelSubscribed")
}
