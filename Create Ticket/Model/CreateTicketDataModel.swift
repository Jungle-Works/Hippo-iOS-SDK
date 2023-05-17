//
//  CreateTicketDataModel.swift
//  Hippo
//
//  Created by Neha Vaish on 26/04/23.
//

import UIKit

// MARK: - CreateTicketDataModel
struct CreateTicketDataModel {
    var priority: String?
    var issue : String?
    var subject: String?
    var customer_email: String?
    var customer_name: String?
    var issueDescription : String?
    var group : String?
}


struct AttachmentData {
     let path: String
     let type: String
     let name: String
    
     init(path: String, type: String, name: String = "") {
        self.path = path
        self.type = type
        
        if name.isEmpty {
            self.name = URL.init(fileURLWithPath: path).lastPathComponent
        } else {
            self.name = name
        }
    }
}
