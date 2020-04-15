//
//  FayeConnection.swift
//  Fugu
//
//  Created by Gagandeep Arora on 21/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

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
            HippoConfig.shared.log.debug("error==>\(error?.localizedDescription ?? "")", level: .info)
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
            completion((false, FayeResponseError.fayeNotConnected() ))
            //         startTimer()
            return
        }
        
        // if channel is not subscribed MZFayeClient does not give callback
        if !isChannelSubscribed(channelID: channelIdForValidation) {
            //TODO: Send notifications typing read all, etc. without subscription check
            completion((false, FayeResponseError.channelNotSubscribed()))
            return
        }
        localFaye.sendMessage(messageDict, toChannel: channelIdForValidation, success: {
            completion((true, nil))
        }) { (error) in
             print("localFaye.sendMessage*****:", error)
            guard let objcError = error as NSError?, let reasonInfo = objcError.userInfo[NSLocalizedFailureReasonErrorKey] as? [String: Any] else {
                completion((false, FayeResponseError.fayeNotConnected()))
                return
            }
            let message = "Sending of message failed due to \(error?.localizedDescription ?? "")"
            HippoConfig.shared.log.debug(message, level: .error)
            let reason = FayeResponseError(reasonInfo: reasonInfo)
            completion((false, reason))
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
        HippoConfig.shared.log.debug("didConnectTo==>\(url.absoluteString)", level: .info)
        NotificationCenter.default.post(name: .fayeConnected, object: nil)
    }
    
    func fayeClient(_ client: MZFayeClient!, didDisconnectWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        HippoConfig.shared.log.debug("didDisconnectWithError==>\(errorMessage)", level: .info)
        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
    }
    
    func fayeClient(_ client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
        HippoConfig.shared.log.debug("didUnsubscribeFromChannel==>\(channel ?? "")", level: .info)
    }
    
    func fayeClient(_ client: MZFayeClient!, didSubscribeToChannel channel: String!) {
        HippoConfig.shared.log.debug("didSubscribeToChannel==>\(channel ?? "")", level: .info)
        NotificationCenter.default.post(name: .channelSubscribed, object: nil)
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailWithError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        HippoConfig.shared.log.debug("didFailWithError==>\(errorMessage)", level: .info)
        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
    }
    
    func fayeClient(_ client: MZFayeClient!, didFailDeserializeMessage message: [AnyHashable : Any]!, withError error: Error!) {
        let errorMessage = error?.localizedDescription ?? ""
        HippoConfig.shared.log.debug("didFailDeserializeMessage==>\(message ?? [:]) \n and error==>\(errorMessage)", level: .info)
    }
    
    func fayeClient(_ client: MZFayeClient!, didReceiveMessage messageData: [AnyHashable : Any]!, fromChannel channel: String!) {
    }
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
        case invalidSending = 413
        case channelNotSubscribed = 4000
        case resendSameMessage = 420

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
    struct FayeResponseError {
        var message: String?
        var error: FayeError?
        var showError: Bool = false
        
        init(reasonInfo: [String: Any]) {
            error =  FayeError(reasonInfo: reasonInfo) ?? .fayeNotConnected
            message = reasonInfo["customMessage"] as? String
            if message == nil {
                message = reasonInfo["message"] as? String
            }
            showError = Bool.parse(key: "showError", json: reasonInfo, defaultValue: false)
        }
        
        static func fayeNotConnected() -> FayeResponseError {
            return FayeResponseError(reasonInfo: [:])
        }
        
        static func channelNotSubscribed() -> FayeResponseError {
            var response =  FayeResponseError(reasonInfo: [:])
            response.error = .channelNotSubscribed
            return response
        }
        
    }
    
    typealias FayeResult = (success: Bool, error: FayeResponseError?)
}

extension Notification.Name {
    public static var fayeConnected = Notification.Name.init("fayeConnected")
    public static var fayeDisconnected = Notification.Name.init("fayeDisconnected")
    public static var channelSubscribed = Notification.Name.init("channelSubscribed")
}
