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
    var bgView: ViewLayout
    var innerCard: ViewLayout
    var labelView: ViewLayout
    var imageWidth: CGFloat
    var labelSpacing: CGFloat
    var amountWidth: CGFloat = 100
    
    static func defaultConfig() -> PaymentCardConfig {
        let bgView = ViewLayout(leading: 20, trailing: 20, top: 3, bottom: 0)
        let innerCard = ViewLayout(equalMargin: 5)
        let labelView = ViewLayout(equalMargin: 10)
        
        let imageWidth: CGFloat = 0
        return PaymentCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5, amountWidth: 100)
    }
}

class PayementButton {
    let title: String
    var selectedCardDetail: CustomerPayment?
    var showAmount: Bool = true
    
    init(title: String) {
        self.title = title
    }
}

extension PayementButton: HippoCard {
    var cardHeight: CGFloat {
       return 50
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
    
    var displayAmount: NSAttributedString {
        let theme = HippoConfig.shared.theme
        var amountText: String = "Free"
        let currencySymbol: String = currenySymbol?.trimWhiteSpacesAndNewLine() ?? ""
        if let temp = amount, temp > 0 {
            amountText = "\(currencySymbol) \(temp)"
        }
        let range = (amountText as NSString).range(of: amountText)
        let attributedString = NSMutableAttributedString(string: amountText)
        let attr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: theme.pricingFont,
                                                   NSAttributedString.Key.foregroundColor: theme.pricingTextColor ?? theme.headerBackgroundColor]
        attributedString.addAttributes(attr, range: range)
        
        let paidString = "\n - PAID -"
        let paidRange = (paidString as NSString).range(of: paidString)
        let paidAttr: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: theme.descriptionFont]
        
        let paidAttributedString = NSMutableAttributedString(string: paidString)
        paidAttributedString.addAttributes(paidAttr, range: paidRange)
        
        if isPaid {
            attributedString.append(paidAttributedString)
        }
        return attributedString
    }
    
    
    
    init?(json: [String: Any]) {
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
        
        if let selectedId = String.parse(values: json, key: "selected_id"), id == selectedId {
            isPaid = true
        }
        
        self.calculateHeight()
    }
    
    static func parse(list: [[String: Any]], selectedCardId: String) -> ([CustomerPayment], CustomerPayment?) {
        var cards: [CustomerPayment] = []
        var card: CustomerPayment?
        
        for each in list {
        
            guard let c = CustomerPayment(json: each) else {
                continue
            }
            if c.id == selectedCardId {
                c.isPaid = true
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
