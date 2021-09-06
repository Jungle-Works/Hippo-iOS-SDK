//
//  FuguActionableMessage.swift
//  AFNetworking
//
//  Created by socomo on 15/12/17.
//

import UIKit

@objc public class FuguActionableMessage: NSObject {

    var actionButtonsArray = [Any]()
    var descriptionArray = [Any]()
    var messageImageURL = ""
    var messageTitle = ""
    var titleDescription = ""
    var botResponseType : BotResponseType?
    var allowedDateTime : AllowedDateTimeType?
    var dateTimeFormat = ""
    var customActionJson = [String : Any]()
    
    // MARK: - Intializer
//     public override init() {}
    public override init() {
        
    }
    public init(dict: [String: Any]) {
      //  super.init()
        if let buttonActionArray = dict["action_buttons"] as? [Any] {
            actionButtonsArray = buttonActionArray
        }
        if let buttonActionArray = dict["description"] as? [Any] {
            descriptionArray = buttonActionArray
        }
        if let image_url = dict["image_url"] as? String {
            messageImageURL = image_url
        }
        if let title = dict["title"] as? String {
            messageTitle = title
        }
        if let title = dict["title_description"] as? String {
            titleDescription = title
        }
        if let botResponse = dict["bot_response_type"] as? String {
            botResponseType = BotResponseType(rawValue: botResponse)
        }
        customActionJson = dict
        if let calendarTime = dict["calendar_time"] as? [String : Any] {
            if let allowedDteTime = calendarTime["allowed_date_time"] as? String {
                allowedDateTime = AllowedDateTimeType(rawValue: allowedDteTime)
            }
            dateTimeFormat = calendarTime["date_time_format"] as? String ?? ""
        } else if let calendarTime = dict["date_scroller"] as? [String : Any] {
            if let allowedDteTime = calendarTime["allowed_date_time"] as? String {
                allowedDateTime = AllowedDateTimeType(rawValue: allowedDteTime)
            }
            dateTimeFormat = calendarTime["date_time_format"] as? String ?? ""
        } else if let calendarTime = dict["time_scroller"] as? [String : Any] {
            if let allowedDteTime = calendarTime["allowed_date_time"] as? String {
                allowedDateTime = AllowedDateTimeType(rawValue: allowedDteTime)
            }
            dateTimeFormat = calendarTime["date_time_format"] as? String ?? ""
        }
    }
    
    func getDictToSaveToCache()-> [String: Any] {
        var dict = [String: Any]()
        
        dict["action_buttons"] = actionButtonsArray
        dict["description"] = descriptionArray
        dict["image_url"] = messageImageURL
        dict["title"] = messageTitle
        dict["title_description"] = titleDescription
        return dict
    }
    
}


enum BotResponseType : String {
    case date = "18"
    case time = "19"
    case dateTime = "20"
}

enum AllowedDateTimeType : String {
    case all = "0"
    case future = "1"
    case past = "2"
}
