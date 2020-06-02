//
//  PaymentStore.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import UIKit

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
    var totalCostEnabled: Bool = false
    var canAddMore: Bool = false
    
    var displayEditButton: Bool = false
    var isUpdating: Bool = false
    
    var isEditing: Bool = true {
        didSet {
            editingValueUpdated()
        }
    }
    var channelId: UInt?
    var plan: PaymentPlan?
    var title: String = "Payment Plan"
    var isSending: Bool = true
    
    
    weak var delegate: PaymentStoreDelegate?
    
    init(channelId: UInt) {
        
        self.channelId = channelId
        
        super.init()
        
        items = PaymentItem.getInitalItems()
        PaymentStore.currencies = PaymentCurrency.getAllCurrency()
        if HippoConfig.shared.appUserType == .agent{
            fields = [] //PaymentField.getInitalFields()
        }else{
            fields = PaymentField.getInitalFields()
        }
        
        buttons = PaymentField.getStaticButtons()
        
        if HippoConfig.shared.appUserType == .agent{
            selectedCurrency = PaymentCurrency.findCurrency(code: "INR", symbol: nil) ?? PaymentStore.currencies.first
        }else{
            selectedCurrency = PaymentStore.currencies.first
        }
    }
    init(plan: PaymentPlan?, channelId: UInt? = nil, isEditing: Bool, isSending: Bool) {
        self.plan = plan
        self.channelId = channelId
        self.isEditing = isEditing
        self.displayEditButton = (plan?.canEdit ?? false && channelId == nil)
        items = plan?.options ?? PaymentItem.getInitalItems()
        if !isSending {
            fields = PaymentField.getPlanNameField(plan: plan)
        }
        selectedCurrency = plan?.currency ?? PaymentCurrency.findCurrency(code: "INR", symbol: nil) ?? PaymentStore.currencies.first
        title = plan?.planName ?? "Plan"
        self.isSending = isSending
        super.init()
        self.editingValueUpdated()
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
    
    internal func editingValueUpdated() {
        if isEditing {
            buttons = PaymentField.getStaticButtons()
            let text: String
            if channelId != nil  {
                text = "Request Payment"
            } else if plan == nil && channelId == nil {
                text = "Save Plan"
            } else {
                text = "Update Plan"
            }
            
            for each in buttons {
                if each.action == .submit {
                    each.title = text
                }
            }
        } else {
            buttons = []
        }
        self.delegate?.dataUpdate()
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
    
    func getItems(withTransactionId: Bool = true) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for (index, item) in items.enumerated() {
            var dict: [String: Any] = [ "id": index + 1,
                                        "title": item.titleField.value,
                                        "description": item.descriptionField.value,
                                        "amount": Double(item.priceField.value) ?? 0,
                                        "currency": item.currency?.code ?? "INR",
                                        "currency_symbol": item.currency?.symbol ?? "₹"]
            
            if withTransactionId {
                dict["transaction_id"] = String.generateUniqueId()
            }
            list.append(dict)
        }
        
        return list
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
    
    static func generatePaymentUrl(channelId: Int, message: HippoMessage, selectedCard: CustomerPayment, selectedPaymentGateway: PaymentGateway?, completion: @escaping ((_ success: Bool, _ data: [String: Any]?) -> ())) {
        guard let enUserId = HippoUserDetail.fuguEnUserID else {
            completion(false, nil)
            return
        }
        var param: [String: Any] = ["channel_id": channelId,
                                    "en_user_id": enUserId,
                                    "app_secret_key": HippoConfig.shared.appSecretKey]
        
        param["items"] = [selectedCard.getJsonForMakePayment()]
        
        param["is_multi_gateway_flow"] = 1
        if let selectedPaymentGatewayId = selectedPaymentGateway?.gateway_id{
            param["payment_gateway_id"] = selectedPaymentGatewayId
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, enCodingType: .json, para: param, extendedUrl: FuguEndPoints.makeSelectedPayment.rawValue) { (response, error, tag, status) in
            if let err = error {
                showAlertWith(message: err.localizedDescription, action: nil)
                completion(false, nil)
            }
            guard let r = response as? [String: Any], let data = r["data"] as? [String: Any] else {
                completion(false, nil)
                return
            }
            completion(true, data)
        }
    }
    
}

extension PaymentStore {
    
    func takeAction(completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
        if channelId != nil {
            sendPayment(completion: completion)
        } else {
            addUpdatePlan(completion: completion)
        }
    }
    
    
    func sendPayment(completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
//        guard let accessToken = PersonInfo.getAccessToken(), let channelId = self.channelId else {
//            completion(false, nil)
//            return
//        }
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken, let channelId = self.channelId else {
            completion(false, nil)
            return
        }
        
        var param: [String: Any] = ["access_token": accessToken,
                                    "channel_id": channelId]
        
        let items = getItems()
        param["items"] = items
        
//        if items.count > 1 {
//            param["is_message_only"] = 1
//        }
        param["is_message_only"] = 1
        
//        HTTPRequest(method: .post, path: EndPoints.sendPayment, parameters: param, encoding: .json, files: nil)
//            .config(isIndicatorEnable: true, isAlertEnable: true)
//            .handler { (response) in
//                completion(response.isSuccess, nil)
//        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: AgentEndPoints.sendPayment.rawValue) { (response, error, _, statusCode) in
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_SendPayment ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false, error)
                    return
            }
            completion(true, nil)
        }
        
    }
    
    func addUpdatePlan(completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
//        guard let accessToken = PersonInfo.getAccessToken() else {
//            completion(false, nil)
//            return
//        }
        guard let accessToken = HippoConfig.shared.agentDetail?.fuguToken else {
            completion(false, nil)
            return
        }
        var param: [String: Any] = ["access_token": accessToken]
        
        for each in fields {
            param += each.getRequestJson()
        }
        param["type"] = self.plan?.type.rawValue ?? PaymentPlanType.agentPlan.rawValue
        
        if let plan = plan, plan.planId > 0 {
            param["plan_id"] = plan.planId
            param["operation_type"] = 1
        }
        
        let items = getItems(withTransactionId: false)
        param["plans"] = items
//        Helper.log.debug("Parama == \(param)", level: .request)
        HippoConfig.shared.log.debug("Parama == \(param)", level: .request)
        
//        HTTPRequest.init(method: .post, path: EndPoints.editPaymentPlans, parameters: param, encoding: .json, files: nil)
//            .config(isIndicatorEnable: true, isAlertEnable: true)
//            .handler { (response) in
//                //                print(response)
//                completion(response.isSuccess, nil)
//        }
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: AgentEndPoints.editPaymentPlans.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_EditPaymentPlans ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false, error)
                    return
            }
            completion(true, nil)
        }
        
    }
}
