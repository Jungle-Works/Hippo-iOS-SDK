////
////  VideoSDKApiManager.swift
////  Hippo
////
////  Created by vikas on 11/11/21.
////
//
//import Foundation
//import HippoCallClient
//
//class VideoSDKApiManager:NSObject {
//    
//    var serverVidToken = ""
//    var meetingID = ""
//    var url = ""
//    static let shared = VideoSDKApiManager()
//    var appSecretKey = ""
//    
//    func appSecretFromHippoCallClient(key : String){
//        appSecretKey = key
//    }
//    
//   
//    func getParamsForVideoToken() -> [String : Any]{
//           var params = [String : Any]()
//        params["app_secret_key"] = HippoConfig.shared.appSecretKey
//           params["request_token"] = 1
//           return params
//       }
//    
////    func meetIdParams() -> [String:Any]{
////        var params = [String : Any]()
////        params["app_secret_key"] = HippoConfig.shared.appSecretKey
////        params["meet_token"] = self.serverVidToken
////        params["create_meet"] = 1
////        return params
////
////    }
//    
//    
//    func getTokenForVidSDK(){
//       
//        let params = getParamsForVideoToken()
//        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.joinVideoSDKMeet.rawValue) { [self] (response, error, _, statusCode) in
//            guard let parsedResponse = response as? [String : Any], let data = parsedResponse["data"] as? [String : Any], let token = data["token"] as? String else{
//                print(error.debugDescription)
//                return
//            }
//            self.serverVidToken = token
////            self.getMeetId()
//        }
//    }
//    
//    
//    
//    func callHangUp(){
//       
//        let params = getParamsForVideoToken()
//        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.callHangup.rawValue) { [self] (response, error, _, statusCode) in
//            guard let parsedResponse = response as? [String : Any], let data = parsedResponse["data"] as? [String : Any], let token = data["token"] as? String else{
//                print(error.debugDescription)
//                return
//            }
//            self.serverVidToken = token
////            self.getMeetId()
//        }
//    }
////    func getMeetId(){
////        if FuguNetworkHandler.shared.isNetworkConnected == false {
////           checkNetworkConnection()
////           return
////        }
////        let params = meetIdParams()
////        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: FuguEndPoints.videoSDKToken.rawValue) { (response, error, _, statusCode) in
////            guard let parsedResponse = response as? [String : Any], let data = parsedResponse["data"] as? [String : Any], let meetingID = data["meeting_id"] as? String, let url = data["url"] as? String else{
////                print(error.debugDescription)
////                return
////            }
////            self.meetingID = meetingID
////            self.url = url
////        }
////    }
//}
