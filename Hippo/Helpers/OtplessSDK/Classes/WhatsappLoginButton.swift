//
//  WhatsappLoginButton.swift
//  OtplessSDK
//
//  Created by Otpless on 06/02/23.
//

import UIKit

public final class WhatsappLoginButton: UIButton, onVerifyWaidDelegate {
    
    
    
    var otplessUrl: String = ""
    var apiRoute = "metaverse"
//    var buttonText = HippoStrings.continue_to_whatsapp
    private var loader = OtplessLoader()
    public weak var delegate: onCallbackResponseDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setImageAndTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setImageAndTitle()
    }
    
    func setImageAndTitle() {
        
        if !Otpless.sharedInstance.isWhatsappInstalled() {
            self.isHidden = true
        }
        
        Otpless.sharedInstance.delegateOnVerify = self
        if let image = UIImage(named: "otplesswhatsapp.png", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            setImage(image, for: .normal)
        }
        checkWaidExistsAndVerified()
        setTitle(Otpless.sharedInstance.buttonText, for: .normal)
        addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        backgroundColor = OtplessHelper.UIColorFromRGB(rgbValue: 0x23D366)
        setTitleColor(UIColor.white, for: UIControl.State.normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    func starifyNumber(number: String) -> String {
        let intLetters = number.prefix(3)
        let endLetters = number.suffix(2)
        let numberOfStars = number.count - (intLetters.count + endLetters.count)
        var starString = ""
        for _ in 1...numberOfStars {
            starString += "*"
        }
        let finalNumberToShow: String = intLetters + starString + endLetters
        return finalNumberToShow
    }
    
    public func onVerifyWaid(mobile: String?, waId: String?, name: String?, message: String?, error: String?) {
        //        DispatchQueue.main.async { [self] in
        let number = starifyNumber(number: mobile ?? Otpless.sharedInstance.buttonText)
        Otpless.sharedInstance.buttonText = number
        self.loader.hide()
        manageLabelAndImage()
        if((self.delegate) != nil){
            delegate?.onCallbackResponse(waId: waId, message: message, name: name, phone: mobile, error: error)
        }
        //        }
    }
    
    
    @objc private func buttonClicked(){
//        removeWaidAndContinueToWhatsapp()
        //        self.loader.show()
        let waIdExists = OtplessHelper.checkValueExists(forKey: OtplessHelper.waidDefaultKey)
        if (waIdExists){
            //            let waId = OtplessHelper.getValue(forKey:OtplessHelper.waidDefaultKey) as String?
            //            let headers = ["Content-Type": "application/json","Accept":"application/json"]
            //            let bodyParams = ["userId": waId, "api": "getUserDetail"]
            //            OtplessNetworkHelper.shared.fetchData(method: "POST", headers: headers, bodyParams:bodyParams as [String : Any]) { [self] (data, response, error) in
            //              guard let data = data else {
            //                // handle error
            //                  removeWaidAndContinueToWhatsapp()
            //                return
            //              }
            //                do {
            //                    let json = try JSONSerialization.jsonObject(with: data, options: [])
            //                    // process the JSON data
            //                    let jsonDictionary = json as? [String: Any]
            //                    if let success = jsonDictionary?["success"] as? Bool {
            //                        if success{
            //                            if let jsonData = jsonDictionary?["data"] as? [String: Any]{
            //                                if let mobile = jsonData["userMobile"] as? String {
            //                                    DispatchQueue.main.async { [self] in
            //                                        buttonText = mobile
            //                                        manageLabelAndImage()
            //                                        if((self.delegate) != nil){
            //                                            delegate?.onCallbackResponse(waId: waId!, message: "success", error: nil)
            //                                            self.loader.hide()
            //                                        }
            //                                    }
            //                                } else {removeWaidAndContinueToWhatsapp()}
            //                            } else {removeWaidAndContinueToWhatsapp()}
            //                        } else {
            //                            removeWaidAndContinueToWhatsapp()
            //                        }
            //                    } else {
            //                        removeWaidAndContinueToWhatsapp()
            //                    }
            //
            //                  } catch {
            //                      removeWaidAndContinueToWhatsapp()
            //                  }
            //            }
            
            
        } else {
            self.generateQrCode()
        }
    }
    
    public func removeWaidAndContinueToWhatsapp (){
        OtplessHelper.removeUserMobileAndWaid()
        Otpless.sharedInstance.continueToWhatsapp(url: otplessUrl)
    }
    
    public func show(){
        self.isHidden = false
    }
    
    public func hide(){
        self.isHidden = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        manageLabelAndImage()
    }
    
    func manageLabelAndImage(){
        
        let imgVwWidthAndHeight =  self.frame.height/2
        let expectedHeightForView = imgVwWidthAndHeight * 7
        
        let marginBetweenImgVwAndLabel = self.frame.height/8
        let marginLeftAndRight = self.frame.height/4
        var labelWidth = self.frame.width - imgVwWidthAndHeight - marginBetweenImgVwAndLabel - (marginLeftAndRight * 2)
        if labelWidth > expectedHeightForView {
            labelWidth = expectedHeightForView
        }
        let yForImgVw = (self.frame.height - imgVwWidthAndHeight)/2
        
        if let titleLabel = self.titleLabel ,let imageView = self.imageView  {
            if titleLabel.text != Otpless.sharedInstance.buttonText{
                setTitle(Otpless.sharedInstance.buttonText, for: .normal)
            }
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 1
            titleLabel.sizeToFit()
            if titleLabel.frame.width > labelWidth {
                titleLabel.frame = CGRect(x: (self.frame.width - labelWidth + imgVwWidthAndHeight + marginBetweenImgVwAndLabel)/2 , y: yForImgVw, width: labelWidth , height: imgVwWidthAndHeight)
            }
            titleLabel.frame = CGRect(x: (self.frame.width - titleLabel.frame.width + imgVwWidthAndHeight + marginBetweenImgVwAndLabel)/2 , y: yForImgVw, width: titleLabel.frame.width , height: imgVwWidthAndHeight)
            
            imageView.frame = CGRect(x:(self.frame.width - titleLabel.frame.width - imgVwWidthAndHeight - marginBetweenImgVwAndLabel)/2, y: yForImgVw, width: imgVwWidthAndHeight, height:imgVwWidthAndHeight)
            
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor=0.001
        }
        layer.cornerRadius = self.frame.height * 0.14
        layer.masksToBounds = true
    }
    
    func checkWaidExistsAndVerified (){
        
        let waIdExists = OtplessHelper.checkValueExists(forKey: OtplessHelper.waidDefaultKey);
        if (waIdExists){
            let waId = OtplessHelper.getValue(forKey:OtplessHelper.waidDefaultKey) as String?
            
            let headers = ["Content-Type": "application/json","Accept":"application/json"]
            let bodyParams = ["userId": waId, "api": "getUserDetail"]
            OtplessNetworkHelper.shared.fetchData(method: "POST", headers: headers, bodyParams:bodyParams as [String : Any]) { (data, response, error) in
                guard let data = data else {
                    // handle error
                    if (error != nil) {
                        OtplessHelper.removeUserMobileAndWaid()
                    }
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    // process the JSON data
                    let jsonDictionary = json as? [String: Any]
                    if let jsonData = jsonDictionary?["data"] as? [String: Any]{
                        if let mobile = jsonData["userMobile"] as? String {
                            DispatchQueue.main.async {
                                Otpless.sharedInstance.buttonText = mobile
                                self.manageLabelAndImage()
                            }
                        }
                    }
                    
                } catch {
                    OtplessHelper.removeUserMobileAndWaid()
                    // handle error
                }
            }
        }
    }
    
    func generateQrCode(){
        var params = [String : Any]()
        params = ["app_secret_key":HippoConfig.shared.appSecretKey,
                  "get_session": true] as [String : Any]
        print(params)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: true, para: params, extendedUrl: AgentEndPoints.generateQrCode.rawValue) { (response, error, _, statusCode) in
            print("generateQrCode \(String(describing: response))")
            if error == nil{
                if let messageDict = ((response) as? [String:Any]){
                    if let data = messageDict["data"] as? [String:Any]{
                        print(data)
                        let url = data["url"] as? String
                        OtplessHelper.link2 = url?.lastPathComponent ?? ""
                        OtplessHelper.link =  url ?? ""
                        
                        //                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        if let completeUrl = OtplessHelper.getCompleteUrl() {
                            self.otplessUrl = OtplessHelper.addEventDetails(url: completeUrl)
                            OtplessNetworkHelper.shared.setBaseUrl(url: self.otplessUrl)
                        }
                        //                        })
                        self.loader.show()
                        Otpless.sharedInstance.continueToWhatsapp(url: self.otplessUrl)
                        self.loader.hide()
                    }
                }
            }
        }
    }
    
}
// Implement this protocol to recieve waid in your view controller class when using WhatsappLoginButton
public protocol onCallbackResponseDelegate: AnyObject {
    func onCallbackResponse(waId : String?, message: String?,name:String?,phone: String?, error : String?)
}

