////
////  FayeConnection.swift
////  Fugu
////
////  Created by Gagandeep Arora on 21/06/17.
////  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
////
//

////MARK: - MZFayeClient Delegate
//
//extension FayeConnection: MZFayeClientDelegate {
//    func fayeClient(_ client: MZFayeClient!, didConnectTo url: URL!) {
//        HippoConfig.shared.log.debug("didConnectTo==>\(url.absoluteString)", level: .info)
//        NotificationCenter.default.post(name: .fayeConnected, object: nil)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didDisconnectWithError error: Error!) {
//        let errorMessage = error?.localizedDescription ?? ""
//        HippoConfig.shared.log.debug("didDisconnectWithError==>\(errorMessage)", level: .info)
//        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didUnsubscribeFromChannel channel: String!) {
//        HippoConfig.shared.log.debug("didUnsubscribeFromChannel==>\(channel ?? "")", level: .info)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didSubscribeToChannel channel: String!) {
//        HippoConfig.shared.log.debug("didSubscribeToChannel==>\(channel ?? "")", level: .info)
//        NotificationCenter.default.post(name: .channelSubscribed, object: nil)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didFailWithError error: Error!) {
//        HippoConfig.shared.socketsFailed = true
//        let errorMessage = error?.localizedDescription ?? ""
//        HippoConfig.shared.log.debug("didFailWithError==>\(errorMessage)", level: .info)
//        NotificationCenter.default.post(name: .fayeDisconnected, object: nil)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didFailDeserializeMessage message: [AnyHashable : Any]!, withError error: Error!) {
//        let errorMessage = error?.localizedDescription ?? ""
//        HippoConfig.shared.log.debug("didFailDeserializeMessage==>\(message ?? [:]) \n and error==>\(errorMessage)", level: .info)
//    }
//    
//    func fayeClient(_ client: MZFayeClient!, didReceiveMessage messageData: [AnyHashable : Any]!, fromChannel channel: String!) {
//    }
//}
//
//extension FayeConnection {
//    enum FayeError: Int, Error {
//        case fayeNotConnected = 400
//        case userBlocked = 401
//        case channelDoesNotExist = 407
//        case invalidThreadMuid = 408
//        case userDoesNotBelongToChannel = 409
//        case messageDeleted = 410
//        case invalidMuid = 411
//        case duplicateMuid = 412
//        case invalidSending = 413
//        case channelNotSubscribed = 4000
//        case resendSameMessage = 420
//        case versionMismatch = 415
//        case personalInfoSharedError = 417
//        
//        init?(reasonInfo: [String: Any]) {
//            guard let statusCode = reasonInfo["statusCode"] as? Int else {
//                return nil
//            }
//            
//            guard let reason = FayeError(rawValue: statusCode) else {
//                return nil
//            }
//            self = reason
//        }
//    }
//    struct FayeResponseError {
//        var message: String?
//        var error: FayeError?
//        var showError: Bool = false
//        
//        init(reasonInfo: [String: Any]) {
//            error =  FayeError(reasonInfo: reasonInfo) ?? .fayeNotConnected
//            message = reasonInfo["customMessage"] as? String
//            if message == nil {
//                message = reasonInfo["message"] as? String
//            }
//            showError = Bool.parse(key: "showError", json: reasonInfo, defaultValue: false)
//        }
//        
//        static func fayeNotConnected() -> FayeResponseError {
//            return FayeResponseError(reasonInfo: [:])
//        }
//        
//        static func channelNotSubscribed() -> FayeResponseError {
//            var response =  FayeResponseError(reasonInfo: [:])
//            response.error = .channelNotSubscribed
//            return response
//        }
//        
//    }
//    
//    typealias FayeResult = (success: Bool, error: FayeResponseError?)
//}
//
//extension Notification.Name {
//    public static var fayeConnected = Notification.Name.init("fayeConnected")
//    public static var fayeDisconnected = Notification.Name.init("fayeDisconnected")
//    public static var channelSubscribed = Notification.Name.init("channelSubscribed")
//}

