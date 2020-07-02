//
//  Socomo+String.swift
//  Fugu
//
//  Created by Gagandeep Arora on 08/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import MobileCoreServices

extension String {
    
    static func parse(values: [String :Any], key: String, defaultValue: String = "") -> String {
       
        return parse(values: values, key: key) ?? defaultValue
    }
    static func parse(values: [String :Any], key: String) -> String? {
        if let rawKey = values[key] as? String {
            return rawKey
        } else if let rawKey = values[key] as? Int {
            return String(rawKey)
        }  else if let rawKey = values[key] as? UInt {
            return String(rawKey)
        } else if let rawKey = values[key] as? NSNumber {
            return "\(rawKey)"
        }  else if let rawKey = values[key] as? Double {
            return String(rawKey)
        }
        return nil
    }
    
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailTest.evaluate(with: self) {
            return false
        } else {
            return true
        }
    }
    var localized: String {
        if let path = FuguFlowManager.bundle?.path(forResource: getCurrentLanguageLocale(), ofType: "lproj") {
              let bundle = Bundle(path: path)
              return NSLocalizedString(self, tableName: "HippoLocalizable", bundle: bundle!, value: "", comment: "")
          }
          return self
      }
    
    
    func isOnlyNumber() -> Bool {
        let number = UInt(self)
        return number != nil
    }
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "[0-9]{4,14}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    func isValidNumberWithCountryCode() -> Bool {
        let phoneRegex = "[\\+]{0,1}[0-9]{6,17}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    func isValidDecimalNumber() -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.locale = Locale.current
        return formatter.number(from: self) != nil
    }
    
    func isValidCountryCode() -> Bool {
        let phoneRegex = "\\+[0-9]{1,5}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    func isOnlyString() -> Bool {
       return true
    }
    
    func length() -> Int {
        return self.count
    }
    
    func mimeTypeForPath() -> String {
        let url = URL.init(fileURLWithPath: self)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    func fileName() -> String {
        let url = URL.init(fileURLWithPath: self)
        let pathExtension = url.lastPathComponent
        
        if !pathExtension.isEmpty {
            return pathExtension
        }
        return "Attachment"
    }
    
    static func uuid() -> String {
        return UUID().uuidString
    }
    
    static func generateUniqueId() -> String {
        return UUID().uuidString.suffix(10) + ".\(arc4random()).\(Date().toMillis())"
    }
    
        func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            #if swift(>=4.0)
            
            let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
            #else
            let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
            #endif
            
            return ceil(boundingBox.height)
        }
        
        func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            
            #if swift(>=4.0)
            
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            #else
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            #endif
            
            
            
            return ceil(boundingBox.width)
        }
    
    func trimWhiteSpacesAndNewLine() -> String {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    
    func removeNewLine() -> String {
        let newString = self.replacingOccurrences(of: "\n", with: " ")
        return newString
    }
    
    var utcFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }
    var toDate: Date? {
        let formatter = utcFormatter
        
        guard let date = formatter.date(from: self) else {
            HippoConfig.shared.log.debug("----\(self)==== nahi chala", level: .customError)
            return nil
        }
        return date
    }
    
    var toDateWithLinent: Date {
        let formatter = utcFormatter
        formatter.isLenient = true
        
        return formatter.date(from: self) ?? Date()
    }
    func checkNA() -> String {
        let str = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.count == 0 {
            return "--"
        } else {
            return self
        }
    }
   
   func formatName() -> String {
      var _name = self.trimWhiteSpacesAndNewLine()
      _name = _name.capitalized
      return _name
   }
    func addHTMLEntities() -> String {
        var tempString = self
        tempString = tempString.htmlEscapeTagOnly()
        return tempString
    }
    func removeHtmlEntities() -> String {
        var tempString = self
        tempString = tempString.htmlUnescape()
        return tempString
    }

}
private extension String {
    func changeDateFormat(sourceFormat: String? = "yyyy-MM-dd HH:mm:ss",
                          toFormat: String) -> String {
        var dateString = self.replacingOccurrences(of: ".000Z", with: "")
        if dateString.contains(".") == true {
            dateString = (dateString.components(separatedBy: "."))[0]
        }
        dateString = dateString.replacingOccurrences(of: "T",
                                                     with: " ")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = toFormat
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = NSTimeZone.local
        if date != nil { return dateFormatter.string(from: date!) }
        
        return ""
    }
}
