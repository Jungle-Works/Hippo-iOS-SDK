//
//  Agent.swift
//  Fugu
//
//  Created by Gagandeep Arora on 22/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation 
//import ObjectMapper
//import SZMentionsSwift


enum AgentEnableStatus: Int {
    case inActive = 0
    case active = 1
    case revoked = 10
    case invited = 4
    
    
    func getString() -> String {
        switch self {
        case .inActive:
            return HippoStrings.inActive
        case .invited:
            return HippoStrings.invited
        case .revoked:
            return HippoStrings.revoked
        case .active:
            return HippoStrings.active
        }
    }
    func getColor() -> UIColor {
        switch self {
        case .inActive, .revoked:
            return UIColor.gray.withAlphaComponent(0.5)
        case .active, .invited:
            return UIColor.themeColor
        }
    }
    
    func newStatus() -> AgentEnableStatus {
        switch self {
        case .inActive:
            return AgentEnableStatus.active
        case .invited:
            return AgentEnableStatus.revoked
        case .revoked:
            return AgentEnableStatus.invited
        case .active:
            return AgentEnableStatus.inActive
        }
    }
}

//class Agent : NSObject, Mappable {
class Agent : NSObject{

	var agentType : Int?
	var email : String?
	var fullName : String?
	var status: Int?
    var currentStatus: AgentEnableStatus = .active
	var userId: Int?
    var inviteId: Int?
	var userName: String?
    var userImageString: String?
    var onlineStatus: String?
    var onlinestatusUpdatedAt: String?
    
    var name: String = ""
    var attributedFullName: String?
    
    var searchableString: String = ""

//	class func newInstance(map: Map) -> Mappable? {
//		return Agent()
//	}
//	required init?(map: Map){}
//	private override init(){}
//
//	func mapping(map: Map) {
//		agentType <- map["agent_type"]
//		email <- map["email"]
//		fullName <- map["full_name"]
//		status <- map["status"]
//		userId <- map["user_id"]
//        inviteId <- map["invite_id"]
//		userName <- map["user_name"]
//        userImageString <- map["user_image"]
//        onlineStatus <- map["online_status"]
//        onlinestatusUpdatedAt <- map["online_status_updated_at"]
//        currentStatus <- map["status"]
//
//        setName()
//        setSearchableString()
//    }
    init(dict: [String: Any]) {
        super.init()
        agentType = dict["agent_type"] as? Int ?? -1
        email = dict["email"] as? String ?? ""
        fullName = dict["full_name"] as? String ?? ""
        status = dict["status"] as? Int ?? -1
        userId = dict["user_id"] as? Int ?? -1
        inviteId = dict["invite_id"] as? Int ?? -1
        userName = dict["user_name"] as? String ?? ""
        userImageString = dict["user_image"] as? String ?? ""
        onlineStatus = dict["online_status"] as? String ?? ""
        onlinestatusUpdatedAt = dict["online_status_updated_at"] as? String ?? ""
//        currentStatus = AgentEnableStatus(rawValue: dict["status"] as? Int ?? -1) ??
        if let _status = dict["status"] as? Int, let status = AgentEnableStatus.init(rawValue: _status) {
            currentStatus = status
        }
        
        setName()
        setSearchableString()

    }
    
    func setSearchableString() {
        searchableString = "\(fullName ?? "")\(email ?? "")".lowercased()
    }
    
    func setName() {
        if let name = fullName, let agentId = userId {
            self.name = name.lowercased()
            self.attributedFullName = "<a color='#2296FF' href='mention://\(agentId)' contenteditable='false' data-id=" + "'\(agentId)'>" + "@" + name + kFontLastStr + " "
        } else {
            self.attributedFullName =  kFontFirstStr + " " + kFontLastStr + " "
            self.name = "".lowercased()
        }
    }

    class func getArrayfrom(jsonArray: [[String: Any]]) -> [Agent] {
        var rawAgents: [Agent] = []
        
        for json in jsonArray {
//            guard let agent = Agent(JSON: json), agent.currentStatus == .active else {
            let agent = Agent(dict: json)
            if agent.currentStatus == .active{
                rawAgents.append(agent)
            } else {
                continue
            }
        }
        return rawAgents
    }
    
    class func generalArrayParser(array: [[String: Any]]) -> [Agent] {
        var rawAgents: [Agent] = []
        
        for json in array {
//            guard let agent = Agent(JSON: json) else {
//            guard agent = Agent(dict: json) else {
//                continue
//            }
            let agent = Agent(dict: json)
            rawAgents.append(agent)
        }
        return rawAgents
    }
    class func getJsonToStore(agents: [Agent]) -> [[String: Any]] {
        var rawJson: [[String: Any]] = []
        for each in agents {
            rawJson.append(each.toJson())
        }
        return rawJson
    }
    
    func toJson() -> [String: Any] {
        var dict = [String: Any]()
        dict["agent_type"] = agentType
        dict["email"] = email
        dict["full_name"] = fullName
        dict["status"] = status
        dict["user_id"] = userId
        dict["invite_id"] = inviteId
        dict["user_name"] = userName
        dict["user_image"] = userImageString
        dict["online_status"] = onlineStatus
        dict["online_status_updated_at"] = onlinestatusUpdatedAt
//        dict["status"] = currentStatus
        dict["status"] = currentStatus.rawValue
        return dict
    }
    
}

extension Agent: CreateMention {
    var mentionName: String {
        return "@" + (self.fullName ?? self.email ?? "Agent")
    }

    var mentionSymbol: String {
        return "@"
    }
}
