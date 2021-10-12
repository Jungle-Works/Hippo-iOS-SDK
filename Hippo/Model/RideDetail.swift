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
        var param: [String: Any] = ["app_secret_key": HippoConfig.shared.appSecretKey,
                                    "en_user_id": HippoUserDetail.fuguEnUserID ?? "-1",
                                    "offering": HippoConfig.shared.offering,
                                    "device_type" : Device_Type_iOS
                                    ]
        if let userIdenficationSecret = HippoConfig.shared.userDetail?.userIdenficationSecret{
            if userIdenficationSecret.trimWhiteSpacesAndNewLine().isEmpty == false {
                param["user_identification_secret"] = userIdenficationSecret
            }
        }
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, showAlert: false, showAlertInDefaultCase: false, showActivityIndicator: false, para: param, extendedUrl: FuguEndPoints.updateRideStatus.rawValue) { (response, error, tag, statusCode) in
            let success = error == nil
            completion(success, error)
        }
    }
    
}
