//
//  Socomo+String.swift
//  Fugu
//
//  Created by Gagandeep Arora on 08/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

extension String {
    //    func randomString(OfLength length: Int) -> String {
    //        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    //        let len = UInt32(letters.length)
    //
    //        var randomString = ""
    //
    //        for _ in 0 ..< length {
    //            let rand = arc4random_uniform(len)
    //            var nextChar = letters.character(at: Int(rand))
    //            randomString += NSString(characters: &nextChar, length: 1) as String
    //        }
    //        return randomString
    //    }
    //
    //    func changeDateFormat(sourceFormat: String? = "yyyy-MM-dd HH:mm:ss", toFormat: String) -> String {
    //        var dateString = self.replacingOccurrences(of: ".000Z", with: "")
    //        if dateString.contains(".") == true {
    //            dateString = (dateString.components(separatedBy: "."))[0]
    //        }
    //        dateString = dateString.replacingOccurrences(of: "T", with: " ")
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = sourceFormat
    //        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    //        let date = dateFormatter.date(from: dateString)
    //
    //        dateFormatter.dateFormat = toFormat
    //        dateFormatter.timeZone = NSTimeZone.local
    //        if date != nil {
    //            return dateFormatter.string(from: date!)
    //        }
    //
    //        return ""
    //    }
    //
    
        func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            return ceil(boundingBox.height)
        }
        
        func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
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
    
    var toDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = formatter.date(from: self) else {
            return nil
        }
        
        return date
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
