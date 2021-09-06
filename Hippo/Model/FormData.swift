//
//  FormData.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class FormData: NSObject {
    var title = ""
    var value = ""
    var isCompleted = true
    var isShow = false
    var isErrorEnabled = false
    var dataType: String = ""
    var errorMessage: String = ""
    var shouldBeEditable: Bool = false
    
    //Dynamic fields
    var validationType: FormValidationType = .any
    var type: FormDataType = .none
    var isRequired: Bool = false
    var placeHolder: String = ""
    var key: String = ""
    var action: FormAction = .none
    var desc: String = ""
    var countryCode: String = "+1"
    
    var backgroundColorHexColor: String = "#fffff"
    var titleColorHexColor: String = "#000000"
    
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    var paramId : Int?
    var param : String?
    var attachmentUrl : [TicketUrl] = []
    
    override init() {
        
    }
    
    init?(json: [String: Any]) {
        super.init()
        isRequired = Bool.parse(key: "is_required", json: json, defaultValue: false)
        placeHolder = json["placeholder"] as? String ?? ""
        key = json["key"] as? String ?? ""
        title = json["title"] as? String ?? ""
        backgroundColorHexColor = json["background_color"] as? String ?? ""
        titleColorHexColor = json["title_color"] as? String ?? ""
        desc = json["description"] as? String ?? ""
        
        
        let validation_type = json["validation_type"] as? String ?? ""
        let rawType = json["type"] as? String ?? ""
        let rawAction = json["action"] as? String ?? ""
        
        
        self.action = FormAction(rawValue: rawAction) ?? .none
        self.type = FormDataType(rawValue: rawType) ?? .none
        self.validationType = FormValidationType(rawValue: validation_type) ?? .any
        
        if let action_value = json["action_value"] as? String, !action_value.isEmpty {
            value = action_value
        }
        setupColor()
        guard isValidForm() else {
            return nil
        }
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String , let dailingCode = isoToDigitCountryCodeDictionary[countryCode] as? String {
            self.countryCode = "+" + dailingCode
        } else {
            self.countryCode = "+1"
        }
    }
    private func setupColor() {
        backgroundColor = HippoConfig.shared.theme.headerBackgroundColor //UIColor.hexStringToUIColor(hex: backgroundColorHexColor)
        titleColor = HippoConfig.shared.theme.headerTextColor //UIColor.hexStringToUIColor(hex: titleColorHexColor)
    }
    
    private func isValidForm() -> Bool {
        guard type != .none else {
            return false
        }
        return true
    }
    
    static func getFormDataList(from json: [String: Any]) -> [FormData] {
        guard let rawFields = json["fields"] as? [[String: Any]], let rawButtons = json["button"] as? [String: Any] else {
            return []
        }
        var fields: [FormData] = []
        var buttons: [FormData] = []
        
        for each in rawFields {
            guard let form = FormData(json: each) else {
                continue
            }
            fields.append(form)
        }
        if let form = FormData(json: rawButtons) {
            buttons.append(form)
        }
        return fields + buttons
    }
    
    static func getArray(object: MessageContent) -> [FormData] {
        var arr = [FormData]()
        var isCompleteFlow = true
        let count = object.questionsArray.count
        
        for i in 0..<count {
            let temp = FormData()
            if object.questionsArray.count > i {
                temp.title = object.questionsArray[i]
            }
            if object.values.count > i {
                if object.paramId.count > i, object.paramId[i] == CreateTicketFields.attachments.rawValue{
                    let dic = getJson(data: object.values[i])
                    if dic.count > 0{
                        temp.value = (dic.first?["fileName"] as? String ?? "") + " and \(dic.count)" + HippoStrings.more
                    }else{
                        temp.value = object.values[i]
                    }
                }else{
                    temp.value = object.values[i]
                }
            }
            if isCompleteFlow {
                temp.isShow = true
            }
            if temp.title.isEmpty || temp.value.isEmpty {
                temp.isCompleted = false
                isCompleteFlow = false
            }
            temp.dataType = object.dataType[i]
            if object.paramId.count > i{
                temp.paramId = object.paramId[i]
            }
            if object.params.count > i{
                temp.param = object.params[i]
            }
            temp.shouldBeEditable = false
            arr.append(temp)
        }
        return arr
        
    }
    
    func getRequestJson() -> [String: Any] {
        var json = [String: Any]()
        let value = self.value.trimWhiteSpacesAndNewLine()
        let key = self.key.trimWhiteSpacesAndNewLine()
        
        switch type {
        case .contactNumber:
            let countryCode = self.countryCode.trimWhiteSpacesAndNewLine()
             if !key.isEmpty, !value.isEmpty {
                json[key] = countryCode + value
            }
        default:
            if !key.isEmpty, !value.isEmpty {
                json[key] = value
            }
        }
        
        
        return json
     }
    func validate() {
        let value = self.value.trimWhiteSpacesAndNewLine()
        
        switch type {
        case .label, .none:
            errorMessage = ""
            return
        default:
            break
        }
        
        if value.isEmpty, isRequired {
            errorMessage = "\(title) \(HippoStrings.fieldEmpty)"
            return
        }
        
        let isValid: Bool
        var isValidCountryCode: Bool = true
        switch (validationType, type) {
        case (.email, _):
            isValid = value.isValidEmail()
        case (.string, _):
            isValid = value.isOnlyString()
        case (.number, _):
            isValid = value.isOnlyNumber()
        case (.contact_number, .contactNumber):
            isValidCountryCode = countryCode.isValidCountryCode()
            isValid = value.isValidPhoneNumber() && isValidCountryCode
        case (.contact_number, _):
            isValid = value.isValidNumberWithCountryCode()
        case (.decimal, _):
            isValid = value.isValidDecimalNumber()
        default:
            isValid = true
        }
        
        if isValid {
            errorMessage = ""
        } else {
            errorMessage = "\(title) is invalid"
        }
        if !isValidCountryCode {
            errorMessage = "Invalid country code"
        }
    }
    
    static func getSkipButton() -> FormData? {
        guard let form = FormData(json: skipButtonForm) else {
            return nil
        }
        form.isShow = true
        
        return form
    }
    
    static func getDummyData() -> [FormData] {
        
        guard let customer_inital_form = formDataJson["customer_initial_form_info"] as? [String: Any] else {
            return []
        }
        return FormData.getFormDataList(from: customer_inital_form)
    }
    
    
    enum FormDataType: String {
        case none = ""
        case textfield = "TEXTFIELD"
        case contactNumber = "CONTACT_NUMBER"
        case label = "LABEL"
        case button = "BUTTON"
    }
    enum FormValidationType: String {
        case none = "NONE"
        case email = "EMAIL"
        case string = "STRING"
        case any = "ANY"
        case number = "NUMBER"
        case contact_number = "PHONE_NUMBER"
        case currency = "CURRENCY"
        case decimal = "DECIMAL"
        
        
        var keyBoardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            case .string:
                return .namePhonePad
            case .number:
                return .numberPad
            case .any:
                return .default
            case .contact_number:
                return .phonePad
            case .decimal:
                return .decimalPad
            default:
                return .default
            }
        }
    }
    
    enum FormAction: String {
        case submit = "SUBMIT"
        case addMore = "ADD_MORE"
        case skip = "SKIP"
        case none = ""
    }
    
    private static let skipButtonForm: [String: Any]  = ["type": "BUTTON",
                                                         "action": "SKIP",
                                                         "title": "skip",
                                                         "title_color": "#000000",
                                                         "background_color": "#ffffff"]
    
    static private func getJson(data: String) -> [[String:Any]] {
        let data = data.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
               return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        return [[String : Any]]()
    }
}

let formDataJson: [String: Any] = [
    "customer_inital_form": [
        "fields": [
            [
                "validation_type": "NONE",
                "placeholder": "",
                "title": "Please Fill below details",
                "description": "To continue you need to fill below details",
                "is_required": true,
                "type": "LABEL",
                "key": ""
            ],
            [
                "validation_type": "ANY",
                "placeholder": "Enter your full name",
                "title": "Name",
                "is_required": true,
                "type": "TEXTFIELD",
                "key": "full_name"
            ],
            [
                "validation_type": "EMAIL",
                "placeholder": "Enter Email",
                "title": "Email",
                "is_required": true,
                "type": "TEXTFIELD",
                "key": "email"
            ],
            [
                "validation_type": "PHONE_NUMBER",
                "placeholder": "Enter Contact Number",
                "title": "Contact Number",
                "is_required": true,
                "type": "CONTACT_NUMBER",
                "key": "phone_number"
            ]
        ],
        "button": [
            "type": "BUTTON",
            "action": "SUBMIT",
            "title": HippoStrings.submit,
            "title_color": "#000000",
            "background_color": "#ffffff"
        ]
    ]
]
