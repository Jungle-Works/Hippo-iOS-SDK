//
//  PaymentStore.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import Foundation

protocol PaymentStoreDelegate: class {
    func dataUpdate()
}

class PaymentStore: NSObject {
    
    
    var totalPriceUpdated: (() -> ())? = nil
    var fields: [PaymentField] = []
    static var currencies: [PaymentCurrency] = []
    var items: [PaymentItem] = []
    var buttons: [PaymentField] = []
    
    var selectedCurrency: PaymentCurrency?
    var totalCost: Double?
    
    weak var delegate: PaymentStoreDelegate?
    
    override init() {
        super.init()
        
        items = PaymentItem.getInitalItems()
        PaymentStore.currencies = PaymentCurrency.getAllCurrency()
        fields = PaymentField.getInitalFields()
        buttons = PaymentField.getStaticButtons()
        
        selectedCurrency = PaymentStore.currencies.first
    }
    
    func addNewItem() {
        guard let newItem = PaymentItem.getDefaultForm() else {
            return
        }
        items.append(newItem)
        delegate?.dataUpdate()
    }
    
    
    func removeIndex(for item: PaymentItem) {
        let rawIndex = items.lastIndex { (p) -> Bool in
            return p.UId == item.UId
        }
        
        guard let index = rawIndex else {
            return
        }
        items.remove(at: index)
        delegate?.dataUpdate()
    }
    
    
    func validateStore() -> String? {
        for each in fields {
            each.validate()
            if !each.errorMessage.isEmpty {
                return each.errorMessage
            }
        }
        for each in items {
            each.validate()
            if !each.errorMessage.isEmpty {
                return each.errorMessage
            }
        }
        if selectedCurrency == nil {
            return "Please select currency"
        }
        return nil
    }
    
    func getJsonToSend() -> [String: Any] {
        var json: [String: Any] = [:]
        
        for each in fields {
            json += each.getRequestJson()
        }
        var symbol = ""
        if let currency = selectedCurrency {
            symbol = currency.symbol
            json["currency_symbol"]  = currency.symbol
        }
        
        let priceObject = getTotalPriceWithRequest(with: symbol)
        
        json["amount"] = "\(priceObject.totalPrice)"
        json["description"] = priceObject.request
        
        var buttonAction: [String: Any] = [:]
        buttonAction += json
        buttonAction["action_type"] = "NATIVE_ACTIVITY"
        
        
        var actionButton: [String: Any] = [:]
        
        actionButton += buttonAction
        actionButton["button_text"] = "PAY"
        
        json["action_buttons"] = [actionButton]
        
        return json
    }
    
    func getTotalPriceWithRequest(with symbol: String) -> (totalPrice: Double, request: [[String: Any]]) {
        var totalPrice: Double = 0.0
        var description: [[String: Any]] = []
        
        
        for each in items {
            let price = Double(each.priceField.value) ?? 0
            totalPrice += price
            let dict: [String: Any] = ["header": each.descriptionField.value,
                                       "content": "\(symbol) \(price)"]
            description.append(dict)
            
        }
        return (totalPrice, description)
    }
    
}
