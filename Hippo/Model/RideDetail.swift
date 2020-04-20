//
//  RideDetail.swift
//  Hippo
//
//  Created by Vishal on 26/03/19.
//

import Foundation


class RideDetail: NSObject {
    static var current: RideDetail?
    
    var estimatedTime: UInt = 0
    var startTime: Date = Date()
    
    init(estimatedTime: UInt) {
        self.estimatedTime = estimatedTime
    }
    
    func getRemaningTime() -> UInt? {
        let interval = Date().timeIntervalSince(startTime)
        let parsedInterval = UInt(interval)
        let diff: UInt
        if estimatedTime > parsedInterval {
            diff = estimatedTime - parsedInterval
        } else {
            diff = 0
        }
        guard diff > 0 else {
            RideDetail.current = nil
            return nil
        }
        return diff
    }
    
    class func sendRideEndStatus(completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
        let param: [String: Any] = ["app_secret_key": HippoConfig.shared.appSecretKey,
                                    "en_user_id": HippoUserDetail.fuguEnUserID ?? "-1"]
        
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, showAlert: false, showAlertInDefaultCase: false, showActivityIndicator: false, para: param, extendedUrl: FuguEndPoints.updateRideStatus.rawValue) { (response, error, tag, statusCode) in
            let success = error == nil
            completion(success, error)
        }
    }
    
}
