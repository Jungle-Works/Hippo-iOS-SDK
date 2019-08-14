//
//  CallClientCredential.swift
//  HippoCallClient
//
//  Created by Asim on 18/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation

struct CallClientCredential {
    
    let turnApiKey: String?
    let password: String?
    let username: String?
    let stunIceServers: [FGIceServers]
    let turnIceServers: [FGIceServers]
    
    init?(rawCredentials: [String: Any]) {
        self.password = rawCredentials["credential"] as? String
        self.username = rawCredentials["username"] as? String
        self.turnApiKey = rawCredentials["turn_api_key"] as? String
        
        guard let iceServersDict = rawCredentials["ice_servers"] as? [String: Any] else {
            return nil
        }
        
        if let rawStunServers = iceServersDict["stun"] as? [String] {
            var servers = [FGIceServers]()
            for serverDomainName in rawStunServers {
                let server = FGIceServers(domainName: serverDomainName, userName: nil, password: nil)
                servers.append(server)
            }
            self.stunIceServers = servers
        } else {
            self.stunIceServers = []
        }
        
        if let rawStunServers = iceServersDict["turn"] as? [String] {
            var servers = [FGIceServers]()
            for serverDomainName in rawStunServers {
                let server = FGIceServers(domainName: serverDomainName, userName: username, password: password)
                servers.append(server)
            }
            self.turnIceServers = servers
        } else {
            self.turnIceServers = []
        }
        
        if turnIceServers.count + stunIceServers.count == 0 {
            return nil
        }
        
    }
    
    func toJson() -> [String: Any] {
        var params = [String: Any]()
        
        params["credential"] = password ?? ""
        params["turn_api_key"] = turnApiKey ?? ""
        params["username"] = username ?? ""
        
        var iceServers = [String: Any]()
        
        iceServers["stun"] = stunIceServers.map {$0.domainName}
        iceServers["turn"] = turnIceServers.map {$0.domainName}
        
        params["ice_servers"] = iceServers
        
        return params
    }
}

struct FGIceServers {
   let domainName: String
   let userName: String?
   let password: String?
}
