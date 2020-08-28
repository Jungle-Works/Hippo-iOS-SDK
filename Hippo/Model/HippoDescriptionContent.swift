//
//  HippoDescriptionContent.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation


class HippoDescriptionContent {
    var subHeading = ""
    var description = ""
    var textViewText = ""
    var isQueryFormEnabled = false
    var responseText = ""
    var defaultText = HippoStrings.hippoDefaultText
    
    var chatButton = buttonContent()
    var callButton = buttonContent()
    var submitButton = buttonContent()
    
    init() {
        
    }
    
    init(json: [String: Any]) {
        if let heading_dict = json["sub_heading"] as? [String: Any] {
            subHeading = heading_dict["text"] as? String ?? ""
        }
        if let desc_dict = json["description"] as? [String: Any] {
            description = desc_dict["text"] as? String ?? ""
        }
        
        if let dict = json["chat_button"] as? [String: Any] {
            var button = buttonContent(dict: dict)
            button.type = .conversation
            self.chatButton = button
        }
        if let dict = json["call_button"] as? [String: Any] {
            var button = buttonContent(dict: dict)
            button.type = .call
            self.callButton = button
        }
        if let dict = json["submit_button"] as? [String: Any] {
            if let response_text = dict["response_text"] as? String {
                self.responseText = response_text
            }
            var button = buttonContent(dict: dict)
            button.type = .submit
            self.submitButton = button
        }
        if let dict = json["query_form"] as? [String: Any] {
            isQueryFormEnabled = true
            if let text_view = dict["text_view"] as? [String: Any], let text = text_view["text"] as? String {
                textViewText = text
            }
        }
    }
}
struct buttonContent {
    var isEnabled = false
    var text = ""
    var number = ""
    var type = ButtonType.none
    
    init() {
        
    }
    init(dict: [String: Any]) {
        if let text = dict["text"] as? String, !text.isEmpty {
            self.text = text
            isEnabled = true
        } else {
            isEnabled = false
        }
        if let text = dict["phone"] as? String, !text.isEmpty {
            self.number = text
        }
        
    }
}
