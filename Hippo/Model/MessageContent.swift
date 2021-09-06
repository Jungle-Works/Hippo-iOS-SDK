//
//  MessageContent.swift
//  SDKDemo1
//
//  Created by Vishal on 22/08/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation


class MessageContent: NSObject {
    var questionsArray = [String]()
    var dataType = [String]()
    var values = [String]()
    var buttonTitles: [String] = []
    var actionId: [String] = []
    var paramId: [Int] = []
    var params: [String] = []
    var erpCustomerName: String?
    override init() {
        
    }
    
    init(param: [[String: Any]]) {
        guard param.count > 0 else {
            return
        }
        let json = param[0]
        paramId = json["params_id"] as? [Int] ?? [Int]()
        params = json["params"] as? [String] ?? [String]()
        questionsArray = json["questions"] as? [String] ?? [String]()
        dataType = json["data_type"] as? [String] ?? []
        values = json["values"] as? [String] ?? [String]()
        for dict in param {
            if let title = dict["button_title"] as? String {
                self.buttonTitles.append(title)
            }
            if let actionId = dict["action_id"] as? String {
                self.actionId.append(actionId)
            }
        }
    }
}
