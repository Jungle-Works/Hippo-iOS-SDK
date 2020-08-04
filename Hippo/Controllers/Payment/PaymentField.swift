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
        
        for each in initalPaymentField() {
            guard let field = PaymentField(json: each) else {
                continue
            }
            fields.append(field)
        }
        return fields
    }
    class func getPlanNameField(plan: PaymentPlan?) -> [PaymentField] {
        
        guard let field = PaymentField(json: planNameFields()) else {
            return []
        }
        field.value = plan?.planName ?? field.value
        return [field]
    }
    
    class func getStaticButtons() -> [PaymentField] {
        var buttons: [PaymentField] = []
        
        for each in defaultButtons() {
            guard let button = PaymentField(json: each) else {
                continue
            }
            buttons.append(button)
        }
        
        return buttons
    }
    
    class func getButtonsWithouAddMore() -> [PaymentField] {
        var buttons: [PaymentField] = []
        
        for each in defaultButtonsWithoutAddMore() {
            guard let button = PaymentField(json: each) else {
                continue
            }
            buttons.append(button)
        }
        
        return buttons
    }

    
    static func initalPaymentField()-> [[String: Any]] {
       let initialPaymentField = [[
               "validation_type": "ANY",
               "placeholder": HippoStrings.enterTitle,
               "title": HippoStrings.title,
               "is_required": true,
               "type": "TEXTFIELD",
               "key": "title"
               ], [
                   "validation_type": "CURRENCY",
                   "placeholder": HippoStrings.currency,
                   "title": HippoStrings.currency,
                   "action_value": "United States dollar ($)",
                   "is_required": true,
                   "type": "TEXTFIELD",
                   "key": ""
               ]]
        return initialPaymentField
    }
    
    static func planNameFields() -> [String: Any] {
        let planNameFields = [
            "validation_type": "ANY",
            "placeholder": HippoStrings.enterPlanName,
            "title": HippoStrings.planName,
            "is_required": true,
            "type": "TEXTFIELD",
            "key": "plan_name"
            ] as [String : Any]
        return planNameFields
    }
    
    
    static func defaultButtons() -> [[String: Any]] {
        let defaultButtons =  [[
            "type": "BUTTON",
            "action": "ADD_MORE",
            "title": "\(HippoStrings.addOption)",
            "title_color": "#000000",
            "background_color": "#ffffff"
            ], [
                "type": "BUTTON",
                "action": "SUBMIT",
                "title": HippoStrings.sendPayment,
                "title_color": "#000000",
                "background_color": "#ffffff"
            ]]
        return defaultButtons
    }
    
    static func defaultButtonsWithoutAddMore() -> [[String: Any]] {
        let defaultButtonsWithoutAddMore = [[
        "type": "BUTTON",
        "action": "SUBMIT",
        "title": HippoStrings.sendPayment,
        "title_color": "#000000",
        "background_color": "#ffffff"
        ]]
        return defaultButtonsWithoutAddMore
    }
}
