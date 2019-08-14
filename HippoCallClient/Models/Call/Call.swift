//
//  Call.swift
//  HippoCallClient
//
//  Created by Vishal on 16/10/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation

public class Call {
    var rtcClient: WebRTCClient?
    fileprivate(set) var signalingClient: SignalingClient
    public let peer: CallerInfo
    fileprivate(set) var currentUser: CallPeer
    public let uID: String
    var status = State.idle
    var timeElapsedSinceCallStart = 0
    let type: CallType
    var isStartCallSend: Bool = false
    
    public init(peer: CallPeer, signalingClient: SignalingClient, uID: String, currentUser: CallPeer, type: CallType) {
        self.peer = peer
        self.signalingClient = signalingClient
        self.uID = uID
        self.currentUser = currentUser
        self.type = type
    }
}

public extension Call {
    enum State {
        case idle //ready to connect not sent
        case incomingCall
        case inCall
        case outgoingCall
    }
    
    enum CallType: String {
        case audio = "AUDIO"
        case video = "VIDEO"
    }
}
