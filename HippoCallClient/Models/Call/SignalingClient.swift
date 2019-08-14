//
//  SignalClient.swift
//  HippoCallClient
//
//  Created by Asim on 05/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation

public protocol SignalingClient: class {
   var signalReceivedFromPeer: (([String: Any]) -> Void)? { get set }
   
   func connectClient(completion: @escaping (Bool) -> Void)
   func checkIfReadyForCommunication() -> Bool
   func sendSignalToPeer(signal: CallSignal, completion: @escaping (Bool, NSError?) -> Void)
}
