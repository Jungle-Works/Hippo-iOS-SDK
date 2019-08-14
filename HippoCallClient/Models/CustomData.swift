//
//  CustomData.swift
//  HippoCallClient
//
//  Created by Vishal on 19/06/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import Foundation

public class CustomData: NSObject {
    public var uniqueId: String
    public var flag: String
    public var message: String?
    
    public init?(uniqueId: String, flag: String, message: String?) {
        guard !uniqueId.isEmpty else {
            return nil
        }
        self.uniqueId = uniqueId
        self.flag = flag
        self.message = message
    }
    init?(dict: [String: Any]) {
        guard let id = dict["unique_id"] as? String else {
            return nil
        }
        self.uniqueId = id
        self.flag = dict["flag"] as? String ?? ""
        self.message = dict["message"] as? String
        
    }
    
    public func getJson() -> [String: Any] {
        var json: [String: Any] = [:]
        
        json["unique_id"] = uniqueId
        json["flag"] = flag
        
        if let parsedMessage = message {
            json["message"] = parsedMessage
        }
        
        return json
    }
}
