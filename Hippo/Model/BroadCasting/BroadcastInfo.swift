//
//  BroadcastInfo.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//

import UIKit

enum BroadcastStatus: Int {
    case pending = 0
    case success
}

class BroadcastInfo: NSObject {
    static let firstNameString = "First Name"
    
    var channelId: UInt?
    var createdAtString: String = ""
    var broadcastType: BroadcastType = BroadcastType.unknown
    var title: String = ""
    var message: String = ""
    var fallbackText: String = ""
    var agentId: UInt = 0
    var agentName: String = ""
    var agentEmail: String = ""
    var creationDate: Date?
    
    var attributedMessage: NSAttributedString?
    
    
    private enum Keys: String, CodingKey {
        case channelId = "channel_id"
        case createdAtString = "created_at"
        case broadcastType = "broadcast_type"
        case title = "broadcast_title"
        case message = "message"
        case fallbackText = "fallback_text"
        case agentId = "user_id"
        case agentName = "full_name"
        case agentEmail = "email"
    }
    
    init(json: [String: Any]) {
        super.init()
        channelId = UInt.parse(values: json, key: "channel_id")
        agentId = UInt.parse(values: json, key: "user_id") ?? 0
        
        createdAtString = json["created_at"] as? String ?? ""
        title = json["broadcast_title"] as? String ?? ""
        message = json["message"] as? String ?? ""
        fallbackText = json["fallback_text"] as? String ?? ""
        agentName = json["full_name"] as? String ?? ""
        agentEmail = json["email"] as? String ?? ""
        
        let rawType = json["broadcast_type"] as? String ?? ""
        broadcastType = BroadcastType(rawValue: rawType) ?? .none
        
        if !createdAtString.isEmpty {
            creationDate = createdAtString.toDate
        }
        self.message = message.stringByReplacingFirstOccurrenceOfString(target: "{{{full_name}}}", withString: BroadcastInfo.firstNameString)
        
        createMessageString()
    }
    
    func createMessageString() {
        let rawAttributedString = NSMutableAttributedString(string: message)
        
        let font = UIFont.bold(ofSize: 15)//UIFont.boldSystemFont(ofSize: 15)
        let firstNameRange = (message as NSString).range(of: BroadcastInfo.firstNameString)
        let firstNameAttributes = [NSAttributedString.Key.foregroundColor: UIColor.themeColor,
                                   NSAttributedString.Key.font: font]
        
        rawAttributedString.addAttributes(firstNameAttributes, range: firstNameRange)
        self.attributedMessage = rawAttributedString
    }
    
    
    //    func encode(to encoder: Encoder) throws {
    //        var container = encoder.container(keyedBy: Keys.self)
    //
    //        try container.encode(channelId, forKey: .channelId)
    //        try container.encode(createdAtString, forKey: .createdAtString)
    //        try container.encode(broadCastType, forKey: .broadCastType)
    //        try container.encode(title, forKey: .title)
    //        try container.encode(message, forKey: .message)
    //        try container.encode(fallbackText, forKey: .fallbackText)
    //        try container.encode(agentId, forKey: .agentId)
    //        try container.encode(agentName, forKey: .agentName)
    //        try container.encode(agentEmail, forKey: .agentEmail)
    //    }
    
    //    convenience required init(from decoder: Decoder) throws {
    //        self.init()
    //        let values = try decoder.container(keyedBy: Keys.self)
    //
    //        channelId = try values.decode(UInt.self, forKey: .channelId)
    //        createdAtString = try values.decode(String.self, forKey: .createdAtString)
    //        broadCastType = try values.decode(String.self, forKey: .broadCastType)
    //        title = try values.decode(String.self, forKey: .title)
    //        message = try values.decode(String.self, forKey: .message)
    //        fallbackText = try values.decode(String.self, forKey: .fallbackText)
    //        agentId = try values.decode(UInt.self, forKey: .agentId)
    //        agentName = try values.decode(String.self, forKey: .agentName)
    //        agentEmail = try values.decode(String.self, forKey: .agentEmail)
    //
    //        if !createdAtString.isEmpty {
    //            date = createdAtString.toDate
    //        }
    //    }
    
    
    class func parse(list: [[String: Any]]) -> [BroadcastInfo] {
        var objects: [BroadcastInfo] = []
        
        for each in list {
            let object = BroadcastInfo(json: each)
            objects.append(object)
        }
        return objects
    }
}
