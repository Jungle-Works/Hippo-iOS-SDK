//
//  PaymentField.swift
//  Hippo
//
//  Created by Vishal on 22/02/19.
//

import Foundation

class PaymentField: FormData {
    
    var UId: String
    
    override init?(json: [String : Any]) {
        UId = UUID().uuidString
        
        super.init(json: json)
    }
    
    class func getInitalFields() -> [PaymentField] {
        var fields: [PaymentField] = []
        
        for each in initalPaymentField {
            guard let field = PaymentField(json: each) else {
                continue
            }
            fields.append(field)
        }
        return fields
    }
    class func getPlanNameField(plan: PaymentPlan?) -> [PaymentField] {
        
        guard let field = PaymentField(json: planNameFields) else {
            return []
        }
        field.value = plan?.planName ?? field.value
        return [field]
    }
    
    class func getStaticButtons() -> [PaymentField] {
        var buttons: [PaymentField] = []
        
        for each in defaultButtons {
            guard let button = PaymentField(json: each) else {
                continue
            }
            buttons.append(button)
        }
        
        return buttons
    }
    
    
    static let initalPaymentField: [[String: Any]] = [[
        "validation_type": "ANY",
        "placeholder": "Enter Title",
        "title": "Title",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "title"
        ], [
            "validation_type": "CURRENCY",
            "placeholder": "Currency",
            "title": "Currency",
            "action_value": "United States dollar ($)",
            "is_required": true,
            "type": "TEXTFIELD",
            "key": ""
        ]]
    static let planNameFields: [String: Any] = [
        "validation_type": "ANY",
        "placeholder": "Enter Plan Name",
        "title": "Plan Name",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "plan_name"
    ]
    
    
    static let defaultButtons: [[String: Any]] = [[
        "type": "BUTTON",
        "action": "ADD_MORE",
        "title": "+ \(HippoStrings.addOption)",
        "title_color": "#000000",
        "background_color": "#ffffff"
        ], [
            "type": "BUTTON",
            "action": "SUBMIT",
            "title": HippoStrings.requestPayment,
            "title_color": "#000000",
            "background_color": "#ffffff"
        ]]
    
    static let defaultButtonsWithoutAddMore: [[String: Any]] = [[
        "type": "BUTTON",
        "action": "SUBMIT",
        "title": HippoStrings.requestPayment,
        "title_color": "#000000",
        "background_color": "#ffffff"
        ]]
}
