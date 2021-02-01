//
//  SocketListner.swift
//  Hippo
//
//  Created by Arohi Sharma on 21/10/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

fileprivate struct EventCallback {
    let uuid: UUID?
    let handler: (Any) -> Void
}

class SocketListner {
    private var eventCallbacks = [String: EventCallback]()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnected), name: .socketConnected, object: nil)
    }
    
    func startListening(event: String, callback: @escaping (Any?) -> Void) {
        let uuid = SocketClient.shared.on(event: event) { (dataArray) in
            let data = dataArray.first
            callback(data)
        }
        
        eventCallbacks[event] = EventCallback(uuid: uuid, handler: callback)
    }
    
    func stopListening(event: String) {
        SocketClient.shared.offEvent(for: event)
    }
    
    @objc private func socketConnected()  {
        for (event, callback) in eventCallbacks {
            startListening(event: event, callback: callback.handler)
        }
    }
    
    private func removeAllCallbacks() {
        for event in eventCallbacks {
            stopListening(event: event.key)
        }
    }
    
    deinit {
        //removeAllCallbacks()
        NotificationCenter.default.removeObserver(self)
    }
}
