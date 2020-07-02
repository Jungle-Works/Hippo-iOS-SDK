//
//  CustomField.swift
//  HippoAgent
//
//  Created by Vishal on 19/11/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class CustomFieldAttachment {
    let id: String = UUID().uuidString
    var fileUrl: String?
    var fileLocalPath: String?
    var fileName: String?
    var documentType: FileType?
    
    var canBeCancelled: Bool = true
    var isAddOption: Bool = false
    var parsedMimeType: String?
    
    var mimeType: String? {
        guard parsedMimeType == nil else {
            return parsedMimeType
        }
        let type: String?
        if fileLocalPath != nil {
            type = fileLocalPath?.mimeTypeForPath()
        } else if fileUrl != nil {
            type = fileUrl?.mimeTypeForPath()
        } else {
            type = nil
        }
        parsedMimeType = type
        return parsedMimeType
    }
    var concreteFileType: FileType? {
        
        guard documentType == nil else {
            return documentType
        }
        let mimeType = self.mimeType
        
        if isUnhandledType() {
            documentType = .document
            return documentType
        }
        
        guard self.fileUrl != nil else {
            if mimeType != nil {
                documentType = FileType.init(mimeType: mimeType!)
                return documentType
            }
            documentType = FileType.document
            return documentType
        }
        
        guard let unwrappedMimeType = mimeType else {
            return nil
        }
        documentType = FileType.init(mimeType: unwrappedMimeType)
        return documentType
    }
    
    init() {
        
    }
    
    init?(json: [String: Any]) {
        guard let url = json["url"] as? String else {
            return nil
        }
        fileName = String.parse(values: json, key: "file_name")
        fileUrl = url
    }
    static func getAddFieldOption() -> CustomFieldAttachment {
        let field = CustomFieldAttachment()
        field.canBeCancelled = false
        field.isAddOption = true
        return field
    }
    
    internal func isUnhandledType() -> Bool {
        guard let mimeType = self.mimeType else {
            return false
        }
        let type = mimeType.components(separatedBy: "/")
        guard let parsedType = type.last?.lowercased(), !parsedType.isEmpty else {
            return false
        }
        let unhandledMimeType = ["vnd.adobe.photoshop", "psd", "tiff", "svg", "svg+xml"]
        return unhandledMimeType.contains(parsedType)
    }
    
    func getJson() -> [String: Any] {
        var json: [String: Any] = [:]
        json["url"] = fileUrl ?? ""
        if let fileName = self.fileName?.trimWhiteSpacesAndNewLine(), !fileName.isEmpty {
            json["file_name"] = fileName
        }
        return json
    }
    
    static func parse(list: [[String: Any]]) -> [CustomFieldAttachment] {
        var attachments: [CustomFieldAttachment] = []
        
        for each in list {
            guard let result = CustomFieldAttachment(json: each) else {
                continue
            }
            attachments.append(result)
        }
        return attachments
    }
}

class CustomField {
    let id: String?
    var displayName: String
    var fieldTitle: String
    let isRequired: Bool
    let placeholder: String
    let showToCustomer: Bool
    let canAgentEdit: Bool
    
    let fieldType: CustomFieldType
    
    var maximumAttachment: Int = 2
    var value: String?
    var attachmentJson: [CustomFieldAttachment]?
    
    var error: String?
    
    var displayTitle: String {
        var fieldTitle = self.fieldTitle
        if isRequired {
            fieldTitle += " *"
        }
        fieldTitle = fieldTitle.capitalized
        return fieldTitle.trimWhiteSpacesAndNewLine()
    }
    
    init?(json: [String: Any]) {
        let rawFieldType = String.parse(values: json, key: "field_type") ?? "None"
        let fieldType: CustomFieldType = CustomFieldType(rawValue: rawFieldType) ?? .none
        self.fieldType = fieldType
        fieldTitle = String.parse(values: json, key: "field_name", defaultValue: "")
        displayName = String.parse(values: json, key: "display_name", defaultValue: "")
        placeholder = String.parse(values: json, key: "placeholder", defaultValue: "")
        isRequired = Bool.parse(key: "is_required", json: json, defaultValue: false)
        showToCustomer = Bool.parse(key: "show_to_customer", json: json, defaultValue: false)
        canAgentEdit = Bool.parse(key: "can_agent_edit", json: json, defaultValue: false)
        value = String.parse(values: json, key: "value")
        id = String.parse(values: json, key: "id")
        maximumAttachment = Int.parse(values: json, key: "maximum_attachment") ?? self.maximumAttachment
        
        if let rawAttachmentJson = json["value_json"] as? [[String: Any]], !rawAttachmentJson.isEmpty {
            self.attachmentJson = CustomFieldAttachment.parse(list: rawAttachmentJson)
        }
        
        if fieldType == .attachment {
            var attachmentJson = self.attachmentJson ?? []
            attachmentJson.append(CustomFieldAttachment.getAddFieldOption())
            self.attachmentJson = attachmentJson
        }
    }
    
    
    func isValidToInsert(text: String) -> Bool {
        return true
    }
    
    static func parse(list: [[String: Any]]) -> [CustomField] {
        var result: [CustomField] = []
        
        for each in list {
            guard let field = CustomField(json: each) else {
                continue
            }
            result.append(field)
        }
        return result
    }
    
    func isValid() -> Bool {
        let result = (value ?? "").trimWhiteSpacesAndNewLine()
        let attachments = getValidAttachment()
        
        if isRequired && result.isEmpty && (fieldType != .attachment) {
            error = "\(fieldTitle.capitalized) is required"
            return false
        }
        
        if isRequired && fieldType == .attachment && attachments.isEmpty {
            error = "Please add \(fieldTitle)"
            return false
        }
        
        switch fieldType {
         case .email:
            let isValidResult: Bool = result.isEmpty ? true : result.isValidEmail()
            error = isValidResult ? nil : "Invalid \(fieldTitle.capitalized)"
            return isValidResult
         case .number, .phoneNumber:
            let isValidResult: Bool = result.isEmpty ? true : result.isOnlyNumber()
            error = isValidResult ? nil : "Invalid \(fieldTitle.capitalized)"
            return isValidResult
         default:
            break
        }
        
        return true
    }
    func getValidAttachment() -> [CustomFieldAttachment] {
        let list = attachmentJson?.filter({ (a) -> Bool in
            return !a.isAddOption
        })
        return list ?? []
    }
    func getJsonToSend() -> [String: Any] {
        
        var json: [String: Any] = ["field_name": fieldTitle,
                                   "field_type": fieldType.rawValue,
                                   "is_required": isRequired,
                                   "placeholder": placeholder,
                                   "display_name": displayName,
                                   "show_to_customer": showToCustomer,
                                   "can_agent_edit": canAgentEdit,
                                   "value": value ?? ""]
        
        if let parsedId = id {
            json["id"] = parsedId
        }
        
        var attachmentJson: [[String: Any]] = []
        for each in getValidAttachment() {
            attachmentJson.append(each.getJson())
        }
        
        if !attachmentJson.isEmpty {
            json["value_json"] = attachmentJson
        }
        return json
    }
}

enum CustomFieldType: String {
    case text = "Text"
    case textView = "TextArea"
    case number = "Number"
    case email = "Email"
    case phoneNumber = "Telephone"
    case attachment = "Document"
    case none = "None"
    
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text:
            return .default
        case .textView:
            return .default
        case .number:
            return .numberPad
        case .email:
            return .emailAddress
        case .phoneNumber:
            return .decimalPad
        case .attachment:
            return .default
        case .none:
            return .default
        }
    }
}
