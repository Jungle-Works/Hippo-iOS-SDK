//
//  FuguPay.swift
//  SDKDemo1
//
//  Created by socomo on 12/02/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
class FuguPay {
    
    // MARK: - Properties
    var canSendMoney: Bool
    var canRequestMoney: Bool
    var sendRequestMoneyData: [String: Any]
    
    
    init(canSendMoney: Bool, canRequestMoney: Bool,sendRequestMoneyData: [String: Any] ) {
     
        self.canSendMoney = canSendMoney
        self.canRequestMoney = canRequestMoney
        self.sendRequestMoneyData = sendRequestMoneyData
    }
    
    init?(dict: [String: Any]) {
        canSendMoney = false
        canRequestMoney = false
        sendRequestMoneyData = [:]
        
        if let can_send_money = dict["can_send_money"] as? Bool  {
            canSendMoney = can_send_money
        }
        
        if let can_request_money = dict["can_request_money"] as? Bool  {
            canRequestMoney = can_request_money
        }
        
        if let send_request_money = dict["additional_details"] as? [String: Any]  {
            sendRequestMoneyData = send_request_money
        }
   
    }
}
