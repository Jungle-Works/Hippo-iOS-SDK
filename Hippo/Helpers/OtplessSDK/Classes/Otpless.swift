//
//  Otpless.swift
//  OtplessSDK
//
//  Created by Otpless on 05/02/23.
//

import Foundation



public class Otpless {
    public var buttonText = HippoStrings.continue_to_whatsapp
    public weak var delegate: onResponseDelegate?
    public weak var delegateOnVerify: onVerifyWaidDelegate?
    public static let sharedInstance: Otpless = {
        let instance = Otpless()
        return instance
    }()
    var loader : OtplessLoader? = nil
    private init(){}
        
    
    public func isWhatsappInstalled() -> Bool{
        if UIApplication.shared.canOpenURL(URL(string: "whatsapp://app")! as URL) {
            return true
        } else {
            return false
        }
    }
    public func continueToWhatsapp(url: String){
        UIApplication.shared.open(URL(string: url) ?? URL(fileURLWithPath: ""))
    }
    
    
    public func continueToWhatsapp(){
        if let completeUrl = OtplessHelper.getCompleteUrl() {
            OtplessNetworkHelper.shared.setBaseUrl(url: completeUrl)
            continueToWhatsapp(url: OtplessHelper.addEventDetails(url: completeUrl))
            loader = OtplessLoader()
            loader?.show()
        }
    }
    
    public func isOtplessDeeplink(url : URL) -> Bool{
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true){
            let host = components.host
            switch host {
            case "hippootpless":
                return true
            default:
                break
            }
        }
        return false
    }
    
    public func processOtplessDeeplink(url : URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            let host = components.host
            switch host {
            case "hippootpless":
                if let waId = components.queryItems?.first(where: { $0.name == "waId" })?.value {
                    let mobile = components.queryItems?.first(where: { $0.name == "phone_number" })?.value ?? ""
                    let name = components.queryItems?.first(where: { $0.name == "name" })?.value ?? ""
                    verifywaID(waId: waId, phone: mobile, name: name)
                } else {
                    
                }
            default:
                break
            }
        }
    }
    
    public func clearSession(){
        OtplessHelper.removeUserMobileAndWaid()
    }
    
    private func verifywaID(waId : String, phone: String, name: String){
        OtplessHelper.saveUserMobileAndWaid(waId: waId, userMobile: phone, name: name)
        DispatchQueue.main.async { [self] in
            if((self.delegateOnVerify) != nil){
                delegateOnVerify?.onVerifyWaid(mobile: phone, waId: waId, name: name, message: "success", error: nil)
            }
            
            if((self.delegate) != nil){
                loader?.hide()
                delegate?.onResponse(waId: waId, message: "success", error: nil)
            }
        }
//            let headers = ["Content-Type": "application/json","Accept":"application/json"]
//            let bodyParams = ["userId": waId, "api": "getUserDetail"]
//            OtplessNetworkHelper.shared.fetchData(method: "POST", headers: headers, bodyParams:bodyParams) { (data, response, error) in
//              guard let data = data else {
//
//                  onError(mobile: nil, waId: nil, message: "error", error: "Error in verify waid api error")
//                return
//              }
//                do {
//
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    // process the JSON data
//                    let jsonDictionary = json as? [String: Any]
//                    if let success = jsonDictionary?["success"] as? Bool {
//                        if success{
//                            if let jsonData = jsonDictionary?["data"] as? [String: Any]{
//                                if let mobile = jsonData["userMobile"] as? String,
//                                   let waid = jsonData["waId"] as? String {
//                                    OtplessHelper.saveUserMobileAndWaid(waId: waid, userMobile: mobile)
//                                    DispatchQueue.main.async { [self] in
//                                        if((self.delegateOnVerify) != nil){
//                                            delegateOnVerify?.onVerifyWaid(mobile: mobile, waId: waid, message: "success", error: nil)
//                                        }
//
//                                        if((self.delegate) != nil){
//                                                loader?.hide()
//                                                delegate?.onResponse(waId: waid, message: "success", error: nil)
//                                        }
//
//                                    }
//                                } else {onError(mobile: nil, waId: nil, message: "error", error: "Error in verify waid parse error")}
//                            } else {onError(mobile: nil, waId: nil, message: "error", error: "Error in verify waid parse error")}
//                        } else {onError(mobile: nil, waId: nil, message: "error", error: "Error in verify waid parse error")}
//                    } else {onError(mobile: nil, waId: nil, message: "error", error: "Error in verify waid parse error")}
//                  } catch {
//                      onError(mobile: nil, waId: nil, message: "error", error: "Exception occured verifying waid")
//                  }
//            }
    }
}
private func onError(mobile : String?, waId : String?,name:String?,message: String?, error : String?){
    OtplessHelper.removeUserMobileAndWaid()
    DispatchQueue.main.async {
        if((Otpless.sharedInstance.delegateOnVerify) != nil){
            Otpless.sharedInstance.delegateOnVerify?.onVerifyWaid(mobile: mobile, waId: waId, name: name, message: message, error: error)
        }
        if((Otpless.sharedInstance.delegate) != nil){
                Otpless.sharedInstance.loader?.hide()
                Otpless.sharedInstance.delegate?.onResponse(waId: nil, message: "error", error: error)
            }
        }
    
}
// used for internal purpose by WhatsappLoginButton
public protocol onVerifyWaidDelegate: AnyObject {
    func onVerifyWaid(mobile : String?, waId : String?,name:String?, message: String?, error : String?)
}

// When you want to do direct integration in which you will not be using WhatsappLoginButton
public protocol onResponseDelegate: AnyObject {
    func onResponse(waId : String?, message: String?, error : String?)
}

