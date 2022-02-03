//
//  PromotionalPopUpModal.swift
//  Hippo
//
//  Created by soc-admin on 25/01/22.
//

import Foundation

struct PromotionalPopUpData: Codable {
    let statusCode: Int?
    let message: String?
    let data: [Datum]?
}

// MARK: - Datum
struct Datum: Codable {
    let channelID: Int?
    let createdAt: String?
    let disableReply: Int?
    let customAttributes: CustomAttributes?
    let datumDescription, title: String?
    let userID, status: Int?

    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case createdAt = "created_at"
        case disableReply = "disable_reply"
        case customAttributes = "custom_attributes"
        case datumDescription = "description"
        case title
        case userID = "user_id"
        case status
    }
}

// MARK: - CustomAttributes
struct CustomAttributes: Codable {
    let image: ImagePopUP?
    let buttons: [ButtonPopUP]?
    let frequency: Int?
    let expiryDate, campaignName: String?

    enum CodingKeys: String, CodingKey {
        case image, buttons, frequency
        case expiryDate = "expiry_date"
        case campaignName = "campaign_name"
    }
}

// MARK: - Button
struct ButtonPopUP: Codable {
    let label, textColor, url: String?
    let actionType: Int?
    let backgroundColor: String?
//    let callbackData: [String: String]?

    enum CodingKeys: String, CodingKey{
        case label,url
        case textColor = "text_color"
        case actionType = "action_type"
        case backgroundColor = "background_color"
//        case callbackData = "callback_data"
    }
}

// MARK: - Image
struct ImagePopUP: Codable {
    let imageURL, thumbnailURL: String?

    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
    }
}

