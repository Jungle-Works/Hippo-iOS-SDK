//
// WhatsappLoginButton.swift
// NotpSDK
//
// Created by Notp on 06/02/23.
//

import UIKit

/// This class inherits all the properties of the button
open class WhatsappLoginButton: UIButton, onVerifyWaidDelegate {

    open var isWhatsAppEnabled = true
    var notpUrl: String = ""
    var apiRoute = "metaverse"
    var redirectURI = ""
    // var buttonText = HippoStrings.continue_to_whatsapp
    private var loader = NotpLoader()
    public weak var delegate: onCallbackResponseDelegate?


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setImageAndTitle()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setImageAndTitle()
    }

    func setImageAndTitle() {
        Notp.sharedInstance.delegateOnVerify = self
        if let image = UIImage(named: "notpwhatsapp.png", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            setImage(image, for: .normal)
        }
        checkWaidExistsAndVerified()
        setTitle(Notp.sharedInstance.buttonText, for: .normal)
        addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        backgroundColor = NotpHelper.UIColorFromRGB(rgbValue: 0x23D366)
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

    public func onVerifyWaid(mobile: String?, countryCode:String?, waId: String?, name: String?, message: String?, error: String?) {
        Notp.sharedInstance.buttonText = Notp.sharedInstance.buttonText
        self.loader.hide()
        manageLabelAndImage()
        if((self.delegate) != nil){
            if error == nil{
                delegate?.onCallbackResponse(waId: waId, message: message, name: name, phone: mobile, countryCode: countryCode, error: error)
            }else{
                delegate?.errorCallback(message: error ?? "")
            }
        }
    }

    @objc private func buttonClicked(){
        self.delegate?.didTapOnButton()

        if isWhatsAppEnabled{
            if !Notp.sharedInstance.isWhatsappInstalled() {
                self.delegate?.errorCallback(message: "Please Install Whatsapp")
            }else{
                let waIdExists = NotpHelper.checkValueExists(forKey: NotpHelper.waidDefaultKey)
                if (waIdExists){
                } else {
                    self.generateQrCode()
                }
            }
        }else{
            return
        }
    }

    public func removeWaidAndContinueToWhatsapp (){
        NotpHelper.removeUserMobileAndWaid()
        Notp.sharedInstance.continueToWhatsapp(url: notpUrl)
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
        let imgVwWidthAndHeight = self.frame.height/2
        let expectedHeightForView = imgVwWidthAndHeight * 7
        let marginBetweenImgVwAndLabel = self.frame.height/8
        let marginLeftAndRight = self.frame.height/4
        var labelWidth = self.frame.width - imgVwWidthAndHeight - marginBetweenImgVwAndLabel - (marginLeftAndRight * 2)
        if labelWidth > expectedHeightForView {
            labelWidth = expectedHeightForView
        }
        let yForImgVw = (self.frame.height - imgVwWidthAndHeight)/2
        if let titleLabel = self.titleLabel ,let imageView = self.imageView {
            if titleLabel.text != Notp.sharedInstance.buttonText{
                setTitle(Notp.sharedInstance.buttonText, for: .normal)
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

        let waIdExists = NotpHelper.checkValueExists(forKey: NotpHelper.waidDefaultKey);
        if (waIdExists){
            let waId = NotpHelper.getValue(forKey:NotpHelper.waidDefaultKey) as String?
            let headers = ["Content-Type": "application/json","Accept":"application/json"]
            let bodyParams = ["userId": waId, "api": "getUserDetail"]
            NotpNetworkHelper.shared.fetchData(method: "POST", headers: headers, bodyParams:bodyParams as [String : Any]) { (data, response, error) in
                guard let data = data else {
                    // handle error
                    if (error != nil) {
                        NotpHelper.removeUserMobileAndWaid()
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
                                Notp.sharedInstance.buttonText = mobile
                                self.manageLabelAndImage()
                            }
                        }
                    }

                } catch {
                    NotpHelper.removeUserMobileAndWaid()
                    // handle error
                }
            }
        }
    }

    func generateQrCode(){
        if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String], let identifier = urlType["CFBundleURLName"] as? String {
                    if urlSchemes.count == 1 && urlSchemes[0].contains("notp") && identifier.contains("notp") {
                        let scheme = urlSchemes[0]
                        let completeUrl = scheme + "://" + identifier
                        self.redirectURI = completeUrl
                    }
                }
            }
        }

        var params = [String : Any]()
        params = ["app_secret_key":HippoConfig.shared.whatsappSecretKey,
                  "get_session": true, "device_type": 2, "redirect_uri":redirectURI] as [String : Any]
        print(params)
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: true, para: params, extendedUrl: AgentEndPoints.generateQrCode.rawValue) { (response, error, _, statusCode) in
            print("generateQrCode \(String(describing: response))")
            if error == nil{
                if let messageDict = ((response) as? [String:Any]){
                    if let data = messageDict["data"] as? [String:Any]{
                        print(data)
                        let url = data["url"] as? String
                        let sessionId = data["session_id"] as? String
                        NotpHelper.link2 = url?.lastPathComponent ?? ""
                        NotpHelper.link = url ?? ""
                        NotpHelper.session_ID = sessionId ?? ""
                        // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        if let completeUrl = NotpHelper.getCompleteUrl() {
                            self.notpUrl = NotpHelper.addEventDetails(url: completeUrl)
                            NotpNetworkHelper.shared.setBaseUrl(url: self.notpUrl)
                        }
                        // })
                        self.loader.show()
                        Notp.sharedInstance.continueToWhatsapp(url: self.notpUrl)
                        self.loader.hide()
                    }
                }
            }else{
                self.delegate?.errorCallback(message: "generateQrCode API Failure")
            }
        }
    }

}

// Implement this protocol to recieve waid in your view controller class when using WhatsappLoginButton
public protocol onCallbackResponseDelegate: AnyObject {
    func onCallbackResponse(waId : String?, message: String?,name:String?,phone: String?,countryCode:String?, error : String?)
    func errorCallback(message:String)
    func didTapOnButton()
}
