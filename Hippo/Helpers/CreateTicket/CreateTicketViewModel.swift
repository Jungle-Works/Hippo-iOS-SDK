//
//  CreateTicketViewModel.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation


enum ErpSearchType : String{
    case issueType = "Issue Type"
    case issuePriority = "Issue Priority"
}


final
class CreateTicketVM{

    var initialIssueTypeData = [String]()
    var initialPriorityData = [String]()
    var issueTypeData = [String]()
    var priorityTypeData = [String]()
    var searchDataUpdated : ((ErpSearchType)->())?
    var isCustomerCreated = false
    var customerName = String()
    
    func erpSearch(type: ErpSearchType, text : String){
        var param = [String : Any]()
        param["business_id"] =  BussinessProperty.current.id
        param["reference"] = "Issue"
        param["text"] = text
        param["type"] = type.rawValue
        
        if text == "" && type == .issueType && initialIssueTypeData.count != 0{
            self.searchDataUpdated?(type)
            return
        }else if text == "" && type == .issuePriority && initialPriorityData.count != 0{
            self.searchDataUpdated?(type)
            return
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: param, extendedUrl: FuguEndPoints.searchErp.rawValue) {[weak self](responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                return
            }
            
            guard let value = responseObject as? [String: Any], let data = value["data"] as? [String: Any], let results = data["results"] as? [[String : Any]] else {
                return
            }
            var dataArr = [String]()
            for value in results{
                dataArr.append(value["value"] as? String ?? "")
            }
            
            if text == "" && type == .issueType{
                self?.initialIssueTypeData = dataArr
            }else if text == "" && type == .issuePriority{
                self?.initialPriorityData = dataArr
            }else if type == .issueType{
                self?.issueTypeData = dataArr
            }else{
                self?.priorityTypeData = dataArr
            }
            self?.searchDataUpdated?(type)
        }
    }
    
    func checkAndCreateCustomer(name : String, email : String, completion: ((Bool) -> Void)? = nil){
        var param = [String : Any]()
        param["app_secret_key"] = HippoConfig.shared.appSecretKey
        param["customer_name"] = name
        param["customer_email"] = email
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: param, extendedUrl: FuguEndPoints.checkAndCreateCustomer.rawValue){[weak self](responseObject, error, tag, statusCode) in
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                print("Error",error ?? "")
                return
            }
            guard let response = responseObject as? [String : Any], let data = response["data"] as? [String : Any] else{
                return
            }
            
            self?.isCustomerCreated = true
            self?.customerName = data["customer_name"] as? String ?? ""
            completion?(true)
        }
    }

}
