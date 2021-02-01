//
//  SocketListner.swift
//  Hippo
//
//  Created by Arohi Sharma on 21/10/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

@objc protocol HippoChannelSocketDelegate : class {
    @objc optional func socketRecieved(dict : [String : Any])
}
@objc protocol UserChannelDelegate : class {
    @objc optional func socketRecieved(dict : [String : Any])
}


class SocketListner {
    
    //MARK:- Variables
    
    static var shared: SocketListner?
    weak var channelDelegate : HippoChannelSocketDelegate?
    weak var userChannelDelegate : UserChannelDelegate?
    
    
    //MARK:- Functions
    class func reIntializeIfRequired() {
        guard shared == nil else {
            return
        }
        
        if let newReference = SocketListner() {
            shared = newReference
        }
    }
    
    private init?() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnected), name: .socketConnected, object: nil)
        self.stopListening()
        self.startListening()
    }
    
    private func startListening() {
        SocketClient.shared.on(event: SocketEvent.SERVER_PUSH.rawValue) { [weak self] (dataArray) in
            DispatchQueue.main.async {
                if let data = dataArray.first as? [String : Any], let channel = (data["channel"] as? String)?.replacingOccurrences(of: "/", with: ""){
                    if currentUserType() == .agent{
                        if channel == HippoConfig.shared.agentDetail?.userChannel{
                            self?.userChannelDelegate?.socketRecieved?(dict: data)
                        }else{
                            self?.channelDelegate?.socketRecieved?(dict: data)
                        }
                    }else{
                        if channel == HippoUserDetail.HippoUserChannelId ?? ""{
                            self?.userChannelDelegate?.socketRecieved?(dict: data)
                        }else{
                            self?.channelDelegate?.socketRecieved?(dict: data)
                        }
                    }
                }
            }
        }
    }
    
    private func stopListening() {
        SocketClient.shared.offEvent(for: SocketEvent.SERVER_PUSH.rawValue)
    }
    
    @objc private func socketConnected()  {
        self.stopListening()
        self.startListening()
    }
    
    deinit {
        self.stopListening()
        NotificationCenter.default.removeObserver(self)
    }
}
