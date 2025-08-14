//
//  Socomo+Date.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import Foundation

enum DateFormat: String {
    case onlyDate = "yyyy/MM/d"
    case serverTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
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
                formatter.dateFormat = "MM/d/yyyy"
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
    
    func toString(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    var toUTCFormatString: String {
        return convertDateTimeToUTC(date: self)
    }
    
    func findDayDifference(referenceDate: Date) -> Int? {
        let calendar = NSCalendar.current
        let dateOfMsg = calendar.startOfDay(for: self)
        let currentDate = calendar.startOfDay(for: referenceDate)
        
        let dateDifference: Int? =  calendar.dateComponents([.day], from: dateOfMsg, to: currentDate).day
        
        return dateDifference
    }
    
    func formatTo(type: DateFormat) -> String {
        let formatterUTC = DateFormatter()
        formatterUTC.dateFormat = type.rawValue
        formatterUTC.timeZone = TimeZone(secondsFromGMT: 0)
        formatterUTC.locale = Locale(identifier: "en_US_POSIX")
        
        return formatterUTC.string(from: self)
    }
    
    func changeDateFormat(toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = toFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: self)
    }
    
    func addDay(days: Int) -> Date {
        var currentDate = self
        if days != 0 {
            currentDate = (Calendar.current.date(byAdding: .day, value: days, to: currentDate)) ?? currentDate
        }
        return currentDate
    }
    
    func generateFilterUTCDateForServer() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        var dateString = dateFormatter.string(from: self)
        dateString = dateString + "T00:00:00.000Z"
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var newDate = dateFormatter.date(from: dateString)
        newDate = newDate?.addingTimeInterval(TimeInterval(-CoreUtil.secondsFromGMT))
        
        return newDate?.toUTCFormatString ?? ""
    }
}

public class CoreUtil {
    public static var secondsFromGMT: Int {
        return TimeZone.current.secondsFromGMT()
    }
    public static var minutesFromGMT: Int {
        return (TimeZone.current.secondsFromGMT() / 60)
    }
    public static var offsetFromGMT: Int {
        return Int(TimeZone.current.secondsFromGMT().magnitude)
    }
    
}
