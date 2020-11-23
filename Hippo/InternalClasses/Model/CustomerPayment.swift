//
//  CustomerPayment.swift
//  HippoChat
//
//  Created by Vishal on 04/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

struct ViewLayout {
    var leading: CGFloat
    var trailing: CGFloat
    var top: CGFloat
    var bottom: CGFloat
    
    var verticleHeight: CGFloat {
        return top + bottom
    }
    var horizontalWidth: CGFloat {
        return leading + trailing
    }
    
    init(){
        self.leading = 0
        self.trailing = 0
        self.top = 0
        self.bottom = 0
    }
    
    init(leading: CGFloat, trailing: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.leading = leading
        self.trailing = trailing
        self.top = top
        self.bottom = bottom
    }
    
    init(equalMargin: CGFloat) {
        self.leading = equalMargin
        self.trailing = equalMargin
        self.top = equalMargin
        self.bottom = equalMargin
    }
}
struct PaymentCardConfig {
    var bgView: ViewLayout = ViewLayout()
    var innerCard: ViewLayout = ViewLayout()
    var labelView: ViewLayout = ViewLayout()
    var imageWidth: CGFloat = CGFloat()
    var labelSpacing: CGFloat = CGFloat()
    var amountWidth: CGFloat = 100
    
    
   
    
    
    static func defaultConfig() -> PaymentCardConfig {
//        let bgView = ViewLayout(leading: 45, trailing: 15, top: 3, bottom: 0)
//        let innerCard = ViewLayout(equalMargin: 5)
//        let labelView = ViewLayout(equalMargin: 10)
//
//        let imageWidth: CGFloat = 0
//        return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
        if HippoConfig.shared.appUserType == .agent{
            let bgView = ViewLayout(leading: 20, trailing: 20, top: 3, bottom: 0)
            let innerCard = ViewLayout(equalMargin: 5)
            let labelView = ViewLayout(equalMargin: 10)
            let imageWidth: CGFloat = 0
            return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
        }else{
            let bgView = ViewLayout(leading: 10, trailing: 10, top: 10, bottom: 10)
            let innerCard = ViewLayout(equalMargin: 5)
            let labelView = ViewLayout(equalMargin: 10)
            let imageWidth: CGFloat = 0
            return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
        }
    }
    
      static func bottomConfig() -> PaymentCardConfig {
    //        let bgView = ViewLayout(leading: 45, trailing: 15, top: 3, bottom: 0)
    //        let innerCard = ViewLayout(equalMargin: 5)
    //        let labelView = ViewLayout(equalMargin: 10)
    //
    //        let imageWidth: CGFloat = 0
    //        return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
            if HippoConfig.shared.appUserType == .agent{
                let bgView = ViewLayout(leading: 20, trailing: 20, top: 3, bottom: 0)
                let innerCard = ViewLayout(equalMargin: 5)
                let labelView = ViewLayout(equalMargin: 10)
                let imageWidth: CGFloat = 0
                return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
            }else{
                let bgView = ViewLayout(leading: 10, trailing: 10, top: 5, bottom: 0)
                let innerCard = ViewLayout(equalMargin: 5)
                let labelView = ViewLayout(equalMargin: 10)
                let imageWidth: CGFloat = 0
                return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
            }
        }
    
}

struct PaymentSecurely {
    var image: UIImage?
    var imageTintColor: UIColor?
    var attributedText: NSMutableAttributedString?
    
    var bgViewLayout: ViewLayout = ViewLayout(leading: 10, trailing: 10, top: 5, bottom: 5)
    var labelContainerLayout: ViewLayout = ViewLayout(equalMargin: 0)
    var calculatedHeight: CGFloat = 0
    var imageWidth: CGFloat = 0
    
    var height: CGFloat = 0
    
    
    static func secrurePaymentOption() -> PaymentSecurely {
        var option = PaymentSecurely()
        let theme = HippoConfig.shared.theme
        
        let headerAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: HippoConfig.shared.theme.darkThemeTextColor,
                                                               NSAttributedString.Key.font: theme.secureTextFont]
//        let secondAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.black,
//                                                                      NSAttributedString.Key.font: theme.secureTextFont]
        
        let headerAttributed = NSMutableAttributedString(string: HippoStrings.hippoSecurePayment, attributes: headerAttributes)
//        let secondAttributed = NSMutableAttributedString(string: "\nDiet Buddy Gurantee", attributes: secondAttributes)
        
//        headerAttributed.append(secondAttributed)
        
