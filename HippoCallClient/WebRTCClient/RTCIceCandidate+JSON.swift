//
//  RTCIceCandidate+JSON.swift
//  HippoCallClient
//
//  Created by Asim on 31/08/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation
import WebRTC

extension RTCIceCandidate {
   func jsonDictionary() -> [String: Any] {
      let dict = [
         CodingKeys.candidate.rawValue: self.sdp,
         CodingKeys.sdpMid.rawValue: self.sdpMid ?? 0,
         CodingKeys.sdpMLineIndex.rawValue: self.sdpMLineIndex
         ] as [String : Any]
      
      return dict
   }
   
   class func fromJson(_ jsonDictionary: [String: Any]) -> RTCIceCandidate? {
      if let sdp = jsonDictionary[CodingKeys.candidate.rawValue] as? String ,
         let sdpMid = jsonDictionary[CodingKeys.sdpMid.rawValue] as? String?,
         let sdpMLineIndex = jsonDictionary[CodingKeys.sdpMLineIndex.rawValue] as? Int32 {
         return RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
      }
      
      return nil
   }
   
   enum CodingKeys: String, CodingKey {
      case candidate
      case sdpMLineIndex
      case sdpMid
   }
}
