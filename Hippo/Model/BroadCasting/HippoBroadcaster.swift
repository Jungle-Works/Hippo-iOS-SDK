//
//  HippoBroadcaster.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

class HippoBroadcaster {
    
    typealias getBroadcastCompletion = ((_ success: Bool, _ errorMessage: String?) -> ())
    typealias previousBroadcastListCompletion = ((_ success: Bool, _ broadcast: BroadcastStore?) -> ())
    typealias sendBroadcastCompletion = ((_ success: Bool, _ message: String) -> ())
    
    var teams = [TagDetail]()
    var agents: [Int: [UserDetail]] = [:]
    
    var selectedTeam: TagDetail?
    
    func copy() -> HippoBroadcaster {
        let newBroadCast = HippoBroadcaster()
        newBroadCast.teams = teams
        
        
        var tempDict: [Int: [UserDetail]] = [:]
        for (key, value) in agents {
            tempDict[key] = UserDetail.createCopy(oldObject: value)
        }
        newBroadCast.agents = tempDict
        newBroadCast.selectedTeam = selectedTeam
        return newBroadCast
    }
    
    func getAgentsList(for team: TagDetail) -> [UserDetail] {
        guard let id = team.tagId else {
            return []
        }
        return agents[id] ?? []
    }
    
    func getSelectedTeamAgent() -> [UserDetail] {
        guard let id = selectedTeam?.tagId else {
            return []
        }
        return agents[id] ?? []
    }
    func getAllSelectedAgent() -> [UserDetail] {
        var agentsList = [UserDetail]()
        for (_, value) in agents {
            for each in value where each.isSelected  {
                guard each.id > 0 else {
                    continue
                }
               agentsList.append(each)
            }
        }
        return agentsList
    }
    
    func getSelectedAgentsIds() -> [Int] {
        var agentsList = [Int]()
        for (_, value) in agents {
            for each in value where each.isSelected  {
                guard each.id > 0 else {
                    continue
                }
                agentsList.append(each.id)
            }
        }
        return agentsList
        
    }
    func updateAgentsListForSelectedTeam(with agents: [UserDetail]) {
        guard let id = selectedTeam?.tagId else {
            return
        }
        self.agents[id] = agents
    }
    func unselectAllAgentsForAllTeam() {
        for (key, value) in agents {
            let rawAgents = value
            for (index, _) in rawAgents.enumerated() {
                rawAgents[index].isSelected = false
            }
            agents[key] = rawAgents
        }
    }
    
    func selectAllAgentsForAllTeam() {
        for (key, value) in agents {
            let rawAgents = value
            for (index, _) in rawAgents.enumerated() {
                rawAgents[index].isSelected = true
            }
            agents[key] = rawAgents
        }
    }
    
    func unselectAllAgentsForSelectedTeam() {
        guard let id = selectedTeam?.tagId, var rawAgents = agents[id] else {
            return
        }
        for (index, _) in rawAgents.enumerated() {
            rawAgents[index].isSelected = false
        }
        agents[id] = rawAgents
    }
    func selectAllAgentsForSelectedTeam() {
        guard let id = selectedTeam?.tagId, var rawAgents = agents[id] else {
            return
        }
        for (index, _) in rawAgents.enumerated() {
            rawAgents[index].isSelected = true
        }
        agents[id] = rawAgents
    }
    
    func isAllAgentSelectedForSelectedTeam() -> Bool {
        guard let id = selectedTeam?.tagId, let rawAgents = agents[id] else {
            return false
        }
        for each in rawAgents where !each.isSelected && each.id > 0 {
            return false
        }
        return true
    }
    
    func getSelectedAgentCount() -> Int {
        return getAllSelectedAgent().count
    }
    
    func getBroadcastTags(completion: @escaping getBroadcastCompletion) {
        
        guard let params = getParamsForGroupingTags() else {
            completion(false, nil)
            return
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getGroupingTag.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any], let data = responseDict["data"] as? [String: Any], let tags = data["tags"] as? [[String: Any]] else {
                    let message = error?.localizedDescription ?? HippoStrings.somethingWentWrong
                    completion(false, message)
                    return
            }
            var rawTeams = [TagDetail.getAllTeamObject()]
            var rawUsers: [Int: [UserDetail]] = [:]
            
            for each in tags {
                let team = TagDetail(json: each)
                
                guard let parsedUser = each["users"] as? [[String: Any]], let tagId = team.tagId else {
                    continue
                }
                
                var users = UserDetail.getObjects(from: parsedUser)
                users.insert(UserDetail.getAllAgentsDefaultObj(), at: 0)
                
                rawTeams.append(team)
                rawUsers[tagId] = users
            }
            
            
            self.teams = rawTeams
            self.agents = rawUsers
            completion(true, nil)
        }
    }
    func sendBroadcastMessage(dict: [String: Any], completion: @escaping sendBroadcastCompletion) {
        guard let params = getParamsForBroadcastMessage(with: dict) else {
            completion(false, HippoStrings.somethingWentWrong)
            return
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.sendBroadcastMessage.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any], let _ = responseDict["data"] as? [String: Any] else {
                let message = HippoStrings.somethingWentWrong
                completion(false, message)
                return
            }
            let message = responseDict["message"] as? String ?? HippoStrings.somethingWentWrong
            completion(true, message)
        }
    }
    
    class func getPreviousBroadcastMessage(completion: @escaping previousBroadcastListCompletion) {
       
        let store = BroadcastStore()
        store.getBroadcastFromInital {(result) in
            guard let _ = result else {
                completion(false, nil)
                return
            }
            completion(true, store)
        }
        
    }
    class func getChatboxViewController(for user: CustomerInfo) -> AgentConversationViewController? {
        guard let channelId = user.repliedOn else {
            return nil
        }
        let intChannelId = Int(channelId)
        let vc = AgentConversationViewController.getWith(channelID: intChannelId, channelName: user.customerName)
        return vc
    }
    
    class func getBroadcastDetailInstance(broadcastDetail: BroadcastInfo) -> BroadcastDetailViewController {
        let store = BroadcastDetailStore(broadcastDetail: broadcastDetail)
        let vc = BroadcastDetailViewController.get(store: store)
        return vc
    }
    
    private func getParamsForBroadcastMessage(with dict: [String: Any]) -> [String: Any]? {
        
        guard let fuguToken = HippoConfig.shared.agentDetail?.fuguToken else {
            return nil
        }
        var param: [String: Any] = ["access_token": fuguToken]
        param["user_ids"] = getSelectedAgentsIds()
        param += dict
        return param
    }
    
    private func getParamsForGroupingTags() -> [String: Any]? {
        
        guard let fuguToken = HippoConfig.shared.agentDetail?.fuguToken, !fuguToken.isEmpty else {
            return nil
        }
        let param: [String: Any] = ["access_token": fuguToken]
        return param
    }
    
}
