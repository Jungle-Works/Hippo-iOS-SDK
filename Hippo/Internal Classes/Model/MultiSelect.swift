//
//  MultiSelect.swift
//  HippoChat
//
//  Created by Clicklabs on 12/16/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation


struct MultipleSelectCardConfig {
    var bgView: ViewLayout
    var innerCard: ViewLayout
    var labelView: ViewLayout
    var imageWidth: CGFloat
    var labelSpacing: CGFloat
    
    
    static func defaultConfig() -> MultipleSelectCardConfig {
        let bgView = ViewLayout(leading: 45, trailing: 15, top: 3, bottom: 0)
        let innerCard = ViewLayout(equalMargin: 5)
        let labelView = ViewLayout(equalMargin: 10)
        
        let imageWidth: CGFloat = 0
        return MultipleSelectCardConfig(bgView: bgView, innerCard: innerCard, labelView: labelView, imageWidth: imageWidth, labelSpacing: 5)
    }
}

class SubmitButton
{
    let title: String
    let attributedTitle: NSMutableAttributedString?
    
    
    
    init(title: String) {
        self.title = title
        self.attributedTitle = nil
    }
    init(attributedString: NSMutableAttributedString) {
        self.title = ""
        self.attributedTitle = attributedString
    }
    
    static func createOption() -> PayementButton {
    
        let button = PayementButton(title: "Submit")
        return button
    }
}

extension SubmitButton: HippoCard {
    var cardHeight: CGFloat {
        return 50
    }
}


class MultiSelect
{
    let title: String
    var id: String
    var cardConfig: MultipleSelectCardConfig = MultipleSelectCardConfig.defaultConfig()
    var height: CGFloat = .zero
    var isLocalySelected: Bool = false
    
    
    init?(json: [String: Any]) {
        guard let id = String.parse(values: json, key: "id") else {
            return nil
        }
        self.id = id
        self.title = String.parse(values: json, key: "label")
        if let selectedId = String.parse(values: json, key: "status"), id == selectedId {
          
        }
        
      //  let listCount = Int.parse(values: json, key: "total_cards") ?? 0
      //  cardConfig.imageWidth = listCount > 1 ? 30 : 0
        self.calculateHeight()
    }
    
    
    
    func calculateHeight() {
        let theme = HippoConfig.shared.theme
        let height: CGFloat = cardConfig.bgView.verticleHeight + cardConfig.innerCard.verticleHeight + cardConfig.labelView.verticleHeight
        
        let labelWidthConstraint: CGFloat = FUGU_SCREEN_WIDTH - cardConfig.bgView.horizontalWidth - cardConfig.innerCard.horizontalWidth - cardConfig.labelView.horizontalWidth - cardConfig.imageWidth
        
        let titleHeight: CGFloat = title.height(withConstrainedWidth: labelWidthConstraint, font: theme.titleFont)
        
        
        
        let spacing: CGFloat = cardConfig.labelSpacing
        self.height = height + titleHeight  + spacing
        
    }
    
   /* func getJsonForMakePayment() -> [String: Any] {
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
    }*/
}

extension MultiSelect: HippoCard {
    var cardHeight: CGFloat {
        return self.height
    }
}
