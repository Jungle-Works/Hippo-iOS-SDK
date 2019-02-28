//
//  Socomo+Date.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import Foundation

extension Date {
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
                return "Yesterday"
            case let difference where (difference > 1 && difference < 8):
                return "\(dateDifference) days ago"
            default:
                formatter.dateFormat = "MMM d, yyyy"//"d/MM/yyyy"
                return formatter.string(from: self)
            }
        }
    }
   
   var toUTCFormatString: String {
      return convertDateTimeToUTC(date: self)
   }
}
