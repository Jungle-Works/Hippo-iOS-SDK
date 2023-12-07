//
//  Notp.swift
//  NotpSDK
//
//  Created by Notp on 05/02/23.
//

import Foundation

@objc public class Notp: NSObject {
    public var buttonText = HippoStrings.continue_to_whatsapp
    public var buttonImage = ""
    public weak var delegate: onResponseDelegate?
    public weak var delegateOnVerify: onVerifyWaidDelegate?
    @objc public static let sharedInstance: Notp = {
        let instance = Notp()
        return instance
    }()
    var loader : NotpLoader? = nil
//    private init(){}
    
    
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
        if let completeUrl = NotpHelper.getCompleteUrl() {
            NotpNetworkHelper.shared.setBaseUrl(url: completeUrl)
            continueToWhatsapp(url: NotpHelper.addEventDetails(url: completeUrl))
            loader = NotpLoader()
            loader?.show()
        }
    }
    
    @objc  public func isNotpDeeplink(url : URL) -> Bool{
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true){
            let host = components.host
            switch host {
            case "hipponotp":
                return true
            default:
                break
            }
        }
        return false
    }
    
    @objc  public func processNotpDeeplink(url : URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            let host = components.host
            switch host {
            case "hipponotp":
                if let waId = components.queryItems?.first(where: { $0.name == "waId" })?.value {
                    let mobile = components.queryItems?.first(where: { $0.name == "phone_number" })?.value ?? ""
                    let name = components.queryItems?.first(where: { $0.name == "name" })?.value ?? ""
                    if waId == NotpHelper.session_ID{
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                            self.getAndUpdateOTPStatusAPI(waID:waId)
                        })
                        
                    }else{
                        self.delegateOnVerify?.onVerifyWaid(mobile: "",countryCode:"", waId: "", name: "", message: "", error: "Session id and Whatsapp id does not match")
                    }
                } else {
                    
                }
            default:
                break
            }
        }
    }
    
    public func clearSession(){
        NotpHelper.removeUserMobileAndWaid()
    }
    
    private func verifywaID(waId : String,code:String, phone: String, name: String){
        NotpHelper.saveUserMobileAndWaid(waId: waId, countryCode:code, userMobile: phone, name: name)
        DispatchQueue.main.async { [self] in
            if((self.delegateOnVerify) != nil){
                delegateOnVerify?.onVerifyWaid(mobile: phone,countryCode:code, waId: waId, name: name, message: "success", error: nil)
            }
            if((self.delegate) != nil){
                loader?.hide()
                delegate?.onResponse(waId: waId, message: "success", error: nil)
            }
        }
    }
    
    
    func getAndUpdateOTPStatusAPI(waID:String){
        var params = [String : Any]()
        params = ["session_id":waID,
                  "get_status": 1] as [String : Any]
        print(params)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: true, para: params, extendedUrl: AgentEndPoints.getUpdateOTPStatus.rawValue) { (response, error, _, statusCode) in
            print("getUpdateOTPStatus \(String(describing: response))")
            if error == nil{
                if let messageDict = ((response) as? [String:Any]){
                    if let data = messageDict["data"] as? [String:Any]{
                        if let userData = data["user_data"] as? [String:Any]{
                            let name = userData["name"] as? String ?? ""
                            if let contactData = userData["contact_number"] as? [String:Any]{
                                let countryCode = contactData["code"] as? String ?? ""
                                let mobile = contactData["number"] as? String ?? ""
                                self.verifywaID(waId: waID, code: countryCode, phone: mobile, name: name)
                            }
                        }
                    }
                }
            }else{
                self.delegateOnVerify?.onVerifyWaid(mobile: "",countryCode:"", waId: "", name: "", message: "", error: "getUpdateOTPStatus API Failure")
            }
        }
    }
    
    private func onError(mobile : String?,countryCode :String?, waId : String?,name:String?,message: String?, error : String?){
        NotpHelper.removeUserMobileAndWaid()
        DispatchQueue.main.async {
            if((Notp.sharedInstance.delegateOnVerify) != nil){
                Notp.sharedInstance.delegateOnVerify?.onVerifyWaid(mobile: mobile, countryCode: countryCode, waId: waId, name: name, message: message, error: error)
            }
            if((Notp.sharedInstance.delegate) != nil){
                Notp.sharedInstance.loader?.hide()
                Notp.sharedInstance.delegate?.onResponse(waId: nil, message: "error", error: error)
            }
        }
        
    }
}
// used for internal purpose by WhatsappLoginButton
public protocol onVerifyWaidDelegate: AnyObject {
    func onVerifyWaid(mobile : String?,countryCode:String?, waId : String?,name:String?, message: String?, error : String?)
}

// When you want to do direct integration in which you will not be using WhatsappLoginButton
public protocol onResponseDelegate: AnyObject {
    func onResponse(waId : String?, message: String?, error : String?)
}

