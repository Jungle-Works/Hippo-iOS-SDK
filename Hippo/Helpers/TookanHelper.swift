//
//  TookanHelper.swift
//  Hippo
//
//  Created by Vishal on 23/01/19.
//

import Foundation

class TookanHelper: NSObject {
    static let tookanCountryCodeEndPoint: String = "https://ip.tookanapp.com:8000/requestCountryCodeGeoIP2"
    
    static var countryInfo: [String: Any]? {
        get {
            return UserDefaults.standard.value(forKey: UserDefaultkeys.countryInfo) as? [String: Any]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultkeys.countryInfo)
        }
    }
    
    class func getCountryCode() {
        guard countryInfo == nil else {
            return
        }
        _ = HTTPClient.makeThirpartyCall(method: .GET, showAlert: false, showAlertInDefaultCase: false, showActivityIndicator: false, para: nil, baseUrl: tookanCountryCodeEndPoint, extendedUrl: "", callback: { (response, error, _, statusCode) in
            guard let parsedResponse = response as? [String: Any], let data = parsedResponse["data"] as? [String: Any] else {
                return
            }
            countryInfo = data
//            guard HippoConfig.shared.userDetail != nil else {
//                return
//            }
           // HippoUserDetail.getUserDetailsAndConversation(completion: nil)
        })
    }
}

