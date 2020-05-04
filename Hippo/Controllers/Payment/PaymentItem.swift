//
//  PaymentItem.swift
//  Hippo
//
//  Created by Vishal on 22/02/19.
//

import Foundation


class PaymentItem: NSObject {
    
    var UId: String
    var priceField: PaymentField
    var descriptionField: PaymentField
    var titleField: PaymentField
    var errorMessage: String = ""
    var id: String?
    
    var currency: PaymentCurrency?
    
    
    
    init(priceDetail: PaymentField, descDetail: PaymentField, titleField: PaymentField) {
        UId = UUID().uuidString
        self.priceField = priceDetail
        self.descriptionField = descDetail
        self.titleField = titleField
    }
    
    init?(option: [String: Any]) {
        UId = UUID().uuidString
        
        guard let priceForm = PaymentField(json: PaymentItem.defaultPriceItem) else {
            return nil
        }
        guard let descriptionForm = PaymentField(json: PaymentItem.defaultDescriptionItem) else {
            return nil
        }
        guard let titleForm = PaymentField(json: PaymentItem.defaultTitleItem) else {
            return nil
        }
        priceForm.value = String.parse(values: option, key: "amount") ?? priceForm.value
        descriptionForm.value = String.parse(values: option, key: "description") ?? descriptionForm.value
        titleForm.value = String.parse(values: option, key: "title") ?? titleForm.value
        
        self.priceField = priceForm
        self.descriptionField = descriptionForm
        self.titleField = titleForm
        
        id = String.parse(values: option, key: "id")
        let currencyCode: String? = String.parse(values: option, key: "currency")
        let currencySymbol: String? = String.parse(values: option, key: "currency_symbol")
        currency = PaymentCurrency.findCurrency(code: currencyCode, symbol: currencySymbol)
        
    }
    
    class func getDefaultForm() -> PaymentItem? {
        guard let priceForm = PaymentField(json: defaultPriceItem) else {
            return nil
        }
        guard let descriptionForm = PaymentField(json: defaultDescriptionItem) else {
            return nil
        }
        guard let titleForm = PaymentField(json: defaultTitleItem) else {
            return nil
        }
        
        let item = PaymentItem(priceDetail: priceForm, descDetail: descriptionForm, titleField: titleForm)
        return item
    }
    
    class func parses(options: [[String: Any]]) -> [PaymentItem] {
        var list: [PaymentItem] = []
        
        for option in options {
            guard let item = PaymentItem(option: option) else {
                continue
            }
            list.append(item)
        }
        
        return list
    }
    
    
    class func getInitalItems() -> [PaymentItem] {
        guard let singleItem = getDefaultForm() else {
            return []
        }
        return [singleItem]
    }
    
    func validate() {
        descriptionField.validate()
        priceField.validate()
        titleField.validate()
        
        if !titleField.errorMessage.isEmpty {
            errorMessage = titleField.errorMessage
        } else if !descriptionField.errorMessage.isEmpty {
            errorMessage = descriptionField.errorMessage
        } else if !priceField.errorMessage.isEmpty {
            errorMessage = priceField.errorMessage
        } else {
            errorMessage = ""
        }
        
    }
    
    static let defaultDescriptionItem: [String: Any] = [
        "validation_type": "ANY",
        "placeholder": "Enter Description",
        "title": "Description",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Title"
    ]
    static let defaultPriceItem: [String: Any] = [
        "validation_type": "DECIMAL",
        "placeholder": "Enter Price",
        "title": "Price",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Price"
    ]
    static let defaultTitleItem: [String: Any] = [
        "validation_type": "ANY",
        "placeholder": "Enter Title",
        "title":  "Title",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Title"
    ]
}
