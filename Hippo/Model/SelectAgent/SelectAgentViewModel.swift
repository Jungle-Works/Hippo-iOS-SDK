//
//  SelectAgent.swift
//  Hippo
//
//  Created by Arohi Sharma on 13/01/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

class SelectAgentViewModel {
    
    //MARK:- Clousers
    var responseRecieved : (()->())?
    var startLoading : ((Bool)->())?
    var tagIds : [String]?
    
    //MARK:- Variables
    var getList : Bool?{
        didSet{
            getAgentList()
        }
    }
    var agentCard : [MessageCard]?
    
    private func getAgentList(){
        self.startLoading?(true)
        
        let params : [String : Any] = ["app_secret_key" : "\(HippoConfig.shared.appSecretKey)","tag_ids" : tagIds ?? [String](),"contain_all_tag_ids" : 1]
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: FuguEndPoints.getAgentCard.rawValue) { (responseObject, error, tag, statusCode) in
            self.startLoading?(false)
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                self.responseRecieved?()
                return
            }
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            self.agentCard?.removeAll()
            
            if let data = ((responseObject as? [String : Any])?["data"] as? [[String : Any]]){
                self.agentCard = MessageCard.parseList(cardsJson: data)
            }
            self.responseRecieved?()
        }
    }
    
}
