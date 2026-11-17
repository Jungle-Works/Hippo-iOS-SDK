//
//  CreateTicketDataModel.swift
//  Hippo
//
//  Created by Neha Vaish on 26/04/23.
//

import UIKit

// MARK: - CreateTicketDataModel

@objc public class CreateTicketDataModel: NSObject {
    var customer_email: String?
    var customer_name: String?
    var subject: String?
    var issueDescription : String?
    var priority: String?
    var issue : String?
    var userTags = [String]()
    public var attachments = [AttachmentData(path: "", type: "")]
    
    override init() {}
    public init(tName:String, tEmail:String, tSubject:String, tDescription:String, tTags:[String], tAttachments : [AttachmentData]) {
        self.customer_name = tName
        self.customer_email = tEmail
        self.subject = tSubject
        self.issueDescription = tDescription
        self.userTags = tTags
        self.attachments = tAttachments
    }

}


public class AttachmentData {
      let path: String
      let type: String
      let name: String
    
    public init(path: String, type: String, name: String = "") {
        self.path = path
        self.type = type
        
        if name.isEmpty {
            self.name = URL.init(fileURLWithPath: path).lastPathComponent
        } else {
            self.name = name
        }
    }
}
