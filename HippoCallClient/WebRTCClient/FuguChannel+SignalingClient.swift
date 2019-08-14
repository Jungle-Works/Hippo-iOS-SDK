//
//  HippoChannel+SignalingClient.swift
//  HippoCallClient
//
//  Created by Vishal on 31/10/18.
//  Copyright © 2018 Clicklabs. All rights reserved.
//

import Foundation

//extension HippoChannel: SignalingClient {
//   
//   func connectClient(completion: @escaping (Bool) -> Void) {
//      guard !isConnected() else {
//         completion(true)
//         return
//      }
//      
//      guard !isSubscribed() else {
//         completion(false)
//         return
//      }
//      
//      subscribeChannel { (success) in
//         completion(success)
//      }
//   }
//   
//   
//   func checkIfReadyForCommunication() -> Bool {
//      return isConnected()
//   }
//   
//   func sendSignalToPeer(signal: CallSignal, completion: @escaping (Bool, NSError?) -> Void) {
//      send(publishable: signal) { (success, error)  in
//         completion(success, error)
//      }
//   }
//   
//}
