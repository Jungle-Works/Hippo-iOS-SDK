//
//  SearchAgentViewModel.swift
//  Hippo
//
//  Created by Arohi Sharma on 11/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation
class SearchAgentViewModel{
    
    //MARK:- Clousers
    var responseRecieved : (()->())?
    var startLoading : ((Bool)->())?
    
    //MARK:- Variables
    var isCountrySearch : Bool = true
    var searchKey : String?{
        didSet{
            searchAgentByCountryOrSkill()
        }
    }
    var tagArr = [Tag]()
    var countryTag : Tag?
    
    private func searchAgentByCountryOrSkill(){
        self.startLoading?(true)
       
        let params : [String : Any] = ["app_secret_key" : "\(HippoConfig.shared.appSecretKey)","team_name" : "\(searchKey ?? "")"]
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.agentSearchTeam.rawValue) { (responseObject, error, tag, statusCode) in
            self.startLoading?(false)
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                self.responseRecieved?()
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            self.tagArr.removeAll()
            if let data = ((responseObject as? [String : Any])?["data"] as? [[String : Any]]){
                if self.isCountrySearch{
                    let data = self.jsonToNSData(json: data.first ?? [String : Any]())
                    self.countryTag = try? JSONDecoder().decode(Tag.self, from: data ?? Data())
                }else{
                    for tag in data{
                        let data = self.jsonToNSData(json: tag)
                        let agent = try? JSONDecoder().decode(Tag.self, from: data ?? Data())
                        self.tagArr.append(agent ?? Tag())
                    }
                }
            }
            self.responseRecieved?()
        }
    }
    
    // Convert from JSON to nsdata
    func jsonToNSData(json: Any) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
}


struct Tag : Codable{
    var tag_id : Int?
    var tag_name : String?
    
    init(){
        
    }
}


