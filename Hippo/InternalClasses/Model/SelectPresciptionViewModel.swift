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
    var pdfUploaded : ((Error?,UploadResult?)->())?
    var startLoading : ((Bool)->())?
    
    //MARK:- Variables
    
    var getTemplates : Bool?{
        didSet{
            getTemplate()
        }
    }
    var createPresciptionParams : [String : Any]?{
        didSet{
            createAndSendPresciption()
        }
    }
    var templateArr = [Template]()
    var channelID : Int?
    
    
    //MARK:- Functions
  
    private func getTemplate(){
        let params = generateGetTemplateParams()
        
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.getTemplates.rawValue) { (responseObject, error, tag, statusCode) in
    
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
    
    private func createAndSendPresciption(){
        self.startLoading?(true)
        HippoConfig.shared.log.trace(createPresciptionParams as Any, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: createPresciptionParams, extendedUrl: AgentEndPoints.createAndSendPresciption.rawValue) { (responseObject, error, tag, statusCode) in
            self.startLoading?(false)
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                self.pdfUploaded?(error, nil)
                return
            }
            
            HippoConfig.shared.log.debug("\(responseObject ?? [:])", level: .response)
            if let response = responseObject as? [String : Any], let data = response["data"] as? [String : Any]{
                let data = self.jsonToNSData(json: data)
                let result = try? JSONDecoder().decode(UploadResult.self, from: data ?? Data())
                self.pdfUploaded?(nil, result)
            }
        }
    }
    
    
    
    private func generateGetTemplateParams() -> [String : Any]{
        var params = [String : Any]()
        params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        params["template_type"] = 1
        params["fetch_predefined_labels"] = 1
        params["channel_id"] = channelID
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
    
    func createParam(withTemplate template : Template) -> (String?, [String : Any]?){
        var dic = [String : Any]()
        var customAttributes = [String : Any]()
        for key in template.body_keys ?? [BodyKeys()]{
            
            if (key.value ?? "") == ""{
                return ("Please Enter \(key.key?.replacingOccurrences(of: "_", with: " ").capitalized ?? "")",nil)
            }
            if PresciptionValidationType(rawValue: key.type ?? "") == .deeplink{
                customAttributes[key.key ?? ""] = "<a href=\(key.value ?? "") > \(key.value ?? "") </a>"
            }else{
                 customAttributes[key.key ?? ""] = key.value
            }
        }
        dic["custom_attributes"] = customAttributes
        dic["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        dic["template_id"] = template.template_id
        dic["channel_id"] = channelID
        return (nil,dic)
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
    var value : String?
    var placeholder : String?
}

struct UploadResult : Codable{
    var file_name : String?
    var thumbnail_url : String?
    var url : String?
}


enum PresciptionValidationType: String {
    case text = "text"
    case email = "email"
    case textArea = "textarea"
    case date = "date"
    case contact_number = "phonenumber"
    case number = "number"
    case deeplink = "href"
    
    
    var keyBoardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .text:
            return .default
        case .textArea:
            return .default
        case .date:
            return .default
        case .contact_number:
            return .phonePad
        case .number:
            return .decimalPad
        case .deeplink:
            return .default
        }
    }
}
