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
    var errorMessage: String = ""
    
    
    
    init(priceDetail: PaymentField, descDetail: PaymentField) {
        UId = UUID().uuidString
        self.priceField = priceDetail
        self.descriptionField = descDetail
    }
    
    
    class func getDefaultForm() -> PaymentItem? {
        guard let priceForm = PaymentField(json: defaultPriceItem) else {
            return nil
        }
        guard let descriptionForm = PaymentField(json: defaultDescriptionItem) else {
            return nil
        }
        
        let item = PaymentItem(priceDetail: priceForm, descDetail: descriptionForm)
        return item
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
        
        if !descriptionField.errorMessage.isEmpty {
             errorMessage = descriptionField.errorMessage
        } else if !priceField.errorMessage.isEmpty {
            errorMessage = priceField.errorMessage
        } else {
            errorMessage = ""
        }
        
    }
    
    static let defaultDescriptionItem: [String: Any] = [
        "validation_type": "ANY",
        "placeholder": "Item Description",
        "title": "Item Description",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Title"
    ]
    static let defaultPriceItem: [String: Any] = [
        "validation_type": "DECIMAL",
        "placeholder": "Price",
        "title": "Price",
        "is_required": true,
        "type": "TEXTFIELD",
        "key": "Price"
    ]
}
