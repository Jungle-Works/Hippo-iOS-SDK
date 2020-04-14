//
//  AgentProfilePresenter.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

protocol AgentProfilePresenterDelegate: class {
    func profileUpdated()
}
class AgentProfilePresenter {
    
    static var channelProfileMapping: [Int: ProfileDetail] = [:]
    static var idProfileMapping: [String: ProfileDetail] = [:]
    weak var delegate: AgentProfilePresenterDelegate?
    
    var profile: ProfileDetail?
    var channelID: Int
    var agentID: String?
    
    init(channelID: Int, agentID: String?, profile: ProfileDetail? = nil) {
        self.channelID = channelID
        self.agentID = agentID?.trimWhiteSpacesAndNewLine()
        
        self.profile = profile ?? AgentProfilePresenter.channelProfileMapping[channelID] ?? AgentProfilePresenter.idProfileMapping[self.agentID ?? ""]
        getProfile(completion: nil)
    }
    
    internal func generateParam() -> [String: Any]? {
        
        var json: [String : Any] = [:]
        
        guard let enUserID = HippoUserDetail.fuguEnUserID else {
            return nil
        }
        if channelID > 0 {
            json["channel_id"] = channelID
        }
        if let id = agentID, !id.isEmpty {
            json["agent_id"] = agentID
        }
        json["app_secret_key"] = HippoConfig.shared.appSecretKey
        json["en_user_id"] = enUserID
        
        return json
    }
    
    func setDelegate(delegate: AgentProfilePresenterDelegate) {
        self.delegate = delegate
        delegate.profileUpdated()
    }
    
    func getProfile(completion: ((_ success: Bool, _ profile: ProfileDetail?) -> ())?) {
        guard let param = generateParam() else {
            completion?(false, profile)
            return
        }
        if self.profile == nil {
            HippoConfig.shared.delegate?.startLoading(message: "Getting User Info")
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: FuguEndPoints.getInfoV2.rawValue) { (response, error, tag, statusCode) in
            HippoConfig.shared.delegate?.stopLoading()
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS  else {
                completion?(false, nil)
                return
            }
            guard let r = response as? [String: Any], let data = r["data"] as? [String: Any] else {
                completion?(false, nil)
                return
            }
            let profile = ProfileDetail(json: data)
            self.profile = profile
            
            if self.channelID > 0 {
                AgentProfilePresenter.channelProfileMapping[self.channelID] = profile
            } else if let id = profile.id, !id.isEmpty {
                AgentProfilePresenter.idProfileMapping[id] = profile
            }
            self.delegate?.profileUpdated()
            completion?(true, profile)
        }
    }
}
