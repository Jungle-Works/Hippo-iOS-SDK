//
//  OtplessHelper.swift
//  OtplessSDK
//
//  Created by Otpless on 06/02/23.
//

import Foundation
class OtplessHelper {
   public static let waidDefaultKey = "otpless_waId"
   public static let userMobileDefaultKey = "otpless_user_mobile"
    public static let userNameDefaultKey = "otpless_user_name"
   public static var link = ""
    public static var link2 = ""
   
    
  public static func checkValueExists(forKey key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    public static func getValue<T>(forKey key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }
    
    public static func setValue<T>(value: T?, forKey key: String) {
            UserDefaults.standard.set(value, forKey: key)
        }
    
    public static func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    /*
    https://jugnoo.authlink.me?
    redirectUri=otpless://dgotpless
    &deviceId=ff8fb67386576cbd
    &package=com.otpless.otplesssample
     &platform=android
     &osVersion=33
     &manufacturer=samsung
     &appVersionName=1.0.2
     &appVersionCode=102
     &sdkVersion=1.0.0
    https://jugnoo.authlink.me?
     redirectUri=hippootpless://hippootpless
     &deviceId=14FB377C-E7FA-4E67-B322-6F30DCA36A4B
     &package=org.cocoapods.demo.OtplessSDK-Example
     &platform=iOS
     &osVersion=14.7.1
     &manufacturer=Apple-iPhone-iPhone
     &appVersionName=1.0
     &appVersionCode=1
     &sdkVersion=1.0.0"

    */
    public static func addEventDetails(url: String) -> String{
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let package = Bundle.main.bundleIdentifier
        let platform = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let manufacturer = "Apple-" + UIDevice.current.model
        let appVersionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let sdkVersion = "1.0.0"
        
        let baseURL = URL(string:url)!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
       
        let newQueryItems = [
            URLQueryItem(name: "deviceId", value: deviceId),
            URLQueryItem(name: "package", value: package),
            URLQueryItem(name: "platform", value: platform),
            URLQueryItem(name: "osVersion", value: osVersion),
            URLQueryItem(name: "manufacturer", value: manufacturer),
            URLQueryItem(name: "appVersionName", value: appVersionName),
            URLQueryItem(name: "appVersionCode", value: appVersionCode),
            URLQueryItem(name: "sdkVersion", value: sdkVersion)
        ]
        queryItems.append(contentsOf: newQueryItems)
        components.queryItems = queryItems
        let finalURL = components.url!
        print(queryItems)
        print("finalURL   \(finalURL.absoluteString)")
        return finalURL.absoluteString
    }
    
    
    
    public static func saveUserMobileAndWaid(waId : String, userMobile : String, name: String) {
        setValue(value: waId, forKey: waidDefaultKey)
        setValue(value: userMobile, forKey: userMobileDefaultKey)
        setValue(value: name, forKey: userNameDefaultKey)
    }
    public static func removeUserMobileAndWaid() {
        removeValue(forKey: waidDefaultKey)
        removeValue(forKey: userMobileDefaultKey)
        removeValue(forKey: userNameDefaultKey)
    }
    
    public static func getCompleteUrl() -> String? {
        if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String], let identifier = urlType["CFBundleURLName"] as? String {
                    if urlSchemes.count == 1 && urlSchemes[0].contains("otpless") && identifier.contains("otpless") {
                        let scheme = urlSchemes[0]
//                        let urlScheme = String(scheme).replacingOccurrences(of: "otpless", with: "")
                        let domainUrl = String(link)
                        let completeUrl = domainUrl + "&redirectUri=" + scheme + "://" + identifier
                        return completeUrl
                      }
                }
            }
        }
        return nil
    }
}
