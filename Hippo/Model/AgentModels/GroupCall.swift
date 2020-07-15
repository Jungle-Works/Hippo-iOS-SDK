//
//  GroupCall.swift
//  Hippo
//
//  Created by Arohi Sharma on 15/07/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import Foundation

class GroupCall{
    class func createGroupCallChannel(request: AgentGroupCallModel, callback: @escaping HippoResponseRecieved) {
        let params: [String: Any]
        
        do {
            params = try request.generateParamsForCreatingChannel()
        } catch {
            callback(error as? HippoError)
            return
        }
        HippoConfig.shared.log.trace(params, level: .request)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: params, extendedUrl: AgentEndPoints.createGroupCallChannel.rawValue) { (responseObject, error, tag, statusCode) in
            
            guard let unwrappedStatusCode = statusCode, error == nil, unwrappedStatusCode == STATUS_CODE_SUCCESS, error == nil  else {
                //                HippoConfig.shared.log.error(error ?? "Something went Wrong!!", level: .error)
                callback(HippoError.general)
                print("Error",error ?? "")
                return
            }
            
            callback(nil)
        }
    }
}
extension GroupCall{
    

    
}
