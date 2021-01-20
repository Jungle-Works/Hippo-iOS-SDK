//
//  SocketClient.swift
//  Hippo
//
//  Created by Arohi Sharma on 21/10/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation
import SocketIO


class SocketClient: NSObject {
    
    // MARK: Properties
    static var shared = SocketClient()
    private var manager: SocketManager?
    var socket: SocketIOClient?
    let channelPrefix = "/"
    var subscribedChannel = [String : Bool]()
    //MARK:- Listeners
    
    private var onConnectCallBack : ((Array<Any>, SocketAckEmitter) -> ())!
    private var onDisconnectCallBack : ((Array<Any>, SocketAckEmitter) -> ())!
    private var handshakeListener : ((Array<Any>, SocketAckEmitter) -> ())!
    private var subscribeChannelListener : ((Array<Any>, SocketAckEmitter) -> ())!
    private var unsubscribeChannelListener : ((Array<Any>, SocketAckEmitter) -> ())!

    // MARK: Computed properties
    private var socketURL: String {
        get {
            return HippoConfig.shared.fayeBaseURLString
        }
    }
    
    // MARK: Init
    private override init() {
        super.init()
        addObserver()
        deinitializeListeners()
        manager = nil
        socket = nil
        socketSetup()
    }
    
    func connect(){
        SocketClient.shared = SocketClient()
    }
    
    func isConnected() -> Bool{
        SocketClient.shared.socket?.status == .connected
    }
    
    // MARK: Methods
    private func socketSetup(){
        if let url = URL(string: socketURL){
            manager = SocketManager(socketURL: url, config: [.reconnectWait(Int(2)), .reconnectAttempts(0), .compress, .forcePolling(false), .forceWebsockets(true)])
        }
        
        socket = manager?.defaultSocket
        initListeners()
        initInitializer()
        socket?.connect()
    }
    
    
    private func initListeners(){
        onConnectCallBack = {[weak self](arr, ack) in
            NotificationCenter.default.post(name: .socketConnected, object: nil)
            if let userChannelId = HippoUserDetail.HippoUserChannelId, currentUserType() == .customer, self?.isChannelSubscribed(channel: userChannelId) == false{
                SocketClient.shared.subscribeSocketChannel(channel: userChannelId)
            }else if let userChannelId = HippoConfig.shared.agentDetail?.userChannel, currentUserType() == .agent, self?.isChannelSubscribed(channel: userChannelId) == false{
                SocketClient.shared.subscribeSocketChannel(channel: userChannelId)
            }
            self?.handshake()
        }
        onDisconnectCallBack = {(arr, ack) in
            NotificationCenter.default.post(name: .socketDisconnected, object: nil)
        }
        handshakeListener = {(arr, ack) in
            
        }
        subscribeChannelListener = {(arr, ack) in
            NotificationCenter.default.post(name: .channelSubscribed, object: nil)
        }
        unsubscribeChannelListener = {(arr, ack) in}
    }
    
    private func initInitializer(){
        socket?.on(clientEvent: .connect, callback: onConnectCallBack)
        socket?.on(clientEvent: .disconnect, callback: onDisconnectCallBack)
        socket?.on(SocketEvent.HANDSHAKE_CHANNEL.rawValue, callback: handshakeListener)
        socket?.on(SocketEvent.SUBSCRIBE_CHAT.rawValue, callback: subscribeChannelListener)
        socket?.on(SocketEvent.SUBSCRIBE_USER.rawValue, callback: subscribeChannelListener)
        socket?.on(SocketEvent.UNSUBSCRIBE_CHAT.rawValue, callback: unsubscribeChannelListener)
        socket?.on(SocketEvent.UNSUBSCRIBE_USER.rawValue, callback: unsubscribeChannelListener)
        socket?.on(clientEvent: .error, callback: { (data, ack) in
            print("error", data)
        })
        socket?.on(clientEvent: .pong, callback: { (data, ack) in })
        socket?.on(clientEvent: .ping, callback: { (data, ack) in })
        socket?.on(SocketEvent.MESSAGE_CHANNEL.rawValue, callback: { (data, ack) in })
    }
    
    private func deinitializeListeners(){
        //off socket events before initialization
        socket?.off(clientEvent: .connect)
        socket?.off(clientEvent: .disconnect)
        socket?.off(SocketEvent.HANDSHAKE_CHANNEL.rawValue)
        socket?.off(SocketEvent.SUBSCRIBE_CHAT.rawValue)
        socket?.off(SocketEvent.SUBSCRIBE_USER.rawValue)
        socket?.off(SocketEvent.UNSUBSCRIBE_CHAT.rawValue)
        socket?.off(SocketEvent.UNSUBSCRIBE_USER.rawValue)
        socket?.off(SocketEvent.MESSAGE_CHANNEL.rawValue)
        socket?.off(SocketEvent.SERVER_PUSH.rawValue)
        
        //release memory of calbacks
        onConnectCallBack = nil
        onDisconnectCallBack = nil
        handshakeListener = nil
        subscribeChannelListener = nil
        unsubscribeChannelListener = nil
    }
    
    @discardableResult
    func on(event: String, callback: @escaping ([Any]) -> Void) -> UUID? {
        return socket?.on(event) { (data, ack) in
            callback(data)
        }
    }
    
    func offEvent(for name: String){
        socket?.off(name)
    }
    
    func isChannelSubscribed(channel : String)-> Bool{
        return subscribedChannel.keys.contains(channel) && subscribedChannel[channel] == true
    }
    
    deinit {
        deinitializeListeners()
        socket?.removeAllHandlers()
        manager = nil
        socket = nil
        NotificationCenter.default.removeObserver(self)
    }
}

extension SocketClient {
    enum SocketError: Int, Error {
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
        case versionMismatch = 415
        case personalInfoSharedError = 417
        
        init?(reasonInfo: [String: Any]) {
            guard let statusCode = reasonInfo["statusCode"] as? Int else {
                return nil
            }
            
            guard let reason = SocketError(rawValue: statusCode) else {
                return nil
            }
            self = reason
        }
    }
}



extension Notification.Name {
    public static var socketConnected = Notification.Name.init("socketConnected")
    public static var socketDisconnected = Notification.Name.init("socketDisconnected")
    public static var channelSubscribed = Notification.Name.init("channelSubscribed")
}

extension SocketClient {
    func addObserver() {
        removeObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: HippoVariable.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func applicationWillEnterForeground() {
        if SocketClient.shared.socket != nil{
            if !SocketClient.shared.isConnectionActive {
                SocketClient.shared.connect() //tearDownPreviousConnectionAndCreateNew
            }
        }
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    var isConnectionActive: Bool {
        return socket?.status.active ?? false
    }
}
