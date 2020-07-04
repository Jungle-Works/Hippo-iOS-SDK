//
//  Socomo+Date.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import Foundation

enum DateFormat: String {
    case onlyDate = "yyyy/MM/d"
    case broadcastDate = "MMM d, yyyy, hh:mm a"
}

extension Date {
    func toMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy, hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        let comparisonResult = Calendar.current.compare(self,
                                                        to: Date(),
                                                        toGranularity: .day)
        
        switch comparisonResult {
            
        case .orderedSame:
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: self)
        default:
            let calendar = NSCalendar.current
            let dateOfMsg = calendar.startOfDay(for: self)
            let currentDate = calendar.startOfDay(for: Date())
            
            let dateDifference = calendar.dateComponents([.day], from: dateOfMsg, to: currentDate).day ?? -1
            
            switch dateDifference {
            case 1:
                //formatter.dateFormat = "hh:mm a"
                return HippoStrings.yesterday
            case let difference where (difference > 1 && difference < 8):
                return "\(dateDifference) \(HippoStrings.daysAgo)"
            default:
                formatter.dateFormat = "d/MM/yyyy"
                return formatter.string(from: self)
            }
        }
    }
   
    func toString(with format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
         return formatter.string(from: self)
    }
   var toUTCFormatString: String {
      return convertDateTimeToUTC(date: self)
   }
}
