//
//  MessageCard.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

protocol HippoCard {
    var cardHeight: CGFloat { get }
}


struct MessageCard: HippoCard {
    var cardHeight: CGFloat {
        return 230
    }
    
    let image: HippoResource?
    let title: String
    let description: String
    
    let id: String
    let rating: Double?
    
    init?(json: [String: Any]) {
        guard json["id"] != nil else {
            return nil
        }
        if let imageURL = json["image_url"] as? String, let url = URL(string: imageURL) {
            self.image = HippoResource(url: url)
        } else {
            self.image = nil
        }
        self.title = String.parse(values: json, key: "title")
        self.description = String.parse(values: json, key: "description")
        
        self.id = String.parse(values: json, key: "id")
        self.rating = Double.parse(values: json, key: "rating")
    }
    static func parseList(cardsJson: [[String: Any]]) -> [MessageCard] {
        var cards: [MessageCard] = []
        
        for card in cardsJson {
            guard let c = MessageCard(json: card) else {
                continue
            }
            cards.append(c)
        }
        return cards
    }
    
    static func parseList(cardsJson: [[String: Any]], selectedCardID: String?) -> ([MessageCard], MessageCard?) {
        var cards: [MessageCard] = []
        var selectedCard: MessageCard?
        
        for card in cardsJson {
            guard let c = MessageCard(json: card) else {
                continue
            }
            if c.id == selectedCardID {
                selectedCard = c
            }
            cards.append(c)
        }
        return (cards, selectedCard)
    }
    
    static func generateMessage() -> HippoMessage? {
        let message = HippoMessage(message: "", type: .card, chatType: .other)
        message.cards = MessageCard.getMockData()
        message.messageUniqueID = mockMuID
        return message
    }
}

extension MessageCard {
    static let mockMuID = String.generateUniqueId()
    
    static func getMockData() -> [MessageCard] {
        return parseList(cardsJson: mockList)
    }
    
    static let mockList = [["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                            "title": "title 1",
                            "desc": "Desc 1",
                            "id": 1],
                           ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                            "title": "title 2",
                            "desc": "Desc 2",
                            "id": 2],
                           ["image_url": "",
                            "title": "title 3",
                            "desc": "Desc 3",
                            "id": 3],
                           ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                            "title": "title 1",
                            "desc": "Desc 1",
                            "id": 1],
                           ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                            "title": "title 1",
                            "desc": "Desc 1",
                            "id": 1],
                           ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                            "title": "title 2",
                            "desc": "Desc 2",
                            "id": 2],
                           ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                            "title": "title 2",
                            "desc": "Desc 2",
                            "id": 2],["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                             "title": "title 1",
                             "desc": "Desc 1",
                             "id": 1],
                            ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                             "title": "title 2",
                             "desc": "Desc 2",
                             "id": 2],
                            ["image_url": "",
                             "title": "title 3",
                             "desc": "Desc 3",
                             "id": 3],
                            ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                             "title": "title 1",
                             "desc": "Desc 1",
                             "id": 1],
                            ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                             "title": "title 1",
                             "desc": "Desc 1",
                             "id": 1],
                            ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                             "title": "title 2",
                             "desc": "Desc 2",
                             "id": 2],
                            ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                             "title": "title 2",
                             "desc": "Desc 2",
                             "id": 2],["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                              "title": "title 1",
                              "desc": "Desc 1",
                              "id": 1],
                             ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                              "title": "title 2",
                              "desc": "Desc 2",
                              "id": 2],
                             ["image_url": "",
                              "title": "title 3",
                              "desc": "Desc 3",
                              "id": 3],
                             ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                              "title": "title 1",
                              "desc": "Desc 1",
                              "id": 1],
                             ["image_url": "https://fuguchat.s3.ap-south-1.amazonaws.com/test/image/KeCkU6JXfL_1571641116341.png",
                              "title": "title 1",
                              "desc": "Desc 1",
                              "id": 1],
                             ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                              "title": "title 2",
                              "desc": "Desc 2",
                              "id": 2],
                             ["image_url": "https://fchat.s3.ap-south-1.amazonaws.com/default/Nl82thIs1q_1559051800922.jpg",
                              "title": "title 2",
                              "desc": "Desc 2",
                              "id": 2]]
}
