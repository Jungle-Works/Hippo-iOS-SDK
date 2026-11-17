//
//  AiMessageViewModel.swift
//  HippoAgent
//
//  Created by Neha on 26/03/25.
//  Copyright © 2025 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation


class AiMessageViewModel {
    
    //MARK: - Variables
    
    
    
    func generateContent(contentType: Int, message:String, language:String,channelId:Int, completion: @escaping ((Bool, String) -> Void)){
        
        var params = [
            "device_type": Device_Type_iOS,
            "app_version": fuguAppVersion,
            "device_details": AgentDetail.getDeviceDetails(),
            "source_type": SourceType.SDK.rawValue,
            "content_type": contentType,
            "access_token": HippoConfig.shared.agentDetail?.fuguToken ?? "",
            "lang": "en",
            "language": language
        ] as [String : Any]
        if contentType == 9{
            params["channel_id"] = channelId
        }else{
            params["message"] = message
        }
        print(params)
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: "",para: params, extendedUrl: AgentEndPoints.generateContent) { (response, error, message, status) in
            if let response = response as? [String : Any], let data = response["data"] as? [String : Any], let newMessage = data["message"] as? String {
                print(newMessage)
                if status == 200{
                    completion(true, newMessage)
                }else{
                    completion(false, newMessage)
                }
                
            }
        }
    }
}
