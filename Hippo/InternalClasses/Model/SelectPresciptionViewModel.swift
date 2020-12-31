//
//  SelectPresciptionViewModel.swift
//  Hippo
//
//  Created by Arohi Sharma on 29/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation
class SelectPresciptionViewModel{
    
    //MARK:- Clousers
    
    var responseRecieved : (()->())?
    
    //MARK:- Variables
    
    var getTemplates : Bool?{
        didSet{
            getTemplate()
        }
    }
    var templateArr = [Template]()
    
    //MARK:- Functions
  
    private func getTemplate(){
     
        
        let params = generateGetTemplateParams()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .url, para: params, extendedUrl: AgentEndPoints.getTemplates.rawValue) { (responseObject, error, tag, statusCode) in
    
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                self.responseRecieved?()
                return
            }
            self.templateArr.removeAll()
            
            if let businessTemplate = (((responseObject as? [String : Any])?["data"] as? [String : Any])?["business_templates"] as? [[String : Any]]){
                for template in businessTemplate{
                    let data = self.jsonToNSData(json: template)
                    let template = try? JSONDecoder().decode(Template.self, from: data ?? Data())
                    self.templateArr.append(template ?? Template())
                }
            }
            
            self.responseRecieved?()
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            
        }
    }
    
    
    private func generateGetTemplateParams() -> [String : Any]{
        var params = [String : Any]()
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        params["template_type"] = 1
        return params
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

struct Template : Codable{
    var name : String?
    var template_id : Int?
    var preview : String?
    var body_keys : [BodyKeys]?
    
    
    init(){
        
    }

}

struct BodyKeys : Codable{
    var key : String?
    var type : String?
}