        option.attributedText = headerAttributed
        option.image = HippoConfig.shared.theme.securePaymentIcon
        option.imageTintColor = HippoConfig.shared.theme.securePaymentTintColor
        option.imageWidth = 30
        option.labelContainerLayout = ViewLayout(leading: 0, trailing: 0, top: 0, bottom: 0)
        option.calculateHeight()
        
        return option
    }
    
    mutating func calculateHeight() {
        guard let attributtedString = self.attributedText else {
            self.height = 0
            return
        }
        
        let width = FUGU_SCREEN_WIDTH - bgViewLayout.horizontalWidth - labelContainerLayout.horizontalWidth - imageWidth
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let h: CGFloat = attributtedString.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        height = h + bgViewLayout.verticleHeight + labelContainerLayout.verticleHeight + 5
    }
}

extension PaymentSecurely: HippoCard {
    var cardHeight: CGFloat {
        return height
    }
}

class PaymentHeader {
    var text: String = HippoStrings.selectaPlan
}

extension PaymentHeader: HippoCard {
    var cardHeight: CGFloat {
        return 40
    }
}

class PayementButton {
    let title: String
    let attributedTitle: NSMutableAttributedString?
    var selectedCardDetail: CustomerPayment?
    var showAmount: Bool = true
    
    init(title: String) {
        self.title = title
        self.attributedTitle = nil
    }
    init(attributedString: NSMutableAttributedString) {
        self.title = ""
        self.attributedTitle = attributedString
    }
    
    static func createPaymentOption() -> PayementButton {
//        let textAtributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        let textAttributed = NSMutableAttributedString(string: "  Securely Pay", attributes: textAtributes)
//
//        let image1Attachment = NSTextAttachment()
//        image1Attachment.image = UIImage(named: "lockIcon", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//        let image1String = NSMutableAttributedString(attachment: image1Attachment)
//        image1String.append(textAttributed)
//
//        let button = PayementButton(attributedString: image1String)
//        return button
        let button = PayementButton(title: HippoStrings.proccedToPay)
        return button
    }
}

extension PayementButton: HippoCard {
    var cardHeight: CGFloat {
       return 50
    }
}

public class PaymentGateway {
    public let gateway_id: Int?
    public var business_id: Int?
    public var gateway_name: String?
    public var gateway_image: String?
    public var currency_allowed: [String]?

    init?(json: [String: Any]) {
        self.gateway_id = Int.parse(values: json, key: "gateway_id")
        self.business_id = Int.parse(values: json, key: "business_id")
        self.gateway_name = String.parse(values: json, key: "gateway_name")
        self.gateway_image = String.parse(values: json, key: "gateway_image")
        self.currency_allowed = json["currency_allowed"] as? [String] ?? []
    }
    
    static func parse(addedPaymentGateways: [[String: Any]]) -> [PaymentGateway] {
        var list: [PaymentGateway] = []
        for addedPaymentGateway in addedPaymentGateways {
            guard let p = PaymentGateway(json: addedPaymentGateway) else {
                continue
            }
            list.append(p)
        }
        return list
    }
    
}

class CustomerPayment {
    let title: String
    var description: String
    var amount: Double?
    var currency: String?
    var paymentUrlString: String?
    var id: String
    var discount: String = ""
    var currenySymbol: String?
    var cardConfig: PaymentCardConfig = PaymentCardConfig.defaultConfig()
    var height: CGFloat = .zero
    var isPaid: Bool = false
    var isLocalySelected: Bool = false
    var transactionId: String?
    
    var displayAmount: NSAttributedString {
        let theme = HippoConfig.shared.theme
        var amountText: String = HippoStrings.free
        let currencySymbol: String = currenySymbol?.trimWhiteSpacesAndNewLine() ?? ""
        if let temp = amount, temp > 0 {
            amountText = "\(currencySymbol) \(temp)"
        }
        let range = (amountText as NSString).range(of: amountText)
        let attributedString = NSMutableAttributedString(string: amountText)
        let attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: theme.pricingFont,
                                                   NSAttributedString.Key.foregroundColor: theme.pricingTextColor ?? theme.headerBackgroundColor]
        attributedString.addAttributes(attr, range: range)
        
        let paidString = isPaid ? "\n \(HippoStrings.paymentPaid)" : "\n \(HippoStrings.paymentPending)"
        let paidRange = (paidString as NSString).range(of: paidString)
        let paidAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: theme.descriptionFont]
        
        let paidAttributedString = NSMutableAttributedString(string: paidString)
        paidAttributedString.addAttributes(paidAttr, range: paidRange)
        
