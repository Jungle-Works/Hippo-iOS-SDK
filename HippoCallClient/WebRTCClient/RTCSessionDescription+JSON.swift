//
//  RTCSessionDescription+JSON.swift
//  HippoCallClient
//
//  Created by Asim on 31/08/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation
import WebRTC

extension RTCSessionDescription {
   
   func toJson() -> [String: Any] {
         let dict = [
            CodingKeys.sdp.rawValue: self.sdp,
            CodingKeys.type.rawValue: self.type.getCommonKeyAsInWeb(),
            ] as [String : Any]
         
         return dict
      }
      
   class func fromJson(_ jsonDictionary: [String: Any]) -> RTCSessionDescription? {
         if let sdp = jsonDictionary[CodingKeys.sdp.rawValue] as? String ,
            let typeString = jsonDictionary[CodingKeys.type.rawValue] as? String,
            let type = RTCSdpType.getFrom(rawValueString: typeString) {
            return RTCSessionDescription(type: type, sdp: sdp)
         }
         
         return nil
      }
      
      enum CodingKeys: String, CodingKey {
         case sdp
         case type
      }
}

extension RTCSdpType {
   func getCommonKeyAsInWeb() -> String {
      switch self {
      case .answer:
         return "answer"
      case .prAnswer:
         return "prAnswer"
      case .offer:
         return "offer"
      }
   }
   
   static func getFrom(rawValueString: String) -> RTCSdpType? {
      switch rawValueString {
      case "answer":
         return RTCSdpType.answer
      case "prAnswer":
         return RTCSdpType.prAnswer
      case "offer":
         return RTCSdpType.offer
      default:
         return nil
      }
   }
}
