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