//        if HippoConfig.shared.appUserType == .agent{
//            attributedString.append(paidAttributedString)
//        }else if isPaid , HippoConfig.shared.appUserType == .customer{
//           attributedString.append(paidAttributedString)
//        }
        return attributedString
    }
    
    
    
    init?(json: [String: Any], isMultipleCards : Bool?) {
        if isMultipleCards ?? false{
            cardConfig = PaymentCardConfig.bottomConfig()
        }else{
            cardConfig = PaymentCardConfig.defaultConfig()
        }
        
        guard let id = String.parse(values: json, key: "id") else {
            return nil
        }
        self.id = id
        self.title = String.parse(values: json, key: "title")
        self.description = String.parse(values: json, key: "payment_description") ?? String.parse(values: json, key: "description")
        self.amount = Double.parse(values: json, key: "amount")
        self.currency = String.parse(values: json, key: "currency")
        self.paymentUrlString = String.parse(values: json, key: "payment_url")
        self.discount = String.parse(values: json, key: "discount")
        self.currenySymbol = String.parse(values: json, key: "currency_symbol")
        self.transactionId = String.parse(values: json, key: "transaction_id")
        
        if let selectedId = String.parse(values: json, key: "selected_id"), id == selectedId {
            isPaid = true
        }else if let selectedId = String.parse(values: json, key: "selected_id"), selectedId == ""{
            isPaid = false
        }
        
//        let listCount = Int.parse(values: json, key: "total_cards") ?? 0
//        cardConfig.imageWidth = listCount > 1 ? 30 : 0
        if HippoConfig.shared.appUserType == .customer{
            let listCount = Int.parse(values: json, key: "total_cards") ?? 0
            cardConfig.imageWidth = listCount > 1 ? 30 : 0
        }
        
        self.calculateHeight()
    }
    
    static func parse(list: [[String: Any]], selectedCardId: String) -> ([CustomerPayment], CustomerPayment?) {
        var cards: [CustomerPayment] = []
        var card: CustomerPayment?
        
        for each in list {
            var cardJson = each
            cardJson["total_cards"] = list.count
        
            guard let c = CustomerPayment(json: cardJson, isMultipleCards: list.count > 1) else {
                continue
            }
            
            if c.id == selectedCardId {
                c.isPaid = true
                c.cardConfig.imageWidth = 0
                c.calculateHeight()
                card = c
            }
            cards.append(c)
        }
        return (cards, card)
    }
    
    func calculateHeight() {
        let theme = HippoConfig.shared.theme
        let height: CGFloat = cardConfig.bgView.verticleHeight + cardConfig.innerCard.verticleHeight + cardConfig.labelView.verticleHeight
        
        let labelWidthConstraint: CGFloat = FUGU_SCREEN_WIDTH - cardConfig.bgView.horizontalWidth - cardConfig.innerCard.horizontalWidth - cardConfig.labelView.horizontalWidth - cardConfig.imageWidth - cardConfig.amountWidth
        
        let titleHeight: CGFloat = title.height(withConstrainedWidth: labelWidthConstraint, font: theme.titleFont)
        
        
        var descriptionHeight: CGFloat = description.trimWhiteSpacesAndNewLine().height(withConstrainedWidth: labelWidthConstraint, font: theme.descriptionFont)
        
        if description.trimWhiteSpacesAndNewLine().isEmpty {
            descriptionHeight = 0
        }
//        let size = CGSize(width: .greatestFiniteMagnitude, height: titleHeight)
//        let amountWidth: CGFloat = displayAmount.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).width
        
        let spacing: CGFloat = descriptionHeight <= 0 ? 0 : cardConfig.labelSpacing
        self.height = height + titleHeight + descriptionHeight + spacing
        
    }
    func getJsonForMakePayment() -> [String: Any] {
        var json: [String: Any] = [:]
        
        json["title"] = self.title
        json["description"] = self.description
        json["amount"] = self.amount ?? 0
        json["currency"] = self.currency ?? ""
        
        if let symnbol = currenySymbol {
            json["currency_symbol"] = symnbol
        }
        json["id"] = self.id
        
        if let transactionID = self.transactionId {
            json["transaction_id"] = transactionID
        }
        return json
    }
}

extension CustomerPayment: HippoCard {
    var cardHeight: CGFloat {
        return self.height
    }
}

extension CustomerPayment {
    static func mockData() -> [[String: Any]] {
        let list: [[String: Any]]  = [["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
         "title": "title 1",
         "desc": "Desc 1",
         "amount": 10.0,
         "id": "1"],
        ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
         "title": "title 2",
         "desc": "Desc 2",
         "id": "2"],
        ["image_url": "",
         "title": "title 3",
         "desc": "Desc 3",
         "amount": 100,
         "currency_symbol": "$",
         "id": "3"]]
        
        return list
    }
}
