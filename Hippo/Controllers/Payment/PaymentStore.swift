//
//  PaymentStore.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
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
    
    
    static let initalPaymentField: [[String: Any]] = [[
        "validation_type": "ANY",
        "placeholder": "Title",
        "title": "Title",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Title"
        ], [
            "validation_type": "ANY",
            "placeholder": "Enter your full name",
            "title": "Name",
            "is_required": true,
            "type": "TEXTFIELD",
            "key": "full_name"
        ]]
}

class PaymentItem: NSObject {
    
    var UId: String
    
    override init() {
        UId = UUID().uuidString
    }
    
    class func getInitalItems() -> [PaymentItem] {
        let singleItem = PaymentItem()
        return [singleItem]
    }
 }

class PaymentCurrency {
    private static var currencies: [PaymentCurrency] = []
    
    init(json: [String: Any]) {
        
    }
    
    class func getAllCurrency() -> [PaymentCurrency] {
        guard currencies.isEmpty else {
            return currencies
        }
        var list: [PaymentCurrency] = []
        
        for each in currencyJson {
            let currency = PaymentCurrency(json: each)
            list.append(currency)
        }
        
        currencies = list
        return currencies
    }
}

class PaymentStore: NSObject {
    var fields: [PaymentField] = []
    var currencies: [PaymentCurrency] = []
    var items: [PaymentItem] = []
    
    
    override init() {
        super.init()
        
        items = PaymentItem.getInitalItems()
        currencies = PaymentCurrency.getAllCurrency()
        fields = PaymentField.getInitalFields()
    }
}

let currencyJson: [[String: Any]] = []

