//
//  ShareUrlHelper.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/06/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation
#if canImport(HippoCallClient)
import HippoCallClient
#else

#endif
#if canImport(JitsiMeetSDK)
import JitsiMeetSDK
#else

#endif


final class ShareUrlHelper {
    
    var customAttributesData = ""
    func shareUrlApiCall(url : String, completion: @escaping (String) -> Void) {
        
        #if canImport(JitsiMeetSDK)
        
        var dic = ["app_secret_key" : HippoConfig.shared.appUserType == .agent ? (HippoConfig.shared.agentDetail?.appSecrectKey ?? "") : HippoConfig.shared.appSecretKey, "en_creator_id" : currentEnUserId(), "creator_id" : currentUserId(), "meet_url" : url, "device_type" : Device_Type_iOS] as [String : Any]
        
        if HippoConfig.shared.appUserType == .customer{
            
            dic["offering"] = HippoConfig.shared.offering
            
            if let enUserID = HippoUserDetail.fuguEnUserID{
                dic["en_user_id"] = enUserID
            }
            
            if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
                if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                    dic["user_identification_secret"] = userIdenficationSecret
                }
            }
        }
        HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: "Share_Url",para: dic, extendedUrl: FuguEndPoints.shareMeetLink.rawValue) { (response, error, message, status) in
            if let response = response as? [String : Any], let data = response["data"] as? [String : Any], let url = data["meet_url"] as? String {
                completion(url)
            }
        }
        #else
        print("cannot import JitsiMeetSDK")
        #endif
    }
    
    
    func createLink(callType : CallType)-> (String, String) {
        var url = ""
        #if canImport(JitsiMeetSDK)
        url = JitsiConstants.inviteLink
        #else
        print("cannot import JitsiMeetSDK")
        #endif
        let randomStr = randomString(length: 11) + "iOS"
        var link = url + randomStr
        if HippoConfig.shared.jitsiUrl?.last == "/" {
            HippoConfig.shared.jitsiUrl?.removeLast()
        }
        var jitsiLink = (HippoConfig.shared.jitsiUrl ?? "") != "" ? (HippoConfig.shared.jitsiUrl ?? "") + "/" + randomStr : ""
        if callType == .audio {
            link += "#config.startWithVideoMuted=true"
            jitsiLink += HippoConfig.shared.jitsiUrl != "" ? "#config.startWithVideoMuted=true" : ""
        }
        return (link,jitsiLink)
    }
    
    private func randomString(length: Int = 10) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getUrlToJoinJitsiCall(url : String,completion: @escaping (String,String) -> Void) {
        #if canImport(JitsiMeetSDK)
        let urlSubstringArr = url.split(separator: "/")
        let roomId = urlSubstringArr.last
        let newUrlSubstringArr = urlSubstringArr.dropLast()
        let appSecretKey = newUrlSubstringArr.last
        
        var dic = ["app_secret_key" : appSecretKey ?? "", "en_room_id" : roomId ?? "", "offering" : HippoConfig.shared.offering, "device_type" : Device_Type_iOS] as [String : Any]
        
        if HippoConfig.shared.appUserType == .customer{
            
            dic["offering"] = HippoConfig.shared.offering
            
            if let enUserID = HippoUserDetail.fuguEnUserID{
                dic["en_user_id"] = enUserID
            }
            
            if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
                if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                    dic["user_identification_secret"] = userIdenficationSecret
                }
            }
        }
        
        if HippoUserDetail.callingType != 3{
            HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: "Join_Jitsi_Url",para: dic, extendedUrl: FuguEndPoints.joinJitsiLink.rawValue) { (response, error, message, status) in
                if let response = response as? [String : Any], let data = response["data"] as? [String : Any], let meet_url = data["meet_url"] as? String {
                    completion(meet_url, self.customAttributesData)
                }
            }
        }else{
            HTTPClient.shared.makeSingletonConnectionWith(method: .POST, identifier: "Join_Jitsi_Url",para: dic, extendedUrl: FuguEndPoints.joinJitsiLink.rawValue) { (response, error, message, status) in
                if let response = response as? [String : Any], let data = response["data"] as? [String : Any], let meet_url = data["meet_url"] as? String ,let customAttributes = data["custom_attributes"] as? [String:Any], let callType = customAttributes["call_type"] as? String{
                    self.customAttributesData = callType
                    
                    completion(meet_url, self.customAttributesData)
                }
            }
        }
        #else
        print("cannot import JitsiMeetSDK")
        #endif
    }
}
